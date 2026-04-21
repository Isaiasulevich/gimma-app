import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Stream<AuthState> authStateChanges() => _client.auth.onAuthStateChange;

  Session? currentSession() => _client.auth.currentSession;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    await _client.auth.signUp(email: email, password: password);
  }

  Future<void> signInWithGoogle({
    required String idToken,
    required String accessToken,
  }) async {
    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  Future<void> signOut() => _client.auth.signOut();
}
