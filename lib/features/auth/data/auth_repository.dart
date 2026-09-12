import 'package:eduquest/app/bootstrap/offline_session_gate.dart';
import 'package:eduquest/features/notifications/data/notification_service.dart';
import 'package:eduquest/features/session/data/device_session_service.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpOutcome {
  const SignUpOutcome({
    required this.accountCreated,
    required this.signedIn,
    required this.emailConfirmationPending,
  });

  final bool accountCreated;
  final bool signedIn;
  final bool emailConfirmationPending;
}

class AuthRepository {
  final _offlineGate = OfflineSessionGate();
  final _notifications = NotificationService();
  final _session = DeviceSessionService();
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
    final uid = Supabase.instance.client.auth.currentUser?.id;
    await _notifications.clearExternalUserId();
    await Supabase.instance.client.auth.signOut();
    await _offlineGate.clear();
    if (uid != null) await _session.clearLocalState(uid);
  }

  Future<void> signInWithEmail(String email, String password) async {
    if (!isConfigured) return;
    await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    await _offlineGate.markSeen();
  }

  Future<SignUpOutcome> signUpWithEmail(String email, String password) async {
    if (!isConfigured) {
      return const SignUpOutcome(
        accountCreated: false,
        signedIn: false,
        emailConfirmationPending: false,
      );
    }
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
    await _offlineGate.markSeen();
    final signedIn =
        response.session != null ||
        Supabase.instance.client.auth.currentSession != null;
    return SignUpOutcome(
      accountCreated: response.user != null,
      signedIn: signedIn,
      emailConfirmationPending: response.user != null && !signedIn,
    );
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
