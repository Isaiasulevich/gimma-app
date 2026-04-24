import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingRepository {
  OnboardingRepository(this._client);
  final SupabaseClient _client;

  Future<void> setMode({
    required String userId,
    required String mode, // 'guided' | 'observe'
    required String goal,
    String? experienceLevel,
  }) async {
    await _client.from('users').update({
      'onboarding_mode': mode,
      'goal': goal,
      // ignore: use_null_aware_elements
      if (experienceLevel != null) 'experience_level': experienceLevel,
    }).eq('id', userId);
  }

  Future<void> markComplete(String userId) async {
    await _client.from('users').update({
      'onboarding_completed_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', userId);
  }

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final data =
        await _client.from('users').select().eq('id', userId).maybeSingle();
    return data;
  }

  Future<int> loggedSessionCount(String userId) async {
    final rows = await _client
        .from('sessions')
        .select('id')
        .eq('user_id', userId)
        .eq('status', 'completed');
    return rows.length;
  }

  Future<int> daysSinceSignup(String userId) async {
    final profile = await getProfile(userId);
    if (profile == null) return 0;
    final created = DateTime.parse(profile['created_at'] as String);
    return DateTime.now().toUtc().difference(created).inDays;
  }
}
