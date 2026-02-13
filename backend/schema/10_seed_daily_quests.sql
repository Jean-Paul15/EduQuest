insert into daily_quests(code, label, xp_reward, active) values
('open_lesson', 'Ouvrir un cours', 10, true),
('complete_quiz', 'Terminer un QCM', 20, true),
('review_15min', 'Réviser 15 minutes', 15, true)
on conflict (code) do update set
  label = excluded.label,
  xp_reward = excluded.xp_reward,
  active = excluded.active;

