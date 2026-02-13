insert into subjects(country_id, code, label)
select c.id, v.code, v.label from countries c
join (values ('MATH','Mathématiques'),('HIST','Histoire-Géographie'),('SVT','SVT')) v(code,label) on c.code='TG'
on conflict (country_id, code) do update set label = excluded.label;

insert into chapters(subject_id, education_level_id, title, position)
select s.id, e.id, v.title, v.pos
from subjects s
join countries c on c.id=s.country_id and c.code='TG'
join education_levels e on e.country_id=c.id
join (values ('MATH','Terminale','Fonctions exponentielles',1),('HIST','Première','Colonisation en Afrique',1),('SVT','Terminale','Génétique humaine',2)) v(sub,lev,title,pos)
on s.code=v.sub and e.code=v.lev;

insert into resources(chapter_id, type, title, external_url, access_scope, version, published)
select ch.id, v.typ, v.title, v.url, v.scope::jsonb, '1.0.0', true
from chapters ch
join subjects s on s.id=ch.subject_id
join education_levels e on e.id=ch.education_level_id
join (values
('MATH','Terminale','Fonctions exponentielles','exercise_set','Exercices guidés - exponentielle','https://example.com/exo-exp','{"levels":["Terminale"],"series":["C","D"],"chapter":"Exponentielle"}'),
('MATH','Terminale','Fonctions exponentielles','summary','Corrections - exponentielle','https://example.com/corr-exp','{"levels":["Terminale"],"series":["C","D"],"chapter":"Exponentielle"}'),
('HIST','Première','Colonisation en Afrique','youtube','Vidéo - Colonisation','https://www.youtube.com/watch?v=dQw4w9WgXcQ','{"levels":["Première"],"series":["A","C","D"],"chapter":"Colonisation"}'),
('SVT','Terminale','Génétique humaine','pdf','Cours PDF - Génétique','https://example.com/svt-gen.pdf','{"levels":["Terminale"],"series":["D"],"chapter":"Génétique"}')
) v(sub,lev,chapter,typ,title,url,scope) on s.code=v.sub and e.code=v.lev and ch.title=v.chapter;

insert into quizzes(chapter_id, title, access_scope, published)
select ch.id, 'QCM '||ch.title, jsonb_build_object('levels', jsonb_build_array(e.code), 'series', jsonb_build_array('A','C','D')), true
from chapters ch join education_levels e on e.id = ch.education_level_id;

insert into quiz_questions(quiz_id, type, prompt, answer_key)
select q.id, 'mcq', 'Quel point est correct ?', '{"options":["A","B","C","D"],"answer":"A"}'::jsonb from quizzes q;

insert into contests(country_id, title, rules_md, eligibility_scope, access_scope, required_ticket_type, starts_at, ends_at)
select c.id, 'Challenge BAC Blanc', '## Règles\n- 20 QCM\n- Classement hebdo', '{"levels":["Terminale"],"series":["A","C","D"]}', '{"levels":["Terminale"]}', 'HALF', now(), now()+interval '15 days'
from countries c where c.code='TG';

insert into events(country_id, title, event_type, access_scope, required_ticket_type, starts_at, venue, external_ticket_url)
select c.id, 'Masterclass Orientation', 'formation', '{"levels":["Première","Terminale"],"series":["A","C","D"]}', 'FULL', now()+interval '5 days', 'Zoom Live', 'https://example.com/tickets/masterclass'
from countries c where c.code='TG';

insert into surveys(country_id, title, target_scope, starts_at, ends_at)
select c.id, 'Difficultés de la semaine', '{"levels":["Seconde","Première","Terminale"]}', now(), now()+interval '7 days'
from countries c where c.code='TG';

insert into marketplace_items(country_id, title, item_type, price_label, external_checkout_url, active, description, tags, access_scope, target_scope)
select c.id, v.title, v.typ, v.price, v.url, true, v.descr, v.tags::text[], '{}'::jsonb, v.scope::jsonb
from countries c
join (values
('Livre SVT Terminale D','book','9 500 FCFA','https://example.com/shop/svt-d','Livre illustré schémas','{"svt","terminale","bac"}','{"levels":["Terminale"],"series":["D"]}'),
('Pack Annales BAC A/C/D','kit','12 000 FCFA','https://example.com/shop/annales-bac','Annales corrigées','{"annales","bac","qcm"}','{"levels":["Terminale"],"series":["A","C","D"]}'),
('Publicité Lycée Partenaire','ad_slot','Sur devis','https://example.com/shop/ad-school','Visibilité école','{"ecole","partenaire"}','{}')
) v(title,typ,price,url,descr,tags,scope) on c.code='TG';
