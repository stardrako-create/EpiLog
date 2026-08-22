# Aggregate access & contribution verification — design spec

Compiled from the design conversation on 2026-08-22. Not built yet — this is
the spec to implement against, phased below. Grounded in the actual current
schema (`sql/add_registry_auth.sql`, `sql/add_aggregate_consent.sql`,
`sql/add_share_links.sql`), not a hypothetical one.

## The problem this solves

The registry (`experiments`/`checkins`) is currently private-by-default,
one-shot-shareable-by-link. That protects labs from being scooped, but it
also means negative results that would help the field never surface anywhere
except a share link handed out one-to-one. The goal: let labs *check* whether
a locus/cell-type combination has already been tried elsewhere, without
exposing whose data it is, without exposing it before the contributing lab's
own race is over, and without handing over anything bulk-extractable enough
to train a model on.

## What "aggregate access" actually means here

Not a browsable/queryable table. A single Postgres RPC function,
`lookup_locus_aggregate(p_locus text, p_cell_model text)`, callable only for
one specific `(locus, cell_model)` pair at a time. No listing endpoint, no
filters beyond the two required params, no pagination. Returns something like
`{ n: 4, silenced_within_8w: 3 }` — a count and a summary stat, never raw
rows, never `user_id`, never `notes`.

Two independent gates apply before an experiment's checkins count toward that
aggregate at all:

### Gate 1 — embargo

New column on `experiments`: `aggregate_visible_at timestamptz`. Default:
`created_at + interval '15 months'` (a reasoned starting point for a typical
locus-search-to-publication timeline, not a fitted number — adjust if labs
push back). The owning lab can update this to `now()` any time to release
early once they've published or moved on. Nothing in the aggregate function
counts an experiment whose `aggregate_visible_at` is still in the future.

### Gate 2 — small-N suppression

`lookup_locus_aggregate` returns null/empty rather than a real count when
fewer than 3 qualifying experiments exist for that pair. A count of 1 or 2 is
functionally a raw-record leak (you can often guess whose it is); 3 is a
reasoned floor, not a validated one.

Both gates are independent of `allow_aggregate_use` (the existing consent
flag) — that flag should gate whether an experiment is eligible for the
*aggregate pool* at all; embargo and small-N gate what's actually returned
from that pool at query time.

## Access control on the lookup itself

- **Per-account rate limit** on calls to `lookup_locus_aggregate` — cap
  distinct `(locus, cell_model)` lookups per account per day/week. Naive
  scraping (many distinct pairs, short window) looks nothing like real usage
  (a handful of pairs, tied to an actual project).
- **Contribution-gated credits** — N lookups per *verified* contribution (see
  below for what "verified" means). Ties consumption to production; bounds
  total extraction by what an account has actually put in.
- **Query logging** — log every call (account, params, timestamp). No
  real-time blocking needed at first; a simple periodic query for accounts
  with high distinct-pair counts in a short window catches most naive
  scraping without building anomaly-detection infrastructure up front.

## Contribution verification — why it's needed now

Credits make fabrication worth doing for the first time (private-only data
had no reason to be faked). Verification tiers, cheapest to most rigorous:

1. **Schema/plausibility validation** (cheap, automatic, do this first) —
   valid genome coordinates for the stated species/build, values in
   biologically plausible ranges. Catches sloppy fakes for free.
2. **Check-in-gated credit unlock** (uses existing `checkins` table as-is) —
   an experiment doesn't earn lookup credit until it has at least one
   check-in at a minimum realistic interval after `created_at`. A single
   fabricated row with no follow-up pattern doesn't qualify; sustaining a
   fake timeline across real elapsed time is a much bigger ask than typing
   one row.
3. **Public-reference plausibility check** (bigger build, real payoff) — for
   species with solid public ATAC-seq/RRBS coverage (human, mouse — not yet
   dog/pig/goat/cattle), cross-check a claimed outcome against reference
   chromatin/methylation state at that locus. Reuses SafeHarborCanine's
   existing ATAC/RRBS analysis capability rather than building new
   infrastructure — same underlying task, different question asked of it.
   Auto-flags inconsistent claims for review; doesn't block submission.
4. **Lab-submitted processed summary, optional "verified" tier** — a lab
   voluntarily attaches their own processed output (peak-call/accessibility
   summary, KB-scale, computed on *their* infrastructure — never raw
   FASTQ/BAM, never processed on ours) for a stronger tier: more credit,
   skip the check-in wait. Validated with cheap format/statistical sanity
   checks on our end, not re-processed from scratch.
5. **Targeted raw-data audit, rare** — only for entries already flagged by
   (1)-(4) or in species too thin on public reference data to plausibility-
   check any other way. Requested from the specific lab as a one-off, not a
   standing requirement.
6. **Spot-check manual review** — random sample + anything flagged above.
   Real consequence when fabrication is confirmed (credits revoked, account
   suspended), which is what makes the deterrent real, not the review
   coverage itself (full verification of unpublished data is impossible by
   definition).

## Suggested build order

1. `aggregate_visible_at` column + default trigger, small-N-suppressed
   `lookup_locus_aggregate` RPC, no credit system yet — ships the core
   privacy-safe lookup on its own, testable immediately.
2. Rate limiting + query logging on the RPC.
3. Check-in-gated credit accounting (new `lookup_credits` column or table on
   `profiles`; decrement on lookup, increment on qualifying check-in).
4. Schema/plausibility validation on `experiments` insert.
5. Public-reference ATAC/RRBS consistency check — biggest single piece,
   sequence last, reuses SafeHarborCanine's pipeline rather than building
   fresh.
6. Optional lab-submitted-summary "verified" tier + spot-check review
   workflow — last, since it's UI/process work more than schema work.

Steps 1-4 are all schema + RPC work on tables that already exist with RLS
already correct. Step 5 is the one that needs its own scoping pass before
starting.
