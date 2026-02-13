insert into countries(code, name) values ('TG', 'Togo')
on conflict (code) do update set name = excluded.name;

insert into education_levels(country_id, code, label, sort_order, is_active, is_exam_level, exam_name)
select c.id, v.code, v.label, v.sort_order, true, v.is_exam, v.exam_name
from countries c
join (values
('Seconde','Seconde',1,false,null),
('Première','Première',2,true,'BAC 1 / Probatoire'),
('Terminale','Terminale',3,true,'BAC / Baccalauréat')
) as v(code,label,sort_order,is_exam,exam_name) on c.code='TG'
on conflict (country_id, code) do update
set label=excluded.label, sort_order=excluded.sort_order, is_active=true,
    is_exam_level=excluded.is_exam_level, exam_name=excluded.exam_name;

insert into series(education_level_id, code, label, is_active)
select e.id, v.code, v.label, v.is_active
from education_levels e
join (values
('A','Série A',true),('C','Série C',true),('D','Série D',true),
('G1','Série G1',false),('G2','Série G2',false),('G3','Série G3',false)
) v(code,label,is_active) on e.code in ('Première','Terminale')
on conflict (education_level_id, code) do update
set label=excluded.label, is_active=excluded.is_active;

