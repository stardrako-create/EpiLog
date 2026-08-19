# EpiLog

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.21996604.svg)](https://doi.org/10.5281/zenodo.21996604)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**A curated, literature-derived catalog of genomic safe harbor loci and post-edit silencing outcomes — plus a shared registry for tracking gene-editing experiments over time.**

Live: [epilogbio.netlify.app](https://epilogbio.netlify.app)

---

## What this is

Genomic "safe harbors" — loci like AAVS1, ROSA26, or H11 where a transgene can be inserted without disrupting neighboring genes — are treated as interchangeable, plug-and-play tools across gene-editing labs. In practice, whether a locus is actually "safe" depends on species, genome assembly, cell type, and differentiation state: a locus that stays active in iPSCs can silence completely after differentiation into cardiomyocytes; the same nominal locus in two different tissues can differ 2-3x in expression; a coordinate from one genome build is not the same physical position in another.

EpiLog does two things:

1. **Catalog** — a public, searchable database of known safe harbor loci, built by systematically mining the primary literature (not just relying on review-article summaries) and recording, per record: the exact evidence, a confidence tier reflecting how directly that evidence was extracted, a stability/duration summary, and tissue context — because "safe" is not a fixed property of a coordinate, it's a claim that only holds in a specific tissue, measured a specific way.
2. **Registry** — a shared, editable log where labs can register their own gene-editing loci and check in on silencing status over time (active / partial / silenced), building a real dataset of what actually happens post-edit, not just what the founding papers reported.

Built originally to help find a safe harbor locus in *Canis lupus familiaris* (dog) — a species with essentially no published safe-harbor characterization, which is itself one of the catalog's findings, not a search failure.

## Current coverage

- **Species**: human, mouse, dog, pig, goat, cattle, zebrafish, *Drosophila melanogaster* (and expanding)
- **100+ catalog records**, systematically mined from 300+ papers across two seed review articles plus targeted citation-chasing and species-specific literature searches
- Every record carries: locus name, species, genome build, coordinates (where the source gives them), a confidence tier (high/medium/low, based on whether the data came from direct primary-text reading vs. a secondary review), a stability/duration summary, tissue context, and a linked PubMed source

## Why the data model looks the way it does

A few deliberate choices, and the reasoning behind them:

- **`confidence` is about evidence directness, not about genome-build certainty.** These got conflated once during development and were split apart on purpose — a coordinate can be exactly known while the underlying finding is only secondary-review-derived, or vice versa.
- **`genome_build` is recorded plainly when it's a known fact** (e.g. Drosophila P[acman] docking sites predate the dm6 assembly entirely, so they're dm3 — not hedged as "possibly outdated"), **and left `null` when it's genuinely unknown** rather than guessed. Coordinates from different builds are not interchangeable, so the species/build filter in the UI treats every (species, build) pair as a distinct bucket rather than lumping them together.
- **`tissue_context` exists because safe-harbor status is tissue-dependent** — chromatin accessibility (ATAC) and TAD organization differ by cell type, so the same coordinate can be transcriptionally quiet in one tissue and active (or disruptive to a neighboring gene within the same TAD) in another.
- **Negative/cautionary records are kept, not filtered out** — e.g. attP40 in Drosophila is one of the two most-used phiC31 docking sites in the field, but it sits inside the *msp-300* gene and has documented insertional effects on muscle and olfactory neuron phenotypes. A catalog that only shows success stories isn't useful for actually picking a locus.

## Stack

- Single-file static frontend (`epilog-live.html`) — vanilla JS, no build step, no framework
- [Supabase](https://supabase.com) (Postgres + Row Level Security) as the backend
  - Public-writable tables for the registry (`experiments`, `checkins`)
  - Curation-only staging table (`public_safe_harbors_staging`) with no public policies — new literature findings land here first
  - Public, read-only catalog table (`known_safe_harbors`) — promoted from staging only after review
- Hosted on [Netlify](https://netlify.com)
- Full catalog also exposed as a raw, crawlable JSON feed via the Supabase REST endpoint (linked from the Catalog tab and referenced in the page's `schema.org/Dataset` structured data)

## Data pipeline

1. Seed review articles identified and read in full
2. Citation-chased from those reviews into primary literature, in checkpointed batches, prioritizing papers that report **exact base-pair coordinates and direct expression/silencing data** over ones that only give a cytogenetic band
3. Each finding logged with its confidence tier and exact source PMID before entering the staging table
4. High-confidence, reviewed records auto-promote to the public catalog; medium/low-confidence records stay in staging for manual review
5. Repeated per-species as coverage expands (human/mouse → dog → *Drosophila* → pig/goat/cattle/zebrafish)

## Running it locally

No build step. Fill in `SUPABASE_URL` and `SUPABASE_ANON_KEY` near the top of `index.html`, then open the file or serve it with any static file server.

## Known limitations / roadmap

Being upfront about what's incomplete, rather than hiding it:

- **`tissue_context` is only populated for records added since the field was introduced** (Drosophila and the pig/goat/cattle/dog/mouse multi-species batch). The original ~150 human/mouse records predate the field and are being backfilled retroactively.
- **Dog (*Canis lupus familiaris*) has essentially no published safe-harbor characterization** — confirmed by two independent literature searches, not a gap in this catalog's coverage. This is itself a finding worth stating plainly, not a bug.
- **Genome build is left `null`, not guessed, for several livestock coordinates** (some pig/goat/cattle records) where the source paper's exact reference assembly wasn't confirmed from the text available. Confirm against the current species assembly before using these for real design work.
- **No automated re-validation against updated genome assemblies.** Coordinates are recorded as reported in the source paper; a dm3→dm6 (or GRCh37→GRCh38) liftover pass is future work, not done automatically.
- **Confidence tiers are a proxy for evidence directness, not a statistical measure.** "High" means the coordinate/finding was read directly from primary-source full text; it is not a calibrated probability.

## License / terms

The source code in this repository (frontend + SQL migrations) is MIT-licensed — see [`LICENSE`](LICENSE).

The catalog and registry **data** served by the live application is a separately maintained compilation with its own usage terms: extraction, redistribution, or substantial reuse outside the platform requires prior written permission from the maintainer — see the terms shown on first visit to the live site.

## Citation

If you use EpiLog in your work, please cite via the archived release: [10.5281/zenodo.21996604](https://doi.org/10.5281/zenodo.21996604) (see [`CITATION.cff`](CITATION.cff)).

## Author

Manuel Afonso de Paiva Menezes de Sequeira — biochemistry student, FCT/UNL. Built independently, not affiliated with any institution.
