import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'onboarding_repository.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => OnboardingRepository(Supabase.instance.client),
);

/// Cached onboarding-complete state for the current user.
/// Returns `true` when onboarding_completed_at is set, `false` otherwise.
/// Returns `null` while loading or when no user is signed in.
final onboardingCompleteProvider = FutureProvider.autoDispose<bool?>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return null;
  final profile = await ref.watch(onboardingRepositoryProvider).getProfile(user.id);
  return profile?['onboarding_completed_at'] != null;
});
