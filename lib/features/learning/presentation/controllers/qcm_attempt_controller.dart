import 'dart:async';
import 'package:eduquest/features/learning/data/learning_content_repository.dart';
import 'package:eduquest/features/learning/domain/qcm_question.dart';
import 'package:flutter/foundation.dart';

class QcmAttemptController extends ChangeNotifier {
  QcmAttemptController(this.quizId);
  final String quizId;
  static const perQuestion = 20;
  final _repo = LearningContentRepository();
  final answers = <String, String>{}, spent = <String, int>{};
  List<QcmQuestion> questions = const [];
  Timer? _timer;
  bool loading = true, locked = false, timeout = false;
  int index = 0, left = perQuestion;
  String? selected;

  bool get done =>
      !loading && questions.isNotEmpty && index >= questions.length;
  int get correct => questions.where((x) => answers[x.id] == x.answer).length;
  int get total => questions.length;
  int get wrong => answers.length - correct;
  int get skipped => total - answers.length;
  int get seconds => spent.values.fold(0, (a, b) => a + b);
  QcmQuestion get current => questions[index];

  Future<void> load() async {
    questions = await _repo.questions(quizId);
    loading = false;
    notifyListeners();
    if (questions.isNotEmpty) _start();
  }

  void _start() {
    _timer?.cancel();
    left = perQuestion;
    selected = null;
    locked = false;
    timeout = false;
    notifyListeners();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (locked) return;
      if (left <= 1) {
        onTimeout();
        return;
      }
      left--;
      notifyListeners();
    });
  }

  Future<void> pick(String o) async {
    if (locked) return;
    _timer?.cancel();
    answers[current.id] = o;
    spent[current.id] = perQuestion - left;
    selected = o;
    locked = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 850));
    _next();
  }

  Future<void> onTimeout() async {
    if (locked) return;
    _timer?.cancel();
    spent[current.id] = perQuestion;
    locked = true;
    timeout = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 700));
    _next();
  }

  void restart() {
    answers.clear();
    spent.clear();
    index = 0;
    _start();
  }

  void _next() {
    if (index + 1 >= questions.length) {
      index = questions.length;
      notifyListeners();
      return;
    }
    index++;
    _start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
