import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/exercises/presentation/create_exercise_screen.dart';
import '../../features/exercises/presentation/exercise_detail_screen.dart';
import '../../features/exercises/presentation/exercise_list_screen.dart';
import '../../features/history/presentation/history_detail_screen.dart';
import '../../features/history/presentation/history_tab.dart';
import '../../features/sessions/presentation/finish_screen.dart';
import '../../features/sessions/presentation/session_screen.dart';
import '../../features/sessions/presentation/today_screen.dart';
import '../shell/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/train',
    redirect: (context, state) {
      final isAuthed = Supabase.instance.client.auth.currentSession != null;
      final goingToSignIn = state.matchedLocation == '/sign-in';
      if (!isAuthed && !goingToSignIn) return '/sign-in';
      if (isAuthed && goingToSignIn) return '/train';
      return null;
    },
    refreshListenable:
        GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),
    routes: [
      GoRoute(path: '/sign-in', builder: (_, _) => const SignInScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/train', builder: (_, _) => const TodayScreen()),
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
      // Full-screen (pushed on top of the shell)
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
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
