# Design system

Empty scaffold — **reserved for the post-v1 design-system pass**.

## Intent

Build v1 features using Flutter's ThemeData + raw primitives (`FilledButton`,
`Card`, `TextField`), styled only via `Theme.of(context)`. Never hardcode
colors or font sizes in feature code.

After v1 ships, wrap those primitives in our own components here:

- `components/app_button.dart` — consistent state handling, sizing, icon variants
- `components/app_card.dart` — consistent padding, elevation, radius
- `components/app_text_field.dart` — consistent decoration, error state
- `components/app_pill.dart` — status pills (sync, session focus, muscle chips)
- `components/app_list_tile.dart` — exercise rows, plan-day cards
- `tokens.dart` — spacing constants, radii, durations, icon sizes

And a grep-replace pass swaps every `FilledButton` → `AppButton`, every
`Card` → `AppCard`, etc. Because feature code never hardcoded styling, this
is mostly mechanical.

## Guidelines for feature code during v1

- Use `Theme.of(context).colorScheme.*` and `.textTheme.*` for all colors + fonts
- Small composable sub-widgets (`_SetRow`, `_HeaderCard`) over 200-line `build()` methods
- A `const _gap = 8.0;` at the top of a widget file if you use spacing repeatedly
- If you find yourself writing `TextStyle(...)` inline, pause and ask whether it's
  a one-off or something that belongs in the design system later
