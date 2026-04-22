import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/exercises/presentation/create_exercise_screen.dart';
import '../../features/exercises/presentation/exercise_detail_screen.dart';
import '../../features/exercises/presentation/exercise_list_screen.dart';
import '../../features/home/presentation/home_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthed = Supabase.instance.client.auth.currentSession != null;
      final goingToSignIn = state.matchedLocation == '/sign-in';
      if (!isAuthed && !goingToSignIn) return '/sign-in';
      if (isAuthed && goingToSignIn) return '/';
      return null;
    },
    refreshListenable:
        GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),
    routes: [
      GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
      GoRoute(path: '/sign-in', builder: (_, _) => const SignInScreen()),
      GoRoute(path: '/exercises', builder: (_, _) => const ExerciseListScreen()),
      GoRoute(
        path: '/exercises/new',
        builder: (_, _) => const CreateExerciseScreen(),
      ),
      GoRoute(
        path: '/exercises/:id',
        builder: (_, state) =>
            ExerciseDetailScreen(id: state.pathParameters['id']!),
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
