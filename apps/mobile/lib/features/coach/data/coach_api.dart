import 'package:supabase_flutter/supabase_flutter.dart';

class CoachApi {
  CoachApi(this._client);
  final SupabaseClient _client;

  Future<Map<String, dynamic>?> latestWeeklySummary(String userId) async {
    final data = await _client
        .from('weekly_summaries')
        .select()
        .eq('user_id', userId)
        .order('week_start', ascending: false)
        .limit(1)
        .maybeSingle();
    return data;
  }

  Future<String> reviewNow() async {
    final res = await _client.functions.invoke('review-now');
    if (res.status >= 400) {
      throw Exception('review-now failed: ${res.data}');
    }
    return (res.data as Map<String, dynamic>)['summary_md'] as String;
  }
}
