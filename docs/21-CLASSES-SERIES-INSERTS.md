# Requêtes insertion classes/séries (dynamique)

## 1) Pays
```sql
insert into countries(code, name) values ('TG','Togo')
on conflict (code) do update set name = excluded.name;
```

## 2) Classes (avec ordre)
```sql
insert into education_levels(country_id, code, label, sort_order, is_exam_level, exam_name)
select c.id, v.code, v.label, v.sort_order, v.is_exam, v.exam_name
from countries c
join (values
('Seconde','Seconde',1,false,null),
('Première','Première',2,true,'BAC 1 / Probatoire'),
('Terminale','Terminale',3,true,'BAC / Baccalauréat')
) as v(code,label,sort_order,is_exam,exam_name)
on c.code='TG'
on conflict (country_id, code) do update
set label=excluded.label, sort_order=excluded.sort_order, is_exam_level=excluded.is_exam_level, exam_name=excluded.exam_name;
```

## 3) Séries par classe
```sql
insert into series(education_level_id, code, label)
select e.id, v.code, v.label
from education_levels e
join (values ('A','Série A'),('C','Série C'),('D','Série D')) v(code,label) on true
where e.code in ('Première','Terminale')
on conflict (education_level_id, code) do update set label = excluded.label;
```

## 4) Ticket Terminale transférable vers inférieur
```sql
update ticket_products tp
set base_education_level_id = e.id, allow_downward_access = true
from education_levels e join countries c on c.id=e.country_id
where c.code='TG' and e.code='Terminale' and tp.code='TICKET_FULL_TLE';
```

## 5) Changement classe utilisateur (contrôlé ticket)
```sql
select change_student_level('LEVEL_UUID', 'SERIES_UUID');
```

