-- Wipes and lets you cleanly re-insert the Drosophila batch, instead of trying
-- to guess which duplicate rows are "old" vs "corrected" versions (the two
-- versions have different evidence_summary text for the VK sites, so a simple
-- text-based de-dup would miss cross-version duplicates).
--
-- Safe to run even if there are 1, 2, or 3 copies of each row -- this clears
-- all of them for these two source papers specifically, nothing else is touched.

delete from known_safe_harbors where source_pmid in ('17360644', '17008526');
delete from public_safe_harbors_staging where source_pmid in ('17360644', '17008526');

-- Confirm it's actually empty before re-inserting:
select count(*) from known_safe_harbors where source_pmid in ('17360644', '17008526');
select count(*) from public_safe_harbors_staging where source_pmid in ('17360644', '17008526');
-- Both should return 0.

-- After confirming 0/0, re-run in order (use the CORRECTED versions I sent most
-- recently, not any earlier copies you may still have open in other tabs):
--   1. staging_insert_drosophila_batch1.sql
--   2. staging_insert_drosophila_batch2.sql
--   3. promote_drosophila_batch.sql
