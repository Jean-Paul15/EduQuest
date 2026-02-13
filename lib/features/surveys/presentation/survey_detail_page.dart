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
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { for (final c in _text.values) { c.dispose(); } super.dispose(); }

  Future<void> _load() async {
    final data = await _repo.questions(widget.id);
    if (!mounted) return;
    setState(() { _q = data; _loading = false; });
  }

  Future<void> _submit(SurveyQuestion q) async {
    final msg = await _repo.submit(questionId: q.id, text: _text[q.id]?.text.trim(), option: _choice[q.id]);
    if (!mounted) return;
    ModernSnackbar.show(context, msg, success: !msg.toLowerCase().contains('non'));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_q.isEmpty) {
      return const Scaffold(body: EmptyState(title: 'Enquete vide', subtitle: 'Aucune question publiee.', icon: Icons.poll_outlined));
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
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
              borderRadius: BorderRadius.circular(AppRadius.card)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(q.prompt, style: const TextStyle(
                fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: AppSpace.s),
              if (q.type == 'mcq') Wrap(spacing: 8, runSpacing: 8, children: q.options.map((o) =>
                ChoiceChip(label: Text(o), selected: _choice[q.id] == o,
                  onSelected: (_) => setState(() => _choice[q.id] = o))).toList()),
              if (q.type == 'text') TextField(controller: ctrl, minLines: 2, maxLines: 4,
                decoration: const InputDecoration(hintText: 'Ta reponse...')),
              const SizedBox(height: AppSpace.s),
              Align(alignment: Alignment.centerRight, child: FilledButton.icon(
                onPressed: () => _submit(q),
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Envoyer'))),
            ]),
          );
        },
      ),
    );
  }
}
