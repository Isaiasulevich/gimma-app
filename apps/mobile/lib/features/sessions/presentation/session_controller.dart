import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import 'today_screen.dart' show sessionRepoProvider;

final sessionExercisesStreamProvider =
    StreamProvider.autoDispose.family<List<SessionExerciseRow>, String>((ref, id) {
  return ref.watch(sessionRepoProvider).watchExercises(id);
});

final currentExerciseProvider =
    Provider.autoDispose.family<SessionExerciseRow?, String>((ref, id) {
  final async = ref.watch(sessionExercisesStreamProvider(id));
  final list = async.value ?? const <SessionExerciseRow>[];
  try {
    return list.firstWhere(
      (SessionExerciseRow e) =>
          e.status == 'pending' || e.status == 'in_progress',
    );
  } catch (_) {
    return null;
  }
});

final skippedExercisesProvider =
    Provider.autoDispose.family<List<SessionExerciseRow>, String>((ref, id) {
  final async = ref.watch(sessionExercisesStreamProvider(id));
  final list = async.value ?? const <SessionExerciseRow>[];
  return list.where((SessionExerciseRow e) => e.status == 'skipped').toList();
});

final setsStreamProvider =
    StreamProvider.autoDispose.family<List<SetRow>, String>((ref, seId) {
  return ref.watch(sessionRepoProvider).watchSets(seId);
});
