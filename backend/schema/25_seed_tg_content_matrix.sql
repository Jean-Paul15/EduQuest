insert into resources(chapter_id, type, title, external_url, access_scope, version, published)
select ch.id, v.typ, v.title, v.url, v.scope::jsonb, '1.0.0', true
from chapters ch
join subjects s on s.id = ch.subject_id
join education_levels e on e.id = ch.education_level_id
join (values
('MATH','Seconde','exercise_set','Exercices de base - Fonctions','https://example.com/exo-seconde-fonctions','{"levels":["Seconde"],"series":[],"chapter":"Fonctions"}'),
('MATH','Première','exercise_set','Exercices Probatoire - Fonctions','https://example.com/exo-premiere-fonctions','{"levels":["Première"],"series":["A","C","D"],"chapter":"Fonctions"}'),
('MATH','Terminale','summary','Corrections BAC - Fonctions','https://example.com/corr-terminale-fonctions','{"levels":["Terminale"],"series":["A","C","D"],"chapter":"Fonctions"}'),
('HIST','Terminale','youtube','Révision BAC - Histoire','https://www.youtube.com/watch?v=dQw4w9WgXcQ','{"levels":["Terminale"],"series":["A","C","D"],"chapter":"Révision BAC"}')
) v(sub,lev,typ,title,url,scope)
on s.code=v.sub and e.code=v.lev
where ch.position = 1;

insert into survey_questions(survey_id, prompt, question_type, options, required, position)
select s.id, v.prompt, v.qtype, v.opts::jsonb, true, v.pos
from surveys s
join (values
('Quelle matière te pose le plus de difficultés ?', 'mcq', '["Mathématiques","SVT","Histoire-Géo","Autre"]', 1),
('Préfères-tu des lives Zoom en semaine ou week-end ?', 'mcq', '["Semaine","Week-end"]', 2),
('Que doit-on améliorer en priorité ?', 'text', '[]', 3)
) v(prompt,qtype,opts,pos) on s.title = 'Difficultés de la semaine'
on conflict do nothing;
