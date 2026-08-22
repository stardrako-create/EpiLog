-- Wires actual spending into lookup_locus_aggregate -- until now it was
-- callable free/unlimited by any authenticated user. Same signature, so
-- create or replace swaps it in place with no migration needed elsewhere.
--
-- Behavior: 1 credit per lookup, charged only on a successful (non-empty)
-- result -- a query that returns nothing (below n=3, or no data for that
-- locus/cell_model at all) doesn't cost anything, so browsing around
-- looking for a hit isn't itself expensive. Raises an exception with a
-- clear message when balance is 0, rather than silently returning empty
-- (which would look identical to "no data exists" -- a real UX difference
-- the frontend needs to distinguish and show differently).
create or replace function lookup_locus_aggregate(p_coords text, p_cell_model text)
returns table(n bigint, silenced_within_8w bigint)
security definer
set search_path = public
language plpgsql
as $$
declare
  balance bigint;
  result record;
begin
  select coalesce(sum(amount), 0) into balance
  from credit_ledger where user_id = auth.uid();

  if balance <= 0 then
    raise exception 'no_credits' using detail = 'Log a fully-filled-out experiment with a follow-up check-in to earn a lookup credit.';
  end if;

  select agg.n, agg.silenced_within_8w into result
  from (
    with eligible as (
      select e.id
      from experiments e
      join profiles p on p.id = e.user_id
      where e.coords = p_coords
        and e.cell_model = p_cell_model
        and e.aggregate_visible_at <= now()
        and p.allow_aggregate_use = true
    ),
    latest_state as (
      select c.experiment_id,
             c.state,
             c.day,
             row_number() over (partition by c.experiment_id order by c.day desc) as rn
      from checkins c
      join eligible el on el.id = c.experiment_id
    )
    select
      count(distinct experiment_id) as n,
      count(distinct experiment_id) filter (
        where state = 'silenced' and day <= 56
      ) as silenced_within_8w
    from latest_state
    where rn = 1
    having count(distinct experiment_id) >= 3
  ) agg;

  if result.n is null then
    return;
  end if;

  insert into credit_ledger (user_id, experiment_id, amount, reason)
  values (auth.uid(), null, -1, 'lookup_spent');

  return query select result.n, result.silenced_within_8w;
end;
$$;

revoke all on function lookup_locus_aggregate(text, text) from public;
grant execute on function lookup_locus_aggregate(text, text) to authenticated;
