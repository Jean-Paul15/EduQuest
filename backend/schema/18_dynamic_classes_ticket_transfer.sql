alter table education_levels
  add column if not exists sort_order int not null default 0;

alter table ticket_products
  add column if not exists base_education_level_id uuid references education_levels(id);

alter table ticket_products
  add column if not exists allow_downward_access boolean not null default true;

create table if not exists profile_level_changes (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles(id),
  old_education_level_id uuid references education_levels(id),
  new_education_level_id uuid not null references education_levels(id),
  old_series_id uuid references series(id),
  new_series_id uuid references series(id),
  changed_at timestamptz not null default now()
);

create or replace function can_ticket_cover_level(p_product_id uuid, p_target_level_id uuid)
returns boolean language plpgsql stable
as $$
declare p_order int; t_order int; allow_downward boolean;
begin
  select base.sort_order, tp.allow_downward_access into p_order, allow_downward
  from ticket_products tp left join education_levels base on base.id = tp.base_education_level_id
  where tp.id = p_product_id;
  if p_order is null then return true; end if;
  select sort_order into t_order from education_levels where id = p_target_level_id;
  if t_order is null then return false; end if;
  if allow_downward then return p_order >= t_order; end if;
  return p_order = t_order;
end; $$;

create or replace function can_user_access_level(p_target_level_id uuid, uid uuid default auth.uid())
returns boolean language plpgsql stable
as $$
declare v_product uuid;
begin
  if uid is null then return false; end if;
  if get_user_role(uid) = 'admin' then return true; end if;
  select tc.product_id into v_product
  from ticket_codes tc
  where tc.activated_by = uid and tc.expires_at > now()
  order by tc.expires_at desc limit 1;
  if v_product is null then return false; end if;
  return can_ticket_cover_level(v_product, p_target_level_id);
end; $$;

create or replace function change_student_level(p_level_id uuid, p_series_id uuid)
returns jsonb language plpgsql security definer
as $$
declare v_uid uuid := auth.uid(); o_level uuid; o_series uuid; v_ok boolean := false;
begin
  if v_uid is null then return jsonb_build_object('success',false,'message','Utilisateur non connecté.'); end if;
  select is_active into v_ok from education_levels where id = p_level_id;
  if coalesce(v_ok,false) = false then return jsonb_build_object('success',false,'message','Classe inactive.'); end if;
  if p_series_id is not null then
    select exists(
      select 1 from series s where s.id = p_series_id and s.education_level_id = p_level_id and s.is_active = true
    ) into v_ok;
    if v_ok = false then return jsonb_build_object('success',false,'message','Série invalide pour cette classe.'); end if;
  end if;
  select education_level_id, series_id into o_level, o_series from profiles where id = v_uid;
  if can_user_access_level(p_level_id, v_uid) = false then
    return jsonb_build_object('success',false,'message','Niveau non autorisé par le ticket.');
  end if;
  update profiles set education_level_id = p_level_id, series_id = p_series_id where id = v_uid;
  insert into profile_level_changes(profile_id, old_education_level_id, new_education_level_id, old_series_id, new_series_id)
  values(v_uid, o_level, p_level_id, o_series, p_series_id);
  return jsonb_build_object('success',true,'message','Classe mise à jour.');
end; $$;
