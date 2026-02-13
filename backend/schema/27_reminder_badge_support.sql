alter table notification_preferences
  add column if not exists reminder_enabled boolean not null default false,
  add column if not exists reminder_hour smallint not null default 19,
  add column if not exists reminder_minute smallint not null default 0;

alter table notification_preferences
  drop constraint if exists notification_preferences_reminder_hour_check;
alter table notification_preferences
  add constraint notification_preferences_reminder_hour_check
  check (reminder_hour between 0 and 23);

alter table notification_preferences
  drop constraint if exists notification_preferences_reminder_minute_check;
alter table notification_preferences
  add constraint notification_preferences_reminder_minute_check
  check (reminder_minute between 0 and 59);

alter table contests add column if not exists created_at timestamptz not null default now();
alter table events add column if not exists created_at timestamptz not null default now();
alter table surveys add column if not exists created_at timestamptz not null default now();
