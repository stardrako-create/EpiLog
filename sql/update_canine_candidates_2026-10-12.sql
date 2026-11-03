-- Replaces the superseded canine computational candidates (the V9-B "Canine safe-harbor
-- shortlist #1-5", scores 0.739-0.765, and the earlier SHIP-01..13 rows) with the outcome of
-- the final computational review of 12 October 2026 (Safe Harbor Canino).
--
-- Source: github.com/stardrako-create/SafeHarborCanine, tag audit-2026-10-12,
-- 08_CANDIDATE_CLOSURE_AUDIT/FINAL_RESULTS_20261012.md. Zenodo concept DOI 10.5281/zenodo.21996452
-- (always resolves to the latest archived snapshot).
--
-- Both rows are computational candidates: nothing here is validated for integration, expression
-- or function, and no guide RNAs are claimed. confidence = 'untested' as for every computational
-- record. w11 is deliberately not listed (not advanced: structural context unresolved).
-- computational_score stays null: the old SHIP score ranked 50-75 kb regions and does not
-- describe these 1-kb windows.
--
-- Run in the Supabase SQL editor, in this order. Step 1 is destructive for the rows it matches;
-- the select before it shows what will be removed.

-- 0. What is there now (keep a copy of this output).
select id, locus_name, coords, computational_score, source_doi
from known_safe_harbors
where evidence_type = 'computational' and species in ('Dog', 'Canis lupus familiaris')
order by locus_name;

-- 1. Remove the superseded computational canine rows.
delete from known_safe_harbors
where evidence_type = 'computational' and species in ('Dog', 'Canis lupus familiaris');

-- 2. Insert the two current candidates.
insert into known_safe_harbors
  (species, genome_build, coords, locus_name, evidence_summary, confidence,
   source_doi, source_title, evidence_type, computational_score)
values
('Dog', 'ROS_Cfam_1.0', 'NC_051811.1:17255706-17256706',
 'Canine w01 (NC_051811.1, LOC119876429/LOC119872513 region)',
 'First-priority computational candidate for testing: a 1-kb window (BED, 0-based, end-exclusive) inside a 56.8-kb convergent SHIP region between LOC119876429 and LOC119872513. No annotated repeats in the window, exact ROS/UU correspondence, no hit in the queried structural-variant catalogue. Blood ATAC percentile 63.75 against matched windows; direct T-cell accessibility support is sparse. RRBS observes 20% of the window (mean methylation 60.71%), so low methylation is not demonstrated. The nearest annotated non-coding RNA 5-prime end is 32,785 bp away. Computational candidate only: not experimentally validated for integration, expression or function, and no guide RNAs are claimed.',
 'untested', 'https://doi.org/10.5281/zenodo.21996452',
 'Safe Harbor Canino: computational audit snapshot of 12 October 2026 (Paiva Sequeira, Valiollahi, Barreto), Zenodo concept DOI 10.5281/zenodo.21996452',
 'computational', null),

('Dog', 'ROS_Cfam_1.0', 'NC_051831.1:39708074-39709074',
 'Canine ANO2-39708 (NC_051831.1, ANO2/NTF3 region)',
 'Additional provisional computational candidate: a 1-kb window (BED, 0-based, end-exclusive) in the broad ANO2/NTF3 SHIP region (previously listed as reserve w03), distinct from w01 and w11. Accessibility percentiles: full 62,427-bp SHIP region 72.70, 20-kb neighbourhood 65.97 (the local 1-kb value, 90.37, is a separate diagnostic). No repeat or regulatory overlap in the queried window sources; curated maximum 50-bp mean phyloP 1.55 (below the 6.5 threshold). Two exploratory 23-nt TTTV profiles had no off-locus matches in full ROS and UU searches under the documented substitution, single-bulge and PAM model; they are not approved guides. RRBS covers 15% of the window (mean 48.73%), so whole-window hypomethylation is not shown. Of 2,654 frozen risk-gene symbols, 2,601 were placed in ROS or UU and 53 remain unresolved. Computational candidate only: not experimentally validated for integration, expression or function.',
 'untested', 'https://doi.org/10.5281/zenodo.21996452',
 'Safe Harbor Canino: computational audit snapshot of 12 October 2026 (Paiva Sequeira, Valiollahi, Barreto), Zenodo concept DOI 10.5281/zenodo.21996452',
 'computational', null);

-- 3. Check: exactly two rows, species 'Dog', DOI stored as a full URL.
select id, locus_name, coords, evidence_type, confidence, source_doi
from known_safe_harbors
where evidence_type = 'computational' and species = 'Dog'
order by locus_name;
-- Expected: 2 rows (w01, ANO2-39708).
