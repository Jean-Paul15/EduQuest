import 'package:eduquest/features/learning/presentation/controllers/qcm_attempt_controller.dart';
import 'package:eduquest/features/learning/presentation/widgets/qcm_question_stage.dart';
import 'package:eduquest/features/learning/presentation/widgets/qcm_result_panel.dart';
import 'package:flutter/material.dart';

class QcmAttemptPage extends StatefulWidget {
  const QcmAttemptPage({super.key, required this.quizId, required this.title});
  final String quizId;
  final String title;
  @override
  State<QcmAttemptPage> createState() => _QcmAttemptPageState();
}

class _QcmAttemptPageState extends State<QcmAttemptPage> {
  late final QcmAttemptController _c;
  @override
  void initState() {
    super.initState();
    _c = QcmAttemptController(widget.quizId)..load();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        if (_c.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (_c.questions.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.title)),
            body: const Center(child: Text('Aucune question disponible.')),
          );
        }
        if (_c.done) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.title)),
            body: QcmResultPanel(
              total: _c.total,
              correct: _c.correct,
              wrong: _c.wrong,
              skipped: _c.skipped,
              seconds: _c.seconds,
              onRetry: _c.restart,
            ),
          );
        }
        return QcmQuestionStage(
          title: widget.title,
          index: _c.index,
          total: _c.total,
          left: _c.left,
          question: _c.current,
          locked: _c.locked,
          selected: _c.selected,
          timeout: _c.timeout,
          onPick: _c.pick,
        );
      },
    );
  }
}
