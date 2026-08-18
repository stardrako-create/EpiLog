-- Promotes the Drosophila high-confidence records (3 flagship attP sites +
-- 31 of the 32 VK sites, everything except heterochromatic VK00029) into the
-- public catalog. Scoped narrowly by source_pmid on purpose -- known_safe_harbors
-- has no unique constraint, so re-running the OLD promote_to_catalog.sql's
-- blanket "where reviewed = true and confidence = 'high'" would duplicate the
-- 90 rows already promoted. Do NOT re-run that old script; use this one.

update public_safe_harbors_staging
set approved = true
where reviewed = true and confidence = 'high'
  and source_pmid in ('17360644', '17008526');

insert into known_safe_harbors
  (species, genome_build, coords, locus_name, evidence_summary, confidence, stability, tissue_context, source_pmid, source_title)
select species, genome_build, coords, locus_name, evidence_summary, confidence, stability, tissue_context, source_pmid, source_title
from public_safe_harbors_staging
where approved = true and source_pmid in ('17360644', '17008526');

-- VK00029 (heterochromatic, low confidence) and ZH-51C/ZH-51D (medium
-- confidence, secondary source) stay in staging for manual review, same as the
-- human BLD_GSH/BRN_GSH computational candidates. Promote individually when ready:
-- update public_safe_harbors_staging set approved = true where id = '...';
-- insert into known_safe_harbors (...) select ... from public_safe_harbors_staging where id = '...';
