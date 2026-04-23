-- Generated from supabase/packs/ by supabase/scripts/seed_packs.ts
insert into public.knowledge_packs
(id, name, version, goal, principles_md, plan_templates, rep_range_guidance, rest_guidance, substitutions, red_flags_md, is_active)
values
  ('hypertrophy-v1', 'Hypertrophy-focused training', '1.0.0', 'muscle', '# Hypertrophy principles

- **Progressive overload is the driver.** Increase weight or reps vs the
  previous session whenever set targets are met at the prescribed RIR.
- **Volume is king.** Target 10–20 hard sets per muscle per week for most
  intermediates. Beginners can progress on less; advanced often need more.
- **Rep range 6–15 is optimal for hypertrophy.** Compounds lean to the low
  end (6–10); isolations to the high end (10–15).
- **RIR 0–3 across working sets.** Most sets should be 1–3 reps from failure.
  Push final sets to RIR 0 on isolations only.
- **Prioritize compounds early, isolations late.** Heaviest work first when
  fresh; focus-pump work at the end.
- **Rest 2–3 min for compounds, 60–90s for isolations.**
- **Frequency matters.** Each muscle group trained 2x/week beats 1x/week at
  matched volume.
- **Deload every 4–6 weeks** OR when two or more exercises stall
  simultaneously. A deload is 50% volume at the same intensity.
- **Sleep, stress, and protein (1.6–2.2 g/kg/day) are non-negotiable.**
- **Do not prescribe plans that:** exceed 6 days/week; place the same muscle
  in consecutive days without a clear reason; prescribe < 5 total sets/week
  for a trained muscle; use rep ranges below 5 or above 20 for hypertrophy
  goals.
', '[{"split":"full_body","days_per_week":3,"structure":[{"day":"Full Body A","focus":"compound lifts","movements":["squat_pattern","horizontal_push","horizontal_pull","core","biceps","triceps"]},{"day":"Full Body B","focus":"compound lifts","movements":["hinge_pattern","vertical_push","vertical_pull","lunge","calves"]},{"day":"Full Body C","focus":"moderate intensity","movements":["squat_pattern","horizontal_push","vertical_pull","rear_delts","forearms"]}]},{"split":"upper_lower","days_per_week":4,"structure":[{"day":"Upper A","focus":"heavy push","movements":["horizontal_push","vertical_pull","horizontal_pull","vertical_push","biceps","triceps"]},{"day":"Lower A","focus":"heavy lower","movements":["squat_pattern","hinge_pattern","lunge","calves","core"]},{"day":"Upper B","focus":"volume push","movements":["vertical_push","horizontal_pull","horizontal_push","vertical_pull","rear_delts","arms"]},{"day":"Lower B","focus":"volume lower + posterior","movements":["hinge_pattern","squat_pattern","hamstrings","calves","glutes"]}]},{"split":"ppl","days_per_week":6,"structure":[{"day":"Push A","movements":["horizontal_push","vertical_push","side_delts","triceps","triceps_isolation"]},{"day":"Pull A","movements":["vertical_pull","horizontal_pull","rear_delts","biceps","forearms"]},{"day":"Legs A","movements":["squat_pattern","hinge_pattern","quads_isolation","hamstrings","calves"]},{"day":"Push B","movements":["vertical_push","horizontal_push_isolation","chest_isolation","side_delts","triceps"]},{"day":"Pull B","movements":["horizontal_pull","vertical_pull","lats_isolation","rear_delts","biceps"]},{"day":"Legs B","movements":["hinge_pattern","lunge","quads_isolation","glutes","calves"]}]}]'::jsonb, '{"compound":{"reps_min":5,"reps_max":10,"rir_min":1,"rir_max":3},"isolation":{"reps_min":8,"reps_max":15,"rir_min":0,"rir_max":2},"core":{"reps_min":10,"reps_max":20,"rir_min":0,"rir_max":3}}'::jsonb, '{"compound":180,"isolation":90,"core":60}'::jsonb, '[{"when":"no_barbell","avoid":["barbell"],"prefer":["dumbbell","machine"]},{"when":"knee_pain","avoid_exercises":["barbell back squat","walking lunge","pistol squat"],"prefer_exercises":["leg press","goblet squat","split squat"]},{"when":"lower_back_pain","avoid_exercises":["barbell deadlift","good morning","bent-over row"],"prefer_exercises":["romanian deadlift","trap bar deadlift","seated row"]},{"when":"shoulder_pain","avoid_exercises":["barbell overhead press","behind-the-neck press","upright row"],"prefer_exercises":["dumbbell overhead press","lateral raise","landmine press"]}]'::jsonb, '# Red flags

If the user reports any of the following, the AI should:
1. Acknowledge the concern.
2. Suggest seeing a qualified professional (physio, physician).
3. Still generate a conservative plan avoiding the flagged area.
4. Never diagnose or treat.

## Signs to flag

- Sharp joint pain during movement
- Radiating nerve pain (numbness, tingling down a limb)
- Pain that worsens with rest
- Chest pain during exertion
- Dizziness or severe shortness of breath
- Pain described as "stabbing" rather than muscular soreness
', true)
on conflict (id) do update set
  name = excluded.name, version = excluded.version, goal = excluded.goal,
  principles_md = excluded.principles_md, plan_templates = excluded.plan_templates,
  rep_range_guidance = excluded.rep_range_guidance, rest_guidance = excluded.rest_guidance,
  substitutions = excluded.substitutions, red_flags_md = excluded.red_flags_md,
  is_active = excluded.is_active;
