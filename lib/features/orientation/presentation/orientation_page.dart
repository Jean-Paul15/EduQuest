import 'package:eduquest/features/orientation/data/gemini_orientation_service.dart';
import 'package:eduquest/features/orientation/data/orientation_repository.dart';
import 'package:eduquest/features/orientation/presentation/orientation_page_body.dart';
import 'package:eduquest/features/surveys/domain/survey_question.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:flutter/material.dart';

class OrientationPage extends StatefulWidget {
  const OrientationPage({super.key});
  @override
  State<OrientationPage> createState() => _OrientationPageState();
}

class _OrientationPageState extends State<OrientationPage> {
  final _repo = OrientationRepository();
  final _gemini = GeminiOrientationService();
  final _text = TextEditingController();
  List<SurveyQuestion> _q = const [];
  final Map<String, String> _answers = {};
  int _i = 0;
  bool _loading = true, _sending = false;
  String _result = '';

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _text.dispose(); super.dispose(); }

  Future<void> _load() async {
    final data = await _repo.activeQuestionnaire();
    if (!mounted) return;
    setState(() { _q = data?.$2 ?? const []; _loading = false; });
  }

  Future<void> _next() async {
    final cur = _q[_i];
    final ans = cur.type == 'mcq'
        ? (_answers[cur.id] ?? '')
        : _text.text.trim();
    if (ans.isEmpty) {
      return ModernSnackbar.show(context, 'Reponds avant.', success: false);
    }
    await _repo.submitAnswer(
      questionId: cur.id, questionType: cur.type, answer: ans,
    );
    _answers[cur.id] = ans;
    if (_i < _q.length - 1) {
      setState(() { _i++; _text.text = _answers[_q[_i].id] ?? ''; });
      return;
    }
    await _finish();
  }

  Future<void> _finish() async {
    setState(() => _sending = true);
    final payload = _q
        .map((e) => {'q': e.prompt, 'a': _answers[e.id] ?? ''})
        .toList();
    final text = await _gemini.recommendFromAnswers(payload);
    if (!mounted) return;
    setState(() { _sending = false; _result = text; });
    ModernSnackbar.show(context, 'Orientation terminee.');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_q.isEmpty) {
      return const EmptyState(
        title: 'Aucun questionnaire',
        subtitle: 'Pas de questionnaire orientation actif.',
      );
    }
    return OrientationPageBody(
      questions: _q,
      currentIndex: _i,
      answers: _answers,
      sending: _sending,
      result: _result,
      textController: _text,
      onAnswerSelected: (v) => setState(() => _answers[_q[_i].id] = v),
      onNext: _next,
    );
  }
}
