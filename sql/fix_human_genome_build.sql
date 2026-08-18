-- Sets genome_build = 'GRCh38' plainly (not a hedge) for the human records that
-- actually carry bp coordinates. Both source papers state their coordinates
-- explicitly as GRCh38/hg38 in their methods (PMID 38164941: coordinates lifted
-- over from hg19 to hg38; PMID 36131352: GRCh38/hg38 throughout, confirmed via
-- Ensembl Release 103 / COSMIC v92 references). Every other human record in the
-- catalog only has a cytogenetic band (coords = null), so genome_build stays
-- null for those -- a band doesn't need an assembly the way a bp coordinate does.

update known_safe_harbors
set genome_build = 'GRCh38'
where source_pmid in ('38164941', '36131352') and coords is not null;

update public_safe_harbors_staging
set genome_build = 'GRCh38'
where source_pmid in ('38164941', '36131352') and coords is not null;

-- Check what's left with coords but no build, across the whole catalog --
-- should be empty after the above, or only species-genome pairs that
-- genuinely have no known build:
select species, locus_name, coords, genome_build, source_pmid
from known_safe_harbors
where coords is not null and genome_build is null;
