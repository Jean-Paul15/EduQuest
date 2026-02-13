create table if not exists monthly_reward_policies (
  period_key text primary key,
  enabled boolean not null default false,
  reward_note text,
  min_score int not null default 40,
  updated_at timestamptz not null default now()
);

create table if not exists monthly_reward_results (
  period_key text not null,
  profile_id uuid not null references profiles(id),
  score int not null,
  rank int not null,
  reward_granted boolean not null default false,
  reward_note text,
  generated_at timestamptz not null default now(),
  primary key(period_key, profile_id)
);

alter table monthly_reward_policies enable row level security;
alter table monthly_reward_results enable row level security;
drop policy if exists monthly_reward_policies_read_all on monthly_reward_policies;
create policy monthly_reward_policies_read_all on monthly_reward_policies for select using (auth.uid() is not null);
drop policy if exists monthly_reward_results_read_all on monthly_reward_results;
create policy monthly_reward_results_read_all on monthly_reward_results for select using (auth.uid() is not null);

create or replace function build_monthly_reward_results(p_period_key text default to_char(current_date, 'YYYY-MM'))
returns jsonb language plpgsql security definer
as $$
declare v_enabled boolean := false; v_note text; v_min int := 40; v_rows jsonb := '[]'::jsonb;
begin
  insert into monthly_reward_policies(period_key, enabled) values(p_period_key, false) on conflict do nothing;
  select enabled, reward_note, min_score into v_enabled, v_note, v_min from monthly_reward_policies where period_key = p_period_key;
  with month_events as (
    select profile_id, event_name from app_events where to_char(event_time, 'YYYY-MM') = p_period_key
  ), scored as (
    select profile_id, sum(case when event_name in ('quiz_submitted','daily_checkin_claimed') then 3 else 1 end)::int as score
    from month_events where profile_id is not null group by profile_id
  ), ranked as (
    select profile_id, score, row_number() over(order by score desc, profile_id) as rank from scored where score >= v_min
  )
  insert into monthly_reward_results(period_key, profile_id, score, rank, reward_granted, reward_note, generated_at)
  select p_period_key, profile_id, score, rank, v_enabled, case when v_enabled then v_note else null end, now() from ranked
  on conflict (period_key, profile_id) do update
  set score = excluded.score, rank = excluded.rank, reward_granted = excluded.reward_granted, reward_note = excluded.reward_note, generated_at = excluded.generated_at;
  select coalesce(jsonb_agg(jsonb_build_object('profile_id', profile_id, 'score', score, 'rank', rank, 'reward', reward_granted)), '[]'::jsonb)
  into v_rows from monthly_reward_results where period_key = p_period_key order by rank;
  return v_rows;
end; $$;

revoke all on function build_monthly_reward_results(text) from public;
grant execute on function build_monthly_reward_results(text) to authenticated;

