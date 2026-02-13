do $$
declare t text;
begin
  for t in select unnest(array[
    'resources','quizzes','quiz_questions','exam_papers','chapters',
    'contests','events','surveys','live_classes',
    'ticket_codes','gamification_profiles','profiles'
  ]) loop
    if exists(select 1 from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='public' and c.relname=t) then
      if not exists(
        select 1 from pg_publication_tables
        where pubname='supabase_realtime' and schemaname='public' and tablename=t
      ) then
        execute format('alter publication supabase_realtime add table public.%I', t);
      end if;
      execute format('alter table public.%I replica identity full', t);
    end if;
  end loop;
end $$;
