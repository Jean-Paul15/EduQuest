import 'package:eduquest/features/auth/data/auth_repository.dart';
import 'package:eduquest/shared/config/env.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeRealtime {
  final AuthRepository _auth;
  RealtimeChannel? _channel;
  Timer? _debounce;

  HomeRealtime(this._auth);

  void subscribe(void Function() onChange) {
    if (!Env.hasSupabase) return;
    final uid = _auth.currentUser?.id;
    if (uid == null) return;
    void trigger() {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 450), onChange);
    }
    final c = Supabase.instance.client;
    _channel = c
        .channel('home-$uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'gamification_profiles',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'profile_id',
            value: uid,
          ),
          callback: (_) => trigger(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'ticket_codes',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'activated_by',
            value: uid,
          ),
          callback: (_) => trigger(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'quest_completions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'profile_id',
            value: uid,
          ),
          callback: (_) => trigger(),
        )
        .subscribe();
  }

  void unsubscribe() {
    _debounce?.cancel();
    final ch = _channel;
    if (ch == null) return;
    Supabase.instance.client.removeChannel(ch);
    _channel = null;
  }
}
