import 'package:supabase_flutter/supabase_flutter.dart';

import 'hydrator.dart';

class SupabaseHydrateSource implements HydrateSource {
  SupabaseHydrateSource(this._client);
  final SupabaseClient _client;

  @override
  Future<List<Map<String, dynamic>>> fetchActivePlan(String userId) async {
    final rows = await _client
        .from('plans')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true);
    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPlanDays(List<String> planIds) async {
    if (planIds.isEmpty) return [];
    final rows = await _client.from('plan_days').select().inFilter('plan_id', planIds);
    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPrescriptions(List<String> dayIds) async {
    if (dayIds.isEmpty) return [];
    final rows = await _client
        .from('plan_prescriptions')
        .select()
        .inFilter('plan_day_id', dayIds);
    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchRecentSessions(
    String userId,
    Duration window,
  ) async {
    final cutoff = DateTime.now().toUtc().subtract(window).toIso8601String();
    final rows = await _client
        .from('sessions')
        .select()
        .eq('user_id', userId)
        .gte('started_at', cutoff);
    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchVisibleExercises(String userId) async {
    final rows = await _client.from('exercises').select().eq('is_archived', false);
    return List<Map<String, dynamic>>.from(rows);
  }
}
