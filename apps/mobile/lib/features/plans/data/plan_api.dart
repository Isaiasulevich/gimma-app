import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlanApi {
  PlanApi(this._client);
  final SupabaseClient _client;

  /// Calls the `generate-plan` edge function and returns the resulting
  /// plan_id. Throws if the function returns a non-2xx status.
  Future<String> generatePlan({
    required String goal,
    required String experienceLevel,
    required int daysPerWeek,
    required int sessionLengthMinutes,
    required String equipment,
    required List<String> injuries,
    String? styleNotes,
  }) async {
    try {
      final res = await _client.functions.invoke(
        'generate-plan',
        body: {
          'goal': goal,
          'experience_level': experienceLevel,
          'days_per_week': daysPerWeek,
          'session_length_minutes': sessionLengthMinutes,
          'equipment': equipment,
          'injuries': injuries,
          if (styleNotes != null && styleNotes.isNotEmpty)
            'style_notes': styleNotes,
        },
      );
      if (res.status >= 400) {
        throw Exception('generate-plan failed (${res.status}): ${res.data}');
      }
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Unexpected response: $data');
      }
      final planId = data['plan_id'];
      if (planId is! String) {
        throw Exception('Missing plan_id in response: $data');
      }
      return planId;
    } catch (e, stackTrace) {
      // Safe no-op if Sentry isn't initialized.
      await Sentry.captureException(e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
