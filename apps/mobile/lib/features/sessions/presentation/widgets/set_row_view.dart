import 'package:flutter/material.dart';

import '../../../../core/db/app_database.dart';

class SetRowView extends StatelessWidget {
  const SetRowView({
    required this.index,
    this.set,
    this.targetWeight,
    this.targetReps,
    this.targetRir,
    this.isActive = false,
    super.key,
  });

  final int index;
  final SetRow? set;
  final double? targetWeight;
  final int? targetReps;
  final int? targetRir;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
      color: set == null && !isActive
          ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
          : theme.colorScheme.onSurface,
    );
    final weight = set?.weight ?? targetWeight;
    final reps = set?.reps ?? targetReps;
    final rir = set?.rir ?? targetRir;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          SizedBox(width: 24, child: Text('$index', style: style)),
          Expanded(child: Text(weight?.toStringAsFixed(1) ?? '—', style: style)),
          Expanded(child: Text(reps?.toString() ?? '—', style: style)),
          Expanded(child: Text(rir?.toString() ?? '—', style: style)),
          SizedBox(
            width: 24,
            child: set != null
                ? Icon(
                    Icons.check,
                    color: theme.colorScheme.primary,
                    size: 18,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class SetHeader extends StatelessWidget {
  const SetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    return Row(
      children: [
        SizedBox(width: 24, child: Text('#', style: labelStyle)),
        Expanded(child: Text('KG', style: labelStyle)),
        Expanded(child: Text('REPS', style: labelStyle)),
        Expanded(child: Text('RIR', style: labelStyle)),
        const SizedBox(width: 24),
      ],
    );
  }
}
