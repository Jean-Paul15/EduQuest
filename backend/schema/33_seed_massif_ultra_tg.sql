do $$
declare
  v_country uuid;
  v_teacher uuid;
begin
  select id into v_country from countries where code = 'TG' limit 1;
  if v_country is null then
    raise exception 'Pays TG introuvable. Exécute d''abord le bootstrap.';
  end if;

  insert into education_levels(country_id, code, label, sort_order, is_active, is_exam_level, exam_name)
  values
  (v_country, 'Seconde', 'Seconde', 1, true, false, null),
  (v_country, 'Première', 'Première', 2, true, true, 'BAC 1 / Probatoire'),
  (v_country, 'Terminale', 'Terminale', 3, true, true, 'BAC / Baccalauréat')
  on conflict (country_id, code) do update
  set label = excluded.label, sort_order = excluded.sort_order, is_active = true,
      is_exam_level = excluded.is_exam_level, exam_name = excluded.exam_name;

  insert into series(education_level_id, code, label, is_active)
  select el.id, v.code, v.label, v.active
  from education_levels el
  join (values
  ('Première', 'A', 'Série A', true),
  ('Première', 'C', 'Série C', true),
  ('Première', 'D', 'Série D', true),
  ('Terminale', 'A', 'Série A', true),
  ('Terminale', 'C', 'Série C', true),
  ('Terminale', 'D', 'Série D', true),
  ('Première', 'G1', 'Série G1', false),
  ('Première', 'G2', 'Série G2', false),
  ('Première', 'G3', 'Série G3', false),
  ('Terminale', 'G1', 'Série G1', false),
  ('Terminale', 'G2', 'Série G2', false),
  ('Terminale', 'G3', 'Série G3', false)
  ) v(level_code, code, label, active) on v.level_code = el.code
  on conflict (education_level_id, code) do update
  set label = excluded.label, is_active = excluded.is_active;

  insert into subjects(country_id, code, label)
  values
  (v_country, 'MATH', 'Mathématiques'),
  (v_country, 'PC', 'Physique-Chimie'),
  (v_country, 'SVT', 'SVT'),
  (v_country, 'HIST', 'Histoire-Géographie'),
  (v_country, 'FR', 'Français'),
  (v_country, 'PHILO', 'Philosophie'),
  (v_country, 'ANGL', 'Anglais'),
  (v_country, 'ESP', 'Espagnol'),
  (v_country, 'ALL', 'Allemand'),
  (v_country, 'ECON', 'Économie'),
  (v_country, 'COMPTA', 'Comptabilité'),
  (v_country, 'INFO', 'Informatique'),
  (v_country, 'GEO', 'Géographie'),
  (v_country, 'EPS', 'Éducation Physique'),
  (v_country, 'EDHC', 'Éducation civique')
  on conflict (country_id, code) do update set label = excluded.label;

  insert into series_subjects(series_id, subject_id, coefficient)
  select sr.id, sb.id, v.coef
  from (values
  ('Première', 'A', 'FR', 4.0),('Première', 'A', 'HIST', 3.0),('Première', 'A', 'PHILO', 2.0),('Première', 'A', 'ANGL', 2.0),
  ('Première', 'C', 'MATH', 5.0),('Première', 'C', 'PC', 4.0),('Première', 'C', 'SVT', 2.0),('Première', 'C', 'ANGL', 2.0),
  ('Première', 'D', 'SVT', 5.0),('Première', 'D', 'PC', 4.0),('Première', 'D', 'MATH', 4.0),('Première', 'D', 'ANGL', 2.0),
  ('Terminale', 'A', 'FR', 4.0),('Terminale', 'A', 'HIST', 4.0),('Terminale', 'A', 'PHILO', 4.0),('Terminale', 'A', 'ANGL', 2.0),
  ('Terminale', 'C', 'MATH', 7.0),('Terminale', 'C', 'PC', 6.0),('Terminale', 'C', 'SVT', 2.0),('Terminale', 'C', 'ANGL', 2.0),
  ('Terminale', 'D', 'SVT', 8.0),('Terminale', 'D', 'PC', 5.0),('Terminale', 'D', 'MATH', 5.0),('Terminale', 'D', 'ANGL', 2.0)
  ) v(level_code, serie_code, subject_code, coef)
  join education_levels el on el.country_id = v_country and el.code = v.level_code
  join series sr on sr.education_level_id = el.id and sr.code = v.serie_code
  join subjects sb on sb.country_id = v_country and sb.code = v.subject_code
  on conflict (series_id, subject_id) do update set coefficient = excluded.coefficient;

  insert into chapters(subject_id, education_level_id, title, position)
  select sb.id, el.id, v.title, v.position
  from (values
  ('Seconde', 'MATH', 'Fonctions de base', 1),
  ('Seconde', 'MATH', 'Équations et inéquations', 2),
  ('Seconde', 'PC', 'Mouvement rectiligne', 1),
  ('Seconde', 'SVT', 'Cellule et organisation', 1),
  ('Seconde', 'HIST', 'Civilisations africaines', 1),
  ('Seconde', 'FR', 'Méthodologie du commentaire', 1),
  ('Première', 'MATH', 'Dérivation', 1),
  ('Première', 'MATH', 'Statistiques', 2),
  ('Première', 'PC', 'Énergie et puissance', 1),
  ('Première', 'SVT', 'Génétique de base', 1),
  ('Première', 'HIST', 'Colonisation et résistances', 1),
  ('Première', 'FR', 'Dissertation guidée', 1),
  ('Première', 'PHILO', 'Conscience et liberté', 1),
  ('Première', 'ANGL', 'Communication skills', 1),
  ('Terminale', 'MATH', 'Exponentielle et logarithme', 1),
  ('Terminale', 'MATH', 'Suites numériques', 2),
  ('Terminale', 'PC', 'Électricité et circuits', 1),
  ('Terminale', 'PC', 'Optique géométrique', 2),
  ('Terminale', 'SVT', 'Génétique humaine', 1),
  ('Terminale', 'SVT', 'Immunologie', 2),
  ('Terminale', 'HIST', 'Indépendances africaines', 1),
  ('Terminale', 'FR', 'Synthèse de textes', 1),
  ('Terminale', 'PHILO', 'Vérité et science', 1),
  ('Terminale', 'ANGL', 'Academic writing', 1)
  ) v(level_code, subject_code, title, position)
  join education_levels el on el.country_id = v_country and el.code = v.level_code
  join subjects sb on sb.country_id = v_country and sb.code = v.subject_code
  where not exists (
    select 1 from chapters c where c.subject_id = sb.id and c.education_level_id = el.id and c.title = v.title
  );

  insert into resources(chapter_id, type, title, external_url, access_scope, version, published)
  select ch.id, v.type, v.title, v.url, v.scope::jsonb, '1.0.0', true
  from (values
  ('Seconde','MATH','Fonctions de base','pdf','Résumé - Fonctions','https://example.com/tg/sec-math-fonctions-resume.pdf','{"levels":["Seconde"],"series":[],"chapter":"Fonctions de base"}'),
  ('Seconde','MATH','Fonctions de base','exercise_set','Exercices - Fonctions','https://example.com/tg/sec-math-fonctions-exo.pdf','{"levels":["Seconde"],"series":[],"chapter":"Fonctions de base"}'),
  ('Première','MATH','Dérivation','pdf','Résumé - Dérivation','https://example.com/tg/prem-math-derivation-resume.pdf','{"levels":["Première"],"series":["A","C","D"],"chapter":"Dérivation"}'),
  ('Première','MATH','Dérivation','summary','Corrigés - Dérivation','https://example.com/tg/prem-math-derivation-corr.pdf','{"levels":["Première"],"series":["A","C","D"],"chapter":"Dérivation"}'),
  ('Terminale','MATH','Exponentielle et logarithme','pdf','Résumé - Exponentielle','https://example.com/tg/tle-math-exp-resume.pdf','{"levels":["Terminale"],"series":["C","D"],"chapter":"Exponentielle"}'),
  ('Terminale','MATH','Exponentielle et logarithme','exercise_set','Exercices - Exponentielle','https://example.com/tg/tle-math-exp-exo.pdf','{"levels":["Terminale"],"series":["C","D"],"chapter":"Exponentielle"}'),
  ('Terminale','MATH','Exponentielle et logarithme','summary','Corrigés - Exponentielle','https://example.com/tg/tle-math-exp-corr.pdf','{"levels":["Terminale"],"series":["C","D"],"chapter":"Exponentielle"}'),
  ('Terminale','SVT','Génétique humaine','pdf','Résumé - Génétique','https://example.com/tg/tle-svt-gen-resume.pdf','{"levels":["Terminale"],"series":["D"],"chapter":"Génétique humaine"}'),
  ('Terminale','SVT','Génétique humaine','video','Capsule - Génétique','https://example.com/tg/tle-svt-gen-video.mp4','{"levels":["Terminale"],"series":["D"],"chapter":"Génétique humaine"}'),
  ('Terminale','SVT','Génétique humaine','youtube','YouTube - Génétique','https://www.youtube.com/watch?v=dQw4w9WgXcQ','{"levels":["Terminale"],"series":["D"],"chapter":"Génétique humaine"}'),
  ('Terminale','HIST','Indépendances africaines','pdf','Résumé - Indépendances','https://example.com/tg/tle-hist-indep-resume.pdf','{"levels":["Terminale"],"series":["A","C","D"],"chapter":"Indépendances africaines"}'),
  ('Terminale','HIST','Indépendances africaines','youtube','YouTube - Indépendances','https://www.youtube.com/watch?v=5qap5aO4i9A','{"levels":["Terminale"],"series":["A","C","D"],"chapter":"Indépendances africaines"}')
  ) v(level_code, subject_code, chapter_title, type, title, url, scope)
  join education_levels el on el.country_id = v_country and el.code = v.level_code
  join subjects sb on sb.country_id = v_country and sb.code = v.subject_code
  join chapters ch on ch.education_level_id = el.id and ch.subject_id = sb.id and ch.title = v.chapter_title
  where not exists (
    select 1 from resources r where r.chapter_id = ch.id and r.type = v.type and r.title = v.title
  );

  insert into quizzes(chapter_id, title, access_scope, published)
  select ch.id, 'QCM - ' || ch.title, jsonb_build_object('levels', jsonb_build_array(el.code), 'series', jsonb_build_array('A','C','D')), true
  from chapters ch join education_levels el on el.id = ch.education_level_id
  where el.country_id = v_country
    and not exists(select 1 from quizzes q where q.chapter_id = ch.id and q.title = 'QCM - ' || ch.title);

  insert into quiz_questions(quiz_id, type, prompt, answer_key)
  select q.id, 'mcq', 'Question 1 - ' || q.title, '{"options":["A","B","C","D"],"answer":"A"}'::jsonb
  from quizzes q
  where not exists(select 1 from quiz_questions qq where qq.quiz_id = q.id and qq.prompt = 'Question 1 - ' || q.title);

  insert into exam_papers(country_id, education_level_id, subject_id, semester, source_school, year, is_national_exam, access_scope, paper_path, correction_path)
  select v_country, el.id, sb.id, v.semester, v.source_school, v.year, v.national, v.scope::jsonb, v.paper, v.correction
  from (values
  ('Terminale','MATH',null,'BAC Série C/D',2022,true,'{"levels":["Terminale"],"series":["C","D"]}','https://example.com/exams/bac-math-2022.pdf','https://example.com/exams/bac-math-2022-corr.pdf'),
  ('Terminale','MATH',null,'BAC Série C/D',2023,true,'{"levels":["Terminale"],"series":["C","D"]}','https://example.com/exams/bac-math-2023.pdf','https://example.com/exams/bac-math-2023-corr.pdf'),
  ('Terminale','HIST',null,'BAC Série A/C/D',2022,true,'{"levels":["Terminale"],"series":["A","C","D"]}','https://example.com/exams/bac-hist-2022.pdf',null),
  ('Terminale','SVT',null,'BAC Série D',2023,true,'{"levels":["Terminale"],"series":["D"]}','https://example.com/exams/bac-svt-2023.pdf','https://example.com/exams/bac-svt-2023-corr.pdf'),
  ('Première','MATH','S1','Lycée Tokoin',2024,false,'{"levels":["Première"],"series":["A","C","D"]}','https://example.com/epreuves/prem-math-s1-2024.pdf','https://example.com/epreuves/prem-math-s1-2024-corr.pdf'),
  ('Première','MATH','S2','Lycée Tokoin',2024,false,'{"levels":["Première"],"series":["A","C","D"]}','https://example.com/epreuves/prem-math-s2-2024.pdf',null),
  ('Première','FR','S1','Lycée Agoè',2024,false,'{"levels":["Première"],"series":["A","C","D"]}','https://example.com/epreuves/prem-fr-s1-2024.pdf','https://example.com/epreuves/prem-fr-s1-2024-corr.pdf'),
  ('Première','HIST','S2','Lycée Agoè',2024,false,'{"levels":["Première"],"series":["A","C","D"]}','https://example.com/epreuves/prem-hist-s2-2024.pdf','https://example.com/epreuves/prem-hist-s2-2024-corr.pdf'),
  ('Terminale','MATH',null,'Examen blanc C/D',2024,false,'{"levels":["Terminale"],"series":["C","D"]}','https://example.com/blancs/tle-math-blanc-2024.pdf','https://example.com/blancs/tle-math-blanc-2024-corr.pdf'),
  ('Terminale','SVT',null,'Examen blanc D',2024,false,'{"levels":["Terminale"],"series":["D"]}','https://example.com/blancs/tle-svt-blanc-2024.pdf','https://example.com/blancs/tle-svt-blanc-2024-corr.pdf'),
  ('Terminale','HIST',null,'Examen blanc A',2024,false,'{"levels":["Terminale"],"series":["A"]}','https://example.com/blancs/tle-hist-blanc-2024.pdf',null)
  ) v(level_code, subject_code, semester, source_school, year, national, scope, paper, correction)
  join education_levels el on el.country_id = v_country and el.code = v.level_code
  join subjects sb on sb.country_id = v_country and sb.code = v.subject_code
  where not exists (
    select 1 from exam_papers ep
    where ep.country_id = v_country
      and ep.education_level_id = el.id
      and ep.subject_id = sb.id
      and coalesce(ep.semester,'') = coalesce(v.semester,'')
      and ep.source_school = v.source_school
      and ep.year = v.year
  );

  if v_teacher is not null then
    insert into live_classes(teacher_id, subject_id, education_level_id, title, access_scope, zoom_link, starts_at, ends_at)
    select v_teacher, sb.id, el.id, v.title, v.scope::jsonb, v.link, now() + v.starts_in, now() + v.ends_in
    from (values
    ('Première','MATH','Live Probatoire Maths','{"levels":["Première"],"series":["A","C","D"]}','https://zoom.us/j/7311111111',interval '2 days',interval '2 days 90 minutes'),
    ('Première','HIST','Live Probatoire Histoire','{"levels":["Première"],"series":["A","C","D"]}','https://zoom.us/j/7322222222',interval '3 days',interval '3 days 90 minutes'),
    ('Terminale','MATH','Live BAC Maths C/D','{"levels":["Terminale"],"series":["C","D"]}','https://zoom.us/j/7333333333',interval '4 days',interval '4 days 2 hours'),
    ('Terminale','SVT','Live BAC SVT D','{"levels":["Terminale"],"series":["D"]}','https://zoom.us/j/7344444444',interval '5 days',interval '5 days 2 hours'),
    ('Terminale','HIST','Live BAC Histoire A/C/D','{"levels":["Terminale"],"series":["A","C","D"]}','https://zoom.us/j/7355555555',interval '6 days',interval '6 days 2 hours')
    ) v(level_code, subject_code, title, scope, link, starts_in, ends_in)
    join education_levels el on el.country_id = v_country and el.code = v.level_code
    join subjects sb on sb.country_id = v_country and sb.code = v.subject_code
    where not exists(select 1 from live_classes lc where lc.title = v.title and lc.education_level_id = el.id);
  end if;

  insert into contests(country_id, title, rules_md, eligibility_scope, access_scope, required_ticket_type, starts_at, ends_at, created_at, is_in_person, venue)
  values
  (v_country, 'Challenge BAC Hebdo', '## Règles\n- 25 QCM\n- Classement hebdo\n- Top 10 récompensé', '{"levels":["Terminale"],"series":["A","C","D"]}', '{"levels":["Terminale"],"series":["A","C","D"]}', 'HALF', now()+interval '2 day', now()+interval '9 day', now(), false, null),
  (v_country, 'Duel Probatoire', '## Règles\n- Série de mini-tests\n- Élimination directe', '{"levels":["Première"],"series":["A","C","D"]}', '{"levels":["Première"],"series":["A","C","D"]}', 'HALF', now()+interval '6 day', now()+interval '13 day', now(), true, 'Campus Lomé')
  on conflict do nothing;

  insert into events(country_id, title, event_type, access_scope, required_ticket_type, starts_at, venue, external_ticket_url, created_at)
  values
  (v_country, 'Masterclass Orientation 2026', 'formation', '{"levels":["Première","Terminale"],"series":["A","C","D"]}', 'FULL', now()+interval '10 day', 'Palais des Congrès + Zoom', 'https://example.com/tickets/masterclass-2026', now()),
  (v_country, 'Bootcamp BAC Intensif', 'formation', '{"levels":["Terminale"],"series":["A","C","D"]}', 'FULL', now()+interval '15 day', 'Lomé', 'https://example.com/tickets/bootcamp-bac', now()),
  (v_country, 'Forum des Filières Universitaires', 'forum', '{"levels":["Première","Terminale"],"series":["A","C","D"]}', 'HALF', now()+interval '20 day', 'Université de Lomé', 'https://example.com/tickets/forum-filieres', now())
  on conflict do nothing;

  insert into surveys(country_id, title, target_scope, starts_at, ends_at, created_at)
  values
  (v_country, 'Difficultés de la semaine', '{"levels":["Seconde","Première","Terminale"]}', now(), now()+interval '7 day', now()),
  (v_country, 'Orientation Universitaire - Diagnostic', '{"levels":["Première","Terminale"],"series":["A","C","D"]}', now(), now()+interval '30 day', now())
  on conflict do nothing;

  insert into marketplace_items(country_id, title, item_type, price_label, external_checkout_url, active, description, tags, access_scope, target_scope)
  values
  (v_country, 'Livre Maths Terminale C/D', 'book', '9 500 FCFA', 'https://example.com/shop/math-tle', true, 'Livre complet avec exercices corrigés', '{"math","terminale","bac"}', '{}'::jsonb, '{"levels":["Terminale"],"series":["C","D"]}'::jsonb),
  (v_country, 'Livre SVT Terminale D', 'book', '10 000 FCFA', 'https://example.com/shop/svt-tle-d', true, 'Schémas et annales corrigées', '{"svt","terminale","bac"}', '{}'::jsonb, '{"levels":["Terminale"],"series":["D"]}'::jsonb),
  (v_country, 'Pack Probatoire Première', 'kit', '8 000 FCFA', 'https://example.com/shop/probatoire', true, 'Épreuves + corrigés + planning', '{"premiere","probatoire"}', '{}'::jsonb, '{"levels":["Première"],"series":["A","C","D"]}'::jsonb),
  (v_country, 'Pack Annales BAC A/C/D', 'kit', '12 000 FCFA', 'https://example.com/shop/annales-bac', true, 'Annales nationales sur 10 ans', '{"annales","bac"}', '{}'::jsonb, '{"levels":["Terminale"],"series":["A","C","D"]}'::jsonb)
  on conflict do nothing;
end $$;
