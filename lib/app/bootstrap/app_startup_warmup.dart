import 'dart:async';
import 'package:eduquest/app/bootstrap/offline_session_gate.dart';
import 'package:eduquest/features/home/presentation/home_controller.dart';
import 'package:eduquest/features/learning/data/learning_security_repository.dart';
import 'package:eduquest/features/legal/data/legal_repository.dart';
import 'package:eduquest/features/learning/data/learning_warmup_service.dart';
import 'package:eduquest/features/learning/domain/learning_section.dart';
import 'package:eduquest/features/surveys/data/survey_reminder_service.dart';
import 'package:eduquest/features/user/data/user_profile_repository.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppStartupWarmup {
  final _gate = OfflineSessionGate();
  final _home = HomeController();
  final _learning = LearningWarmupService();
  final _security = LearningSecurityRepository();
  final _legal = LegalRepository();
  final _user = UserProfileRepository();
  final _surveyReminder = SurveyReminderService();

  Future<void> run() async {
    if (!Env.hasSupabase) return;
    if (Supabase.instance.client.auth.currentUser != null) {
      await _gate.markSeen();
    }
    await _step(_user.load, ms: 900);
    await _step(_home.refresh, ms: 1200);
    await _step(_security.load, ms: 500);
    await _step(() => _learning.warmSection(LearningSection.courses), ms: 900);
    await _step(() => _legal.load('terms'), ms: 500);
    await _step(() => _legal.load('privacy'), ms: 500);
    await _step(_surveyReminder.remindIfNeeded, ms: 800);
  }

  Future<void> _step(Future<dynamic> Function() fn, {required int ms}) async {
    try {
      await fn().timeout(Duration(milliseconds: ms));
    } catch (_) {}
  }
}
