import 'package:flutter/material.dart';

const kAllMuscles = [
  'chest', 'upper_back', 'lats', 'traps', 'lower_back',
  'front_delts', 'side_delts', 'rear_delts',
  'biceps', 'triceps', 'forearms',
  'quads', 'hamstrings', 'glutes', 'calves', 'adductors', 'abductors',
  'abs', 'obliques', 'neck', 'core',
];

class MusclePicker extends StatelessWidget {
  const MusclePicker({
    required this.selected,
    required this.onChanged,
    this.multi = false,
    super.key,
  });

  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final bool multi;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: kAllMuscles.map((m) {
        final isSelected = selected.contains(m);
        return FilterChip(
          label: Text(m.replaceAll('_', ' ')),
          selected: isSelected,
          onSelected: (_) {
            final next = {...selected};
            if (multi) {
              if (isSelected) {
                next.remove(m);
              } else {
                next.add(m);
              }
            } else {
              next
                ..clear()
                ..add(m);
            }
            onChanged(next);
          },
        );
      }).toList(),
    );
  }
}
