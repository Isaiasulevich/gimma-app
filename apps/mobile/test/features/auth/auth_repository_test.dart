import 'package:flutter_test/flutter_test.dart';
import 'package:gimma/features/auth/data/auth_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}
class _MockGoTrueClient extends Mock implements GoTrueClient {}
class _FakeAuthResponse extends Fake implements AuthResponse {}

void main() {
  late _MockSupabaseClient client;
  late _MockGoTrueClient auth;
  late AuthRepository repo;

  setUpAll(() {
    registerFallbackValue(OAuthProvider.google);
  });

  setUp(() {
    client = _MockSupabaseClient();
    auth = _MockGoTrueClient();
    when(() => client.auth).thenReturn(auth);
    repo = AuthRepository(client);
  });

  test('signInWithEmail calls auth.signInWithPassword', () async {
    when(() => auth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => _FakeAuthResponse());

    await repo.signInWithEmail(email: 'a@b.com', password: 'secret');

    verify(() => auth.signInWithPassword(email: 'a@b.com', password: 'secret'))
        .called(1);
  });

  test('signUpWithEmail calls auth.signUp', () async {
    when(() => auth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => _FakeAuthResponse());

    await repo.signUpWithEmail(email: 'a@b.com', password: 'secret');

    verify(() => auth.signUp(email: 'a@b.com', password: 'secret')).called(1);
  });

  test('signOut calls auth.signOut', () async {
    when(() => auth.signOut()).thenAnswer((_) async {});

    await repo.signOut();

    verify(() => auth.signOut()).called(1);
  });
}
