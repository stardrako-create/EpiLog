-- Drosophila batch 2 -- two additional named ZH-series sites. Only cytological
-- bands are known (51C1, 51D9), no bp coordinates, so genome_build is left
-- null (bands are assembly-independent). Confidence stays medium -- identity
-- confirmed via BDSC stock listing, not read directly from a primary paper's
-- methods/results text. This is unrelated to the dm3/dm6 question.

insert into public_safe_harbors_staging
  (species, genome_build, coords, locus_name, evidence_summary, confidence, stability, tissue_context, source_pmid, source_title, reviewed, approved)
values

('Drosophila', null, null, 'ZH-51C',
 'Cytological location 51C1, chromosome 2R (Bloomington Drosophila Stock Center #24482). Part of the Zurich (Basler lab) ZH-attP series of phiC31 docking sites. Location/identity confirmed via BDSC stock listing, not read directly from a primary paper''s methods/results text -- confidence kept at medium pending direct full-text confirmation.',
 'medium', 'Standard reusable ZH-series docking site; no silencing/methylation benchmark available in the sources checked', 'Whole organism / germline (fly transgenesis; not tissue-restricted).', '17360644', 'An optimized transgenesis system for Drosophila using germ-line-specific phiC31 integrases (ZH-series docking site catalog)', true, false),

('Drosophila', null, null, 'ZH-51D',
 'Cytological location 51D9, chromosome 2R (Bloomington Drosophila Stock Center #24483). Part of the Zurich (Basler lab) ZH-attP series of phiC31 docking sites, adjacent to ZH-51C. Location/identity confirmed via BDSC stock listing, not read directly from a primary paper''s methods/results text -- confidence kept at medium pending direct full-text confirmation.',
 'medium', 'Standard reusable ZH-series docking site; no silencing/methylation benchmark available in the sources checked', 'Whole organism / germline (fly transgenesis; not tissue-restricted).', '17360644', 'An optimized transgenesis system for Drosophila using germ-line-specific phiC31 integrases (ZH-series docking site catalog)', true, false);
