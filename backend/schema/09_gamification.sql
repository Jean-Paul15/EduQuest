create table if not exists gamification_profiles (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles(id),
  xp int not null default 0,
  level int not null default 1,
  streak_days int not null default 0,
  best_streak int not null default 0,
  last_checkin_date date,
  updated_at timestamptz not null default now(),
  unique(profile_id)
);

create table if not exists daily_quests (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  label text not null,
  xp_reward int not null,
  active boolean not null default true
);

create table if not exists quest_completions (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles(id),
  quest_id uuid not null references daily_quests(id),
  completed_on date not null default current_date,
  unique(profile_id, quest_id, completed_on)
);

alter table gamification_profiles enable row level security;
alter table quest_completions enable row level security;

drop policy if exists gamification_profiles_self_all on gamification_profiles;
create policy gamification_profiles_self_all
on gamification_profiles for all
using (profile_id = auth.uid() or get_user_role(auth.uid()) = 'admin')
with check (profile_id = auth.uid() or get_user_role(auth.uid()) = 'admin');

drop policy if exists quest_completions_self_all on quest_completions;
create policy quest_completions_self_all
on quest_completions for all
using (profile_id = auth.uid() or get_user_role(auth.uid()) = 'admin')
with check (profile_id = auth.uid() or get_user_role(auth.uid()) = 'admin');

create or replace function claim_daily_checkin()
returns jsonb language plpgsql security definer
as $$
declare v_uid uuid := auth.uid(); v_gam record; v_today date := current_date;
begin
  if v_uid is null then return jsonb_build_object('success',false,'message','Utilisateur non connecté.'); end if;
  insert into gamification_profiles(profile_id) values(v_uid) on conflict (profile_id) do nothing;
  select * into v_gam from gamification_profiles where profile_id = v_uid for update;
  if v_gam.last_checkin_date = v_today then return jsonb_build_object('success',false,'message','Check-in déjà effectué.'); end if;
  update gamification_profiles set
    streak_days = case when v_gam.last_checkin_date = v_today - 1 then v_gam.streak_days + 1 else 1 end,
    best_streak = greatest(v_gam.best_streak, case when v_gam.last_checkin_date = v_today - 1 then v_gam.streak_days + 1 else 1 end),
    xp = v_gam.xp + 20, level = greatest(1, ((v_gam.xp + 20) / 120) + 1),
    last_checkin_date = v_today, updated_at = now()
  where profile_id = v_uid;
  return jsonb_build_object('success',true,'message','Check-in validé.', 'xp_gain',20);
end; $$;

revoke all on function claim_daily_checkin() from public;
grant execute on function claim_daily_checkin() to authenticated;
