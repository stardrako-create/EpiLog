-- Computationally-predicted canine safe harbor candidates from the
-- SafeHarborCanine pipeline (Manuel Sequeira, same author as this catalog).
-- Source: github.com/stardrako-create/SafeHarborCanine, DOI 10.5281/zenodo.21996453
--
-- These are NOT experimentally validated -- they passed a SHIP (Safe Harbor
-- Integration Prioritization) computational screen: intergenic convergent-gene
-- intervals (50-75kb) on ROS_Cfam_1.0, filtered against hard vetoes (Hi-C TAD
-- boundary overlap, ATAC consensus peak overlap; 461 raw -> 280 passing), then
-- ranked on 5 normalized components (ATAC stability, methylation stability,
-- CpG methylation level, TAD distance, accessibility pattern).
-- confidence = 'untested' throughout -- do not conflate with the high/medium/
-- low literature-confidence tiers used elsewhere in this catalog; those mean
-- "how directly does published evidence support this", which does not apply
-- here yet.
--
-- Run add_computational_candidate_columns.sql BEFORE this file.

insert into known_safe_harbors
  (species, genome_build, coords, locus_name, evidence_summary, confidence,
   source_doi, source_title, evidence_type, computational_score)
values

-- #1: the flagship entry -- independently cross-validated. A completely
-- different method (Ehsan Valiollahi's human-regulatory-element liftover,
-- 27 final candidates) also picked this exact locus as a top hit. Two
-- unrelated filtering strategies converging on the same site is the
-- strongest evidence in this batch, even without wet-lab validation.
('Dog', 'ROS_Cfam_1.0', 'chr8:52,431-118,675',
 'Canine SHIP-01 (chr8, convergent LOC119872972/LOC119872973)',
 'Top-ranked SHIP candidate (score 0.83/1.0) from ATAC-seq (n=71 dogs, PBMC) + RRBS methylation (n=71) + Hi-C (single dog, blood) integration. Passes hard vetoes against Hi-C TAD boundaries and ATAC consensus peaks. Flanking genes are both uncharacterized predicted loci (LOC119872972, LOC119872973), convergently oriented. Independently cross-validated: also appears in an unrelated human-regulatory-element-liftover-based candidate list (27 final candidates, Ehsan Valiollahi), despite using a completely different filtering strategy -- agreement between two independent methods not sharing a common assumption is stronger evidence than either method alone. Not experimentally tested.',
 'untested', 'https://github.com/stardrako-create/SafeHarborCanine', 'SafeHarborCanine v0.1.0 (Sequeira, unpublished pipeline output) - DOI 10.5281/zenodo.21996453', 'computational', 0.8323),

('Dog', 'ROS_Cfam_1.0', 'chr13:42,409,351-42,467,972',
 'Canine SHIP-02 (chr13, convergent LOC119865519/LOC119865447)',
 'SHIP candidate, score 0.75/1.0. Both flanking genes are uncharacterized predicted loci. Passes hard vetoes (Hi-C TAD boundary, ATAC consensus peak); not independently cross-validated. Not experimentally tested.',
 'untested', 'https://github.com/stardrako-create/SafeHarborCanine', 'SafeHarborCanine v0.1.0 (Sequeira, unpublished pipeline output) - DOI 10.5281/zenodo.21996453', 'computational', 0.749),

('Dog', 'ROS_Cfam_1.0', 'chr12:2,021,125-2,084,815',
 'Canine SHIP-03 (chr12, convergent LOC119881685/TSBP1)',
 'SHIP candidate, score 0.72/1.0. One flanking gene is named (TSBP1, testis-expressed basic protein 1); the other is an uncharacterized predicted locus. Passes hard vetoes; not independently cross-validated. Not experimentally tested.',
 'untested', 'https://github.com/stardrako-create/SafeHarborCanine', 'SafeHarborCanine v0.1.0 (Sequeira, unpublished pipeline output) - DOI 10.5281/zenodo.21996453', 'computational', 0.7182),

('Dog', 'ROS_Cfam_1.0', 'chr4:77,033,647-77,089,414',
 'Canine SHIP-04 (chr4, convergent TMEM125/LOC102156164)',
 'SHIP candidate, score 0.72/1.0. One flanking gene is named (TMEM125, transmembrane protein 125); the other is an uncharacterized predicted locus. Passes hard vetoes; not independently cross-validated. Not experimentally tested.',
 'untested', 'https://github.com/stardrako-create/SafeHarborCanine', 'SafeHarborCanine v0.1.0 (Sequeira, unpublished pipeline output) - DOI 10.5281/zenodo.21996453', 'computational', 0.7158),

('Dog', 'ROS_Cfam_1.0', 'chr8:21,931,015-21,992,476',
 'Canine SHIP-05 (chr8, convergent LOC100684096/LOC119872816)',
 'SHIP candidate, score 0.70/1.0. Both flanking genes are uncharacterized predicted loci. Passes hard vetoes; not independently cross-validated. Not experimentally tested.',
 'untested', 'https://github.com/stardrako-create/SafeHarborCanine', 'SafeHarborCanine v0.1.0 (Sequeira, unpublished pipeline output) - DOI 10.5281/zenodo.21996453', 'computational', 0.7027),

('Dog', 'ROS_Cfam_1.0', 'chr35:18,052,245-18,123,443',
 'Canine SHIP-06 (chr35, convergent LOC111093969/LOC102156827)',
 'SHIP candidate, score 0.70/1.0. Both flanking genes are uncharacterized predicted loci. Passes hard vetoes; not independently cross-validated. Not experimentally tested.',
 'untested', 'https://github.com/stardrako-create/SafeHarborCanine', 'SafeHarborCanine v0.1.0 (Sequeira, unpublished pipeline output) - DOI 10.5281/zenodo.21996453', 'computational', 0.7003),

('Dog', 'ROS_Cfam_1.0', 'chr7:48,020,921-48,077,046',
 'Canine SHIP-07 (chr7, convergent RIT2/LOC119872716)',
 'SHIP candidate, score 0.70/1.0. One flanking gene is named (RIT2, Ras-like without CAAX 2 -- expressed mainly in neurons, worth noting for tissue-context caution); the other is an uncharacterized predicted locus. Passes hard vetoes; not independently cross-validated. Not experimentally tested.',
 'untested', 'https://github.com/stardrako-create/SafeHarborCanine', 'SafeHarborCanine v0.1.0 (Sequeira, unpublished pipeline output) - DOI 10.5281/zenodo.21996453', 'computational', 0.6973),

('Dog', 'ROS_Cfam_1.0', 'chr1:84,616,059-84,680,359',
 'Canine SHIP-08 (chr1, convergent LOC119869841/LOC100686852)',
 'SHIP candidate, score 0.70/1.0. Both flanking genes are uncharacterized predicted loci. Passes hard vetoes; not independently cross-validated. Not experimentally tested.',
 'untested', 'https://github.com/stardrako-create/SafeHarborCanine', 'SafeHarborCanine v0.1.0 (Sequeira, unpublished pipeline output) - DOI 10.5281/zenodo.21996453', 'computational', 0.6968),

('Dog', 'ROS_Cfam_1.0', 'chr4:1,943,254-2,003,893',
 'Canine SHIP-09 (chr4, convergent LOC102151881/LOC111095689)',
 'SHIP candidate, score 0.69/1.0. Both flanking genes are uncharacterized predicted loci. Passes hard vetoes; not independently cross-validated. Not experimentally tested.',
 'untested', 'https://github.com/stardrako-create/SafeHarborCanine', 'SafeHarborCanine v0.1.0 (Sequeira, unpublished pipeline output) - DOI 10.5281/zenodo.21996453', 'computational', 0.6892),

('Dog', 'ROS_Cfam_1.0', 'chr21:51,990,876-52,054,339',
 'Canine SHIP-10 (chr21, convergent LOC119864909/LOC119864867)',
 'SHIP candidate, score 0.69/1.0. Both flanking genes are uncharacterized predicted loci. Passes hard vetoes; not independently cross-validated. Not experimentally tested.',
 'untested', 'https://github.com/stardrako-create/SafeHarborCanine', 'SafeHarborCanine v0.1.0 (Sequeira, unpublished pipeline output) - DOI 10.5281/zenodo.21996453', 'computational', 0.6891),

('Dog', 'ROS_Cfam_1.0', 'chr31:23,436,373-23,508,916',
 'Canine SHIP-11 (chr31, convergent LOC111093569/LOC119867012)',
 'SHIP candidate, score 0.69/1.0. Both flanking genes are uncharacterized predicted loci. Passes hard vetoes; not independently cross-validated. Not experimentally tested.',
 'untested', 'https://github.com/stardrako-create/SafeHarborCanine', 'SafeHarborCanine v0.1.0 (Sequeira, unpublished pipeline output) - DOI 10.5281/zenodo.21996453', 'computational', 0.6858),

('Dog', 'ROS_Cfam_1.0', 'chr1:7,072,137-7,132,579',
 'Canine SHIP-12 (chr1, convergent LOC111090579/LOC100685067)',
 'SHIP candidate, score 0.69/1.0. Both flanking genes are uncharacterized predicted loci. Passes hard vetoes; not independently cross-validated. Not experimentally tested.',
 'untested', 'https://github.com/stardrako-create/SafeHarborCanine', 'SafeHarborCanine v0.1.0 (Sequeira, unpublished pipeline output) - DOI 10.5281/zenodo.21996453', 'computational', 0.6854),

-- Legacy candidate: originally identified on the older UU_Cfam_GSD_1.0
-- assembly (NC_049233.1:72,350,025-72,351,060), lifted over to ROS_Cfam_1.0
-- with high-confidence alignment (MAPQ 60, 2 mismatches). Does NOT appear in
-- the 461-candidate SHIP pool (~370kb from the nearest SHIP interval) --
-- included separately because it passes both hard vetoes and has favorable
-- methylation (2.4%), but flagged explicitly for its anomalously high
-- accessibility (0.214 vs the typical 0.04-0.11 SHIP-candidate range), which
-- may indicate an unannotated regulatory element nearby. No computational_score
-- assigned since it wasn't produced by the same scoring pass as the others.
('Dog', 'ROS_Cfam_1.0', 'chr12:72,767,426-72,768,461',
 'Canine legacy candidate (chr12, lifted over from UU_Cfam_GSD_1.0)',
 'Originally identified on the UU_Cfam_GSD_1.0 assembly (NC_049233.1:72,350,025-72,351,060), lifted over to ROS_Cfam_1.0 with high-confidence alignment (MAPQ 60, 2 mismatches out of 1036bp). Does not overlap the 461-candidate SHIP pool (nearest SHIP interval is ~370kb away). Passes both hard vetoes (Hi-C TAD boundary, ATAC consensus peak) and shows favorable methylation (2.4%). CAUTION: accessibility is anomalously elevated (0.214) versus the typical SHIP-candidate range (0.04-0.11), which may indicate proximity to an unannotated regulatory element -- treat as lower confidence than the ranked SHIP candidates above until this is resolved. Not experimentally tested.',
 'untested', 'https://github.com/stardrako-create/SafeHarborCanine', 'SafeHarborCanine v0.1.0 (Sequeira, unpublished pipeline output) - DOI 10.5281/zenodo.21996453', 'computational', null);
