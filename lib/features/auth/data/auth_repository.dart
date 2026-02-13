import 'package:eduquest/app/bootstrap/offline_session_gate.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final _offlineGate = OfflineSessionGate();
  bool get isConfigured => Env.hasSupabase;
  User? get currentUser =>
      isConfigured ? Supabase.instance.client.auth.currentUser : null;
  Stream<AuthState> get authStream =>
      Supabase.instance.client.auth.onAuthStateChange;

  Future<void> signInWithGoogle() async {
    await _oauth(OAuthProvider.google);
  }

  Future<void> signInWithApple() async {
    await _oauth(OAuthProvider.apple);
  }

  Future<void> signOut() async {
    if (!isConfigured) return;
    await Supabase.instance.client.auth.signOut();
    await _offlineGate.clear();
  }

  Future<void> signInWithEmail(String email, String password) async {
    if (!isConfigured) return;
    await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    await _offlineGate.markSeen();
  }

  Future<void> signUpWithEmail(String email, String password) async {
    if (!isConfigured) return;
    await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
    await _offlineGate.markSeen();
  }

  Future<void> resetPassword(String email) async {
    if (!isConfigured) return;
    await Supabase.instance.client.auth.resetPasswordForEmail(
      email,
      redirectTo: Env.oauthRedirectUrl.isEmpty ? null : Env.oauthRedirectUrl,
    );
  }

  Future<void> _oauth(OAuthProvider provider) async {
    if (!isConfigured) return;
    await Supabase.instance.client.auth.signInWithOAuth(
      provider,
      redirectTo: Env.oauthRedirectUrl.isEmpty ? null : Env.oauthRedirectUrl,
      authScreenLaunchMode: kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode.externalApplication,
    );
  }
}
