-- PASSO 1: cria a tabela pública (só de leitura para todos, sem escrita pública)
create table known_safe_harbors (
  id uuid primary key default gen_random_uuid(),
  species text not null,
  genome_build text,
  coords text,
  locus_name text not null,
  evidence_summary text,
  confidence text,
  source_pmid text,
  source_title text,
  promoted_at timestamptz default now()
);
alter table known_safe_harbors enable row level security;
create policy "public select" on known_safe_harbors for select using (true);
-- sem policy de insert publica -- so entra por esta promocao manual, nunca pelo site

-- PASSO 2: corre isto SO DEPOIS de teres colado os 24 ficheiros de staging.
-- Aprova automaticamente tudo o que ficou "high" e ja foi revisto -- e o criterio
-- que ja tinhamos combinado (high confidence + citacao direta = auto-promovivel).
update public_safe_harbors_staging
set approved = true
where reviewed = true and confidence = 'high';

-- PASSO 3: promove os aprovados para a tabela publica.
insert into known_safe_harbors (species, genome_build, coords, locus_name, evidence_summary, confidence, source_pmid, source_title)
select species, genome_build, coords, locus_name, evidence_summary, confidence, source_pmid, source_title
from public_safe_harbors_staging
where approved = true;

-- Os "medium" e "low" ficam em staging, por reveres tu a olho antes de decidires
-- promove-los -- corre isto quando quiseres, registo a registo ou em bloco:
-- update public_safe_harbors_staging set approved = true where id = '...';
-- (depois repete o INSERT do passo 3 para apanhar os novos aprovados)
