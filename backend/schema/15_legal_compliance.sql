create table if not exists legal_documents (
  id uuid primary key default gen_random_uuid(),
  doc_type text not null check (doc_type in ('terms','privacy')),
  version text not null,
  locale text not null default 'fr-TG',
  title text not null,
  body_md text not null,
  active boolean not null default true,
  published_at timestamptz not null default now(),
  unique(doc_type, version, locale)
);

create table if not exists user_legal_consents (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles(id),
  doc_type text not null check (doc_type in ('terms','privacy')),
  doc_version text not null,
  locale text not null default 'fr-TG',
  accepted_at timestamptz not null default now(),
  unique(profile_id, doc_type, doc_version, locale)
);

alter table legal_documents enable row level security;
alter table user_legal_consents enable row level security;
drop policy if exists legal_documents_read_all on legal_documents;
create policy legal_documents_read_all on legal_documents for select using (auth.uid() is not null);
drop policy if exists legal_consents_self_all on user_legal_consents;
create policy legal_consents_self_all on user_legal_consents for all
using (profile_id = auth.uid() or get_user_role(auth.uid()) = 'admin')
with check (profile_id = auth.uid() or get_user_role(auth.uid()) = 'admin');

