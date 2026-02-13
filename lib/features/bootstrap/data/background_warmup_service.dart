import 'dart:async';
import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/engagement/data/live_classes_repository.dart';
import 'package:eduquest/features/learning/data/learning_warmup_service.dart';
import 'package:eduquest/features/learning/domain/learning_section.dart';

class BackgroundWarmupService {
  final _learning = LearningWarmupService();
  final _engagement = EngagementRepository();
  final _lives = LiveClassesRepository();
  static bool _running = false;

  Future<void> run() async {
    if (_running) return;
    _running = true;
    await _step(() => _learning.warmSection(LearningSection.courses));
    await _step(() => _learning.warmSection(LearningSection.exams));
    await _step(() => _learning.warmSection(LearningSection.epreuves));
    await _step(() => _learning.warmSection(LearningSection.mockExams));
    await _step(() => _lives.list());
    await _step(() => _engagement.listContests());
    await _step(() => _engagement.listEvents());
    await _step(() => _engagement.listSurveys());
    _running = false;
  }

  Future<void> _step(Future<dynamic> Function() action) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    try {
      await action();
    } catch (_) {}
  }
}
