import 'dart:async';
import 'package:eduquest/features/auth/data/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository({
    this.signInError,
    this.signUpOutcome = const SignUpOutcome(
      accountCreated: true,
      signedIn: true,
      emailConfirmationPending: false,
    ),
  });

  final Object? signInError;
  final SignUpOutcome signUpOutcome;
  final events = StreamController<AuthState>.broadcast();
  String? lastEmail, lastPassword, resetEmail;

  @override
  bool get isConfigured => true;

  @override
  Stream<AuthState> get authStream => events.stream;

  @override
  User? get currentUser => null;

  @override
  Future<void> signInWithEmail(String email, String password) async {
    if (signInError != null) throw signInError!;
    lastEmail = email;
    lastPassword = password;
  }

  @override
  Future<SignUpOutcome> signUpWithEmail(String email, String password) async {
    lastEmail = email;
    lastPassword = password;
    return signUpOutcome;
  }

  @override
  Future<void> resetPassword(String email) async => resetEmail = email;
}
