-- Explicit, opt-in (never pre-checked) consent per account: can LocusAtlas use
-- anonymized, aggregate statistics from this account's data to validate/
-- improve the prediction model and demonstrate it to funders/industry
-- partners? This is separate from and does NOT affect row-level privacy --
-- individual entries stay private regardless of this setting; it only ever
-- governs aggregate/statistical use (e.g. "N of M candidates validated"),
-- never raw entries, never locus-level detail, never identity.

alter table profiles add column if not exists allow_aggregate_use boolean not null default false;

-- RLS on profiles already restricts each account to seeing/editing only its
-- own row (add_registry_auth.sql) -- this column inherits that automatically,
-- no new policy needed.
