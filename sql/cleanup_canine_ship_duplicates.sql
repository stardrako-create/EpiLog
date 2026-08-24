-- insert_canine_ship_candidates.sql got run twice (once before source_doi was
-- fixed to point at GitHub instead of the DOI, once after) -- 26 rows instead
-- of 13, same locus_name/computational_score, differing only in source_doi.
-- Same fix as cleanup_drosophila_duplicates.sql: wipe everything from this
-- batch and cleanly re-insert once, rather than guessing which half to keep.

-- Note: the original insert used species = 'Canis lupus familiaris' directly,
-- inconsistent with the rest of the catalog's convention (common names like
-- 'Dog', 'Human', 'Mouse' -- see SPECIES_SCIENTIFIC in index.html,
-- which translates those for display). Matching on the actual stored value
-- here; the corrected insert file below now uses 'Dog' for consistency.
delete from known_safe_harbors where evidence_type = 'computational' and species = 'Canis lupus familiaris';

-- Confirm it's actually empty before re-inserting:
select count(*) from known_safe_harbors where evidence_type = 'computational' and species in ('Canis lupus familiaris', 'Dog');
-- Should return 0.

-- After confirming 0, re-run the UPDATED insert_canine_ship_candidates.sql
-- (species is now 'Dog', matching catalog convention) ONCE.
