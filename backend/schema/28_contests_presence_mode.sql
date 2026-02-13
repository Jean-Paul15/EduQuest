alter table contests
  add column if not exists is_in_person boolean not null default false,
  add column if not exists venue text;
