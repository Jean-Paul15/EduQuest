import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/surveys/data/survey_repository.dart';
import 'package:eduquest/features/surveys/domain/survey_question.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:flutter/material.dart';
import 'survey_detail_view.dart';

class SurveyDetailPage extends StatefulWidget {
  const SurveyDetailPage({super.key, required this.id, required this.title});
  final String id;
  final String title;
  @override
  State<SurveyDetailPage> createState() => _SurveyDetailPageState();
}
class _SurveyDetailPageState extends State<SurveyDetailPage> {
  final _repo = SurveyRepository();
  final Map<String, TextEditingController> _text = {};
  final Map<String, String> _choice = {};
  List<SurveyQuestion> _q = const [];
  bool _loading = true, _sending = false;
  @override
  void initState() {
    super.initState();
    _load();
  }
  @override
  void dispose() {
    for (final c in _text.values) {
      c.dispose();
    }
    super.dispose();
  }
  Future<void> _load() async {
    final data = await _repo.questions(widget.id);
    if (!mounted) return;
    setState(() {
      _q = data;
      _loading = false;
    });
  }
  bool _answered(SurveyQuestion q) {
    if (q.type == 'mcq') return (_choice[q.id] ?? '').trim().isNotEmpty;
    return (_text[q.id]?.text.trim() ?? '').isNotEmpty;
  }
  Future<void> _submitAll() async {
    if (_sending) return;
    final missing = _q.where((q) => !_answered(q)).length;
    if (missing > 0) {
      ModernSnackbar.show(
        context,
        'Complète toutes les questions avant envoi.',
        success: false,
      );
      return;
    }
    setState(() => _sending = true);
    final answers = _q
        .map((q) {
          final opt = _choice[q.id];
          return {
            'question_id': q.id,
            'answer_text': q.type == 'text' ? _text[q.id]?.text.trim() : null,
            'answer_json': opt == null
                ? <String, dynamic>{}
                : {'selected': opt},
          };
        })
        .toList(growable: false);
    final msg = await _repo.submitAll(answers);
    if (!mounted) return;
    setState(() => _sending = false);
    final ok =
        !msg.toLowerCase().contains('non') &&
        !msg.toLowerCase().contains('impossible');
    ModernSnackbar.show(context, msg, success: ok);
    if (ok) {
      await EngagementRepository().clearSurveysCache();
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }
  @override
  Widget build(BuildContext context) {
    return SurveyDetailView(
      title: widget.title,
      loading: _loading,
      questions: _q,
      isSending: _sending,
      onSubmit: _submitAll,
      getChoice: (qId) => _choice[qId],
      getController: (qId) =>
          _text.putIfAbsent(qId, TextEditingController.new),
      isAnswered: _answered,
      onChoiceSelected: (qId, choice) =>
          setState(() => _choice[qId] = choice),
    );
  }
}
