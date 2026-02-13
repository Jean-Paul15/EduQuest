import 'package:eduquest/features/orientation/data/gemini_orientation_service.dart';
import 'package:eduquest/features/orientation/data/orientation_repository.dart';
import 'package:eduquest/features/surveys/domain/survey_question.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
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
    final cur = _q[_i];
    return ListView(padding: const EdgeInsets.all(20), children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: (_i + 1) / _q.length,
          minHeight: 4,
          backgroundColor: AppColors.divider,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'Question ${_i + 1} / ${_q.length}',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        cur.prompt,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
      ),
      const SizedBox(height: 14),
      if (cur.type == 'mcq')
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cur.options
              .map((o) => ChoiceChip(
                    label: Text(o),
                    selected: _answers[cur.id] == o,
                    onSelected: (_) =>
                        setState(() => _answers[cur.id] = o),
                  ))
              .toList(),
        ),
      if (cur.type == 'text')
        TextField(
          controller: _text,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Ta reponse...'),
        ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: _sending ? null : _next,
          child: Text(
            _sending
                ? 'Analyse...'
                : (_i == _q.length - 1 ? 'Terminer' : 'Suivant'),
          ),
        ),
      ),
      if (_result.isNotEmpty) ...[
        const SizedBox(height: 16),
        Text(
          _result,
          style: const TextStyle(
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ],
    ]);
  }
}
