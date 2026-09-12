// SQL migration 210 : realignement du socle sur le modele reel (pas de recreation).
// - EDHC -> ECM (0 reference en base, renommage sur)
// - HIST reetiquete "Histoire-Geographie" (la source combine ; Togo enseigne combine au lycee)
// - GEO supprime s'il est orphelin (le combine vit sur HIST)
// - Seconde : ajout des series A et S (C & D fusionnees)

export function buildFoundationSql() {
  return `-- 210: realignement socle curriculum Togo sur ecole.gouv.tg (source de verite = programme scrappe)
update subjects set code = 'ECM', label = 'Éducation Civique et Morale'
where code = 'EDHC' and country_id = (select id from countries where code = 'TG');

update subjects set label = 'Histoire-Géographie'
where code = 'HIST' and country_id = (select id from countries where code = 'TG');

delete from subjects
where code = 'GEO' and country_id = (select id from countries where code = 'TG')
  and not exists (select 1 from series_subjects x where x.subject_id = subjects.id)
  and not exists (select 1 from chapters c where c.subject_id = subjects.id)
  and not exists (select 1 from exam_papers e where e.subject_id = subjects.id);

insert into series (education_level_id, code, label, is_active)
select el.id, v.code, v.label, true
from education_levels el
join countries c on c.id = el.country_id and c.code = 'TG'
join (values ('A', 'Série A'), ('S', 'Série S (C & D)')) v(code, label) on el.code = 'Seconde'
on conflict (education_level_id, code) do update set label = excluded.label, is_active = true;
`;
}
