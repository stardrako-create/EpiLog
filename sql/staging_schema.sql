-- Tabela de staging para o catálogo público de safe harbors extraído de literatura.
-- Separada de `experiments`/`checkins` de propósito: esta NÃO é publicamente escrevível.
-- Só sai daqui para uma tabela pública depois de revisão humana (reviewed + approved = true).

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
-- Sem políticas públicas de propósito — só acesso via service key (usada pelo script), nunca pela anon key do site.

-- Tabela de destino final, só para referência (criar quando tiveres o primeiro lote validado):
--
-- create table known_safe_harbors (
--   id uuid primary key default gen_random_uuid(),
--   species text not null,
--   genome_build text not null,
--   coords text not null,
--   locus_name text,
--   evidence_summary text,
--   source_doi text,
--   source_pmid text,
--   promoted_at timestamptz default now()
-- );
-- alter table known_safe_harbors enable row level security;
-- create policy "public select" on known_safe_harbors for select using (true);
-- (sem policy de insert pública — só promovido manualmente do staging)
