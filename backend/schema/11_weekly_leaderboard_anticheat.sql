create table if not exists anti_cheat_rules (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  value_int int not null,
  active boolean not null default true
);

create table if not exists weekly_leaderboards (
  period_key text not null,
  scope text not null default 'GLOBAL',
  ranking jsonb not null default '[]'::jsonb,
  generated_at timestamptz not null default now(),
  primary key(period_key, scope)
);

alter table weekly_leaderboards enable row level security;
drop policy if exists weekly_leaderboards_read_all on weekly_leaderboards;
create policy weekly_leaderboards_read_all
on weekly_leaderboards for select
using (auth.uid() is not null);

insert into anti_cheat_rules(code, value_int, active) values
('min_activity_events', 8, true),
('max_events_per_day', 250, true)
on conflict (code) do update set value_int = excluded.value_int, active = excluded.active;

create or replace function build_weekly_leaderboard(p_period_key text default to_char(current_date, 'IYYY-IW'))
returns jsonb language plpgsql security definer
as $$
declare v_min int := 8; v_max_day int := 250; v_rank jsonb := '[]'::jsonb;
begin
  select value_int into v_min from anti_cheat_rules where code = 'min_activity_events' and active = true limit 1;
  select value_int into v_max_day from anti_cheat_rules where code = 'max_events_per_day' and active = true limit 1;
  with week_events as (
    select profile_id, event_name, event_time::date as d from app_events where to_char(event_time, 'IYYY-IW') = p_period_key
  ), abnormal as (
    select distinct profile_id from week_events group by profile_id, d having count(*) > v_max_day
  ), scored as (
    select profile_id, count(*) as activity_count,
      sum(case when event_name in ('quiz_submitted','daily_checkin_claimed') then 3 else 1 end) as score
    from week_events where profile_id is not null and profile_id not in (select profile_id from abnormal)
    group by profile_id having count(*) >= v_min
  ), ranked as (select profile_id, score, row_number() over(order by score desc, profile_id) as rank from scored)
  select coalesce(jsonb_agg(jsonb_build_object('profile_id', profile_id, 'score', score, 'rank', rank) order by rank), '[]'::jsonb)
  into v_rank from ranked;
  insert into weekly_leaderboards(period_key, scope, ranking, generated_at)
  values (p_period_key, 'GLOBAL', v_rank, now())
  on conflict (period_key, scope) do update set ranking = excluded.ranking, generated_at = excluded.generated_at;
  return v_rank;
end; $$;

revoke all on function build_weekly_leaderboard(text) from public;
grant execute on function build_weekly_leaderboard(text) to authenticated;

