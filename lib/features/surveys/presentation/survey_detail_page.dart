import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/surveys/data/survey_repository.dart';
import 'package:eduquest/features/surveys/domain/survey_question.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:flutter/material.dart';

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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_q.isEmpty) {
      return const Scaffold(
        body: EmptyState(
          title: 'Enquete vide',
          subtitle: 'Aucune question publiee.',
          icon: Icons.poll_outlined,
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppSpace.l),
        child: FilledButton.icon(
          onPressed: _sending ? null : _submitAll,
          icon: const Icon(Icons.send_rounded, size: 18),
          label: Text(_sending ? 'Envoi...' : 'Envoyer toutes les réponses'),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpace.l),
        itemCount: _q.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpace.m),
        itemBuilder: (_, i) {
          final q = _q[i];
          final ctrl = _text.putIfAbsent(q.id, TextEditingController.new);
          return Container(
            padding: const EdgeInsets.all(AppSpace.m),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q.prompt,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpace.s),
                if (q.type == 'mcq')
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: q.options.map((o) {
                      final selected = _choice[q.id] == o;
                      final dark =
                          Theme.of(context).brightness == Brightness.dark;
                      return ChoiceChip(
                        label: Text(o),
                        selected: selected,
                        showCheckmark: false,
                        selectedColor: AppColors.primary,
                        backgroundColor: dark
                            ? AppColors.inputDark
                            : AppColors.canvasLight,
                        side: BorderSide(
                          color: selected
                              ? AppColors.primary
                              : AppColors.divider,
                        ),
                        labelStyle: TextStyle(
                          color: selected
                              ? AppColors.white
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (_) => setState(() => _choice[q.id] = o),
                      );
                    }).toList(),
                  ),
                if (q.type == 'text')
                  TextField(
                    controller: ctrl,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Ta reponse...',
                    ),
                  ),
                const SizedBox(height: AppSpace.xs),
                Row(
                  children: [
                    Icon(
                      _answered(q)
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 16,
                      color: _answered(q)
                          ? AppColors.success
                          : AppColors.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _answered(q) ? 'Répondu' : 'À compléter',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
