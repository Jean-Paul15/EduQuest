alter table marketplace_items
  add column if not exists description text,
  add column if not exists tags text[] not null default '{}'::text[],
  add column if not exists access_scope jsonb not null default '{}'::jsonb,
  add column if not exists target_scope jsonb not null default '{}'::jsonb;

alter table marketplace_items enable row level security;
drop policy if exists marketplace_access_select on marketplace_items;
create policy marketplace_access_select on marketplace_items for select
using (active = true and has_scope_access(access_scope) and can_match_profile_scope(target_scope));

create index if not exists idx_marketplace_active_type on marketplace_items(active, item_type);
create index if not exists idx_marketplace_tags_gin on marketplace_items using gin(tags);

create or replace function search_marketplace_items(
  p_query text default null,
  p_item_type text default null,
  p_limit int default 40
)
returns table(id uuid, title text, item_type text, price_label text, external_checkout_url text, rank double precision)
language sql stable as $$
  with q as (
    select nullif(trim(coalesce(p_query,'')), '') as txt,
           case when nullif(trim(coalesce(p_query,'')), '') is null then null
             else plainto_tsquery('simple', nullif(trim(coalesce(p_query,'')), '')) end as ts
  )
  select m.id, m.title, m.item_type, m.price_label, m.external_checkout_url,
         case when q.ts is null then 0::double precision
              else ts_rank(to_tsvector('simple', coalesce(m.title,'') || ' ' || coalesce(m.description,'') || ' ' || array_to_string(m.tags,' ')), q.ts)::double precision end as rank
  from marketplace_items m cross join q
  where m.active = true
    and (p_item_type is null or m.item_type = p_item_type)
    and has_scope_access(m.access_scope) and can_match_profile_scope(m.target_scope)
    and (q.ts is null or to_tsvector('simple', coalesce(m.title,'') || ' ' || coalesce(m.description,'') || ' ' || array_to_string(m.tags,' ')) @@ q.ts)
  order by rank desc, m.title asc
  limit greatest(1, least(coalesce(p_limit,40), 120));
$$;

grant execute on function search_marketplace_items(text, text, int) to authenticated;
