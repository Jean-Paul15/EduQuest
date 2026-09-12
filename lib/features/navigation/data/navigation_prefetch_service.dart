import 'dart:async';
import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/engagement/data/live_classes_repository.dart';
import 'package:eduquest/features/home/presentation/home_controller.dart';
import 'package:eduquest/features/learning/data/learning_catalog_repository.dart';
import 'package:eduquest/features/learning/data/learning_warmup_service.dart';
import 'package:eduquest/features/learning/domain/learning_section.dart';
import 'package:eduquest/features/marketplace/data/marketplace_repository.dart';
import 'package:eduquest/features/notifications/data/notification_preferences_repository.dart';
import 'package:eduquest/features/orientation/data/orientation_repository.dart';
import 'package:eduquest/features/referral/data/referral_repository.dart';
import 'package:eduquest/features/user/data/user_profile_repository.dart';

class NavigationPrefetchService {
  final _home = HomeController();
  final _catalog = LearningCatalogRepository();
  final _learning = LearningWarmupService();
  final _engagement = EngagementRepository();
  final _lives = LiveClassesRepository();
  final _orientation = OrientationRepository();
  final _market = MarketplaceRepository();
  final _referral = ReferralRepository();
  final _profile = UserProfileRepository();
  final _prefs = NotificationPreferencesRepository();
  final Map<String, Future<void>> _pending = {};

  Future<void> tab(int index) => _run('tab:$index', () async {
    if (index == 0) {
      await _home.refresh();
      return;
    }
    if (index == 1) {
      await Future.wait([
        _profile.load(),
        _catalog.subjectsForCourses(),
        _engagement.listContests(),
        _engagement.listEvents(),
      ]);
      return;
    }
    if (index == 2) {
      await Future.wait(LearningSection.values.map(_learning.warmSection));
      return;
    }
    if (index == 3) {
      await Future.wait([
        _lives.list(),
        _engagement.listContests(),
        _engagement.listEvents(),
        _engagement.listSurveys(),
        Future<void>(() async {
          try {
            await _orientation.activeQuestionnaire();
          } catch (_) {}
        }),
        _market.search(limit: 30),
      ]);
      return;
    }
    await Future.wait([
      _profile.load(),
      _prefs.get(),
      _referral.myCode(),
      _referral.invitedCount(),
    ]);
  });

  Future<void> neighbors(int index) async {
    final targets = <int>{if (index > 0) index - 1, if (index < 4) index + 1};
    await Future.wait(targets.map(tab));
  }

  Future<void> learningSection(LearningSection section) =>
      _run('learn:${section.name}', () => _learning.warmSection(section));

  Future<void> _run(String key, Future<void> Function() task) {
    final running = _pending[key];
    if (running != null) return running;
    final f = task()
        .catchError((_) {})
        .whenComplete(() => _pending.remove(key));
    _pending[key] = f;
    return f;
  }
}
