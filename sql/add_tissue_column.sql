-- Run once, before any tissue_context backfill scripts.
-- Rationale: a locus's safe-harbor behavior is tissue/cell-type dependent
-- (chromatin accessibility / ATAC signal and TAD boundaries differ by cell type),
-- so "safe in iPSCs" and "safe in cardiomyocytes" are different claims about the
-- same coordinate. This field records which tissue(s)/cell type(s) the evidence
-- for a given record actually comes from.
alter table known_safe_harbors add column if not exists tissue_context text;
alter table public_safe_harbors_staging add column if not exists tissue_context text;
