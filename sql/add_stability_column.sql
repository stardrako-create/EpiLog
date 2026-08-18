-- Run this FIRST, once, before any of the translate_batch_*.sql files.
alter table known_safe_harbors add column if not exists stability text;
alter table public_safe_harbors_staging add column if not exists stability text;
