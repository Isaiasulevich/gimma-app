import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/coach/presentation/coach_tab.dart';
import '../../features/exercises/presentation/create_exercise_screen.dart';
import '../../features/exercises/presentation/exercise_detail_screen.dart';
import '../../features/exercises/presentation/exercise_list_screen.dart';
import '../../features/history/presentation/history_detail_screen.dart';
import '../../features/history/presentation/history_tab.dart';
import '../../features/onboarding/data/onboarding_state_provider.dart';
import '../../features/onboarding/presentation/generating_plan_screen.dart';
import '../../features/onboarding/presentation/guided_qa_screen.dart';
import '../../features/onboarding/presentation/mode_picker_screen.dart';
import '../../features/onboarding/presentation/observe_qa_screen.dart';
import '../../features/sessions/presentation/finish_screen.dart';
import '../../features/sessions/presentation/session_screen.dart';
import '../../features/sessions/presentation/today_screen.dart';
import '../shell/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/train',
    redirect: (context, state) {
      final isAuthed = Supabase.instance.client.auth.currentSession != null;
      final loc = state.matchedLocation;

      if (!isAuthed) {
        return loc == '/sign-in' ? null : '/sign-in';
      }

      // Authed: check onboarding completion (cached).
      final onboardingAsync = ref.read(onboardingCompleteProvider);
      final onboardingComplete = onboardingAsync.asData?.value;
      final onOnboarding = loc.startsWith('/onboarding');

      // While loading, don't redirect — avoids flicker.
      if (onboardingComplete == null) {
        if (loc == '/sign-in') return '/train';
        return null;
      }

      if (!onboardingComplete && !onOnboarding) return '/onboarding';
      if (onboardingComplete && onOnboarding) return '/train';
      if (loc == '/sign-in') return '/train';
      return null;
    },
    refreshListenable: GoRouterRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange,
      onRefresh: () => ref.invalidate(onboardingCompleteProvider),
    ),
    routes: [
      GoRoute(path: '/sign-in', builder: (_, _) => const SignInScreen()),
      // Onboarding routes are outside the shell (full-screen, no bottom nav).
      GoRoute(
        path: '/onboarding',
        builder: (_, _) => const ModePickerScreen(),
      ),
      GoRoute(
        path: '/onboarding/guided',
        builder: (_, _) => const GuidedQaScreen(),
      ),
      GoRoute(
        path: '/onboarding/observe',
        builder: (_, _) => const ObserveQaScreen(),
      ),
      GoRoute(
        path: '/onboarding/generating',
        builder: (_, _) => const GeneratingPlanScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/train', builder: (_, _) => const TodayScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/coach', builder: (_, _) => const CoachTab()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/history', builder: (_, _) => const HistoryTab()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/exercises',
              builder: (_, _) => const ExerciseListScreen(),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: '/exercises/new',
        builder: (_, _) => const CreateExerciseScreen(),
      ),
      GoRoute(
        path: '/exercises/:id',
        builder: (_, state) =>
            ExerciseDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/session/:id',
        builder: (_, state) =>
            SessionScreen(sessionId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/session/:id/finish',
        builder: (_, state) =>
            FinishScreen(sessionId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/history/:id',
        builder: (_, state) =>
            HistoryDetailScreen(sessionId: state.pathParameters['id']!),
      ),
    ],
  );
});

/// Bridges a Stream to a Listenable so GoRouter refreshes on auth changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream, {this.onRefresh}) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) {
      onRefresh?.call();
      notifyListeners();
    });
  }
  late final StreamSubscription<dynamic> _sub;
  final VoidCallback? onRefresh;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
