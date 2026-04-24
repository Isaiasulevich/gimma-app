-- Google retired gemini-2.0-flash for new users. Move to gemini-2.5-flash
-- for both the column default and the active row.

alter table public.ai_config
  alter column active_model set default 'gemini-2.5-flash';

update public.ai_config
  set active_model = 'gemini-2.5-flash'
  where id = 'active' and active_model = 'gemini-2.0-flash';
