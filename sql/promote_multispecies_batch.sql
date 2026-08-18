-- Promotes the new dog/mouse/pig/goat/cattle records (all high confidence,
-- all reviewed = true). Scoped by source_pmid, same reasoning as the
-- Drosophila promote script -- do NOT use the old blanket promote_to_catalog.sql.

update public_safe_harbors_staging
set approved = true
where reviewed = true and confidence = 'high'
  and source_pmid in ('42554239', '38897206', '26381350', '40879839', '29991797');

insert into known_safe_harbors
  (species, genome_build, coords, locus_name, evidence_summary, confidence, stability, tissue_context, source_pmid, source_title)
select species, genome_build, coords, locus_name, evidence_summary, confidence, stability, tissue_context, source_pmid, source_title
from public_safe_harbors_staging
where approved = true
  and source_pmid in ('42554239', '38897206', '26381350', '40879839', '29991797');
