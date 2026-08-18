-- Translate species values from Portuguese to English, in both tables
-- (staging, so future promotions stay consistent, and the public catalog already promoted).

update known_safe_harbors set species = 'Human' where species = 'Humano';
update known_safe_harbors set species = 'Mouse' where species = 'Ratinho';
update known_safe_harbors set species = 'Dog' where species = 'Cão';
update known_safe_harbors set species = 'Rat' where species = 'Rato';
update known_safe_harbors set species = 'Pig' where species = 'Porco';
update known_safe_harbors set species = 'Zebrafish' where species = 'Peixe-zebra';

update public_safe_harbors_staging set species = 'Human' where species = 'Humano';
update public_safe_harbors_staging set species = 'Mouse' where species = 'Ratinho';
update public_safe_harbors_staging set species = 'Dog' where species = 'Cão';
update public_safe_harbors_staging set species = 'Rat' where species = 'Rato';
update public_safe_harbors_staging set species = 'Pig' where species = 'Porco';
update public_safe_harbors_staging set species = 'Zebrafish' where species = 'Peixe-zebra';

-- Check what's left, in case there's a species value not covered above:
select distinct species from known_safe_harbors order by species;
