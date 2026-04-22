import 'package:flutter/material.dart';

import '../../../../core/db/app_database.dart';

class ExerciseTile extends StatelessWidget {
  const ExerciseTile({required this.exercise, this.onTap, super.key});

  final ExerciseRow exercise;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Text(exercise.primaryMuscle.substring(0, 1).toUpperCase()),
      ),
      title: Text(exercise.name),
      subtitle: Text('${exercise.primaryMuscle} · ${exercise.equipment}'),
      trailing: exercise.source == 'user'
          ? const Icon(Icons.person_outline, size: 18)
          : null,
    );
  }
}
