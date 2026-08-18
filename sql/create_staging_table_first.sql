create table public_safe_harbors_staging (
  id uuid primary key default gen_random_uuid(),
  species text,
  genome_build text,
  coords text,
  locus_name text,
  evidence_summary text,
  confidence text check (confidence in ('high', 'medium', 'low')),
  source_doi text,
  source_pmid text,
  source_title text,
  reviewed boolean default false,
  approved boolean default false,
  extracted_at timestamptz default now()
);

alter table public_safe_harbors_staging enable row level security;
-- Sem politicas publicas de proposito -- so acesso via SQL Editor/service key.
