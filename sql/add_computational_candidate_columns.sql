-- Adds support for computationally-predicted (not yet experimentally validated)
-- safe harbor candidates, distinct from the literature-confirmed entries that
-- make up the rest of the catalog. Two changes:
--   1. source_doi: known_safe_harbors never got this column even though the
--      staging table has always had it -- needed now because these candidates
--      cite a Zenodo DOI, not a PMID.
--   2. evidence_type + computational_score: a SHIP prioritization score is a
--      different kind of number than the existing `confidence` tier (which
--      means "how directly does published literature support this locus").
--      Keeping them as separate columns avoids conflating "well-cited" with
--      "well-scored by an unpublished pipeline".

alter table known_safe_harbors add column if not exists source_doi text;
alter table known_safe_harbors add column if not exists evidence_type text default 'literature';
alter table known_safe_harbors add column if not exists computational_score numeric;

-- Backfill existing rows explicitly (the default only applies to new rows in
-- some Postgres versions when the column is added without a value already
-- present -- this makes it explicit and safe to re-run).
update known_safe_harbors set evidence_type = 'literature' where evidence_type is null;
