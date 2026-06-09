import 'package:eduquest/features/surveys/domain/survey_question.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'survey_question_card.dart';

class SurveyDetailView extends StatelessWidget {
  const SurveyDetailView({
    super.key,
    required this.title,
    required this.loading,
    required this.questions,
    required this.isSending,
    required this.onSubmit,
    required this.getChoice,
    required this.getController,
    required this.isAnswered,
    required this.onChoiceSelected,
  });
  final String title;
  final bool loading;
  final List<SurveyQuestion> questions;
  final bool isSending;
  final VoidCallback onSubmit;
  final String? Function(String qId) getChoice;
  final TextEditingController Function(String qId) getController;
  final bool Function(SurveyQuestion q) isAnswered;
  final void Function(String qId, String choice) onChoiceSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (loading || questions.isEmpty)
          ? null
          : RuachAppBar(title: title, showBack: true),
      bottomNavigationBar: _submitBar(),
      body: _body(context),
    );
  }

  Widget? _submitBar() {
    if (loading || questions.isEmpty) return null;
    return SafeArea(
      minimum: const EdgeInsets.all(RuachSpace.s4),
      child: RuachButton(
        label: isSending ? 'Envoi...' : 'Envoyer toutes les réponses',
        onPressed: isSending ? null : onSubmit,
        icon: PhosphorIconsRegular.paperPlaneTilt,
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (questions.isEmpty) {
      return const EmptyState(
        title: 'Enquete vide',
        subtitle: 'Aucune question publiee.',
        icon: PhosphorIconsRegular.chartBar,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(RuachSpace.s4),
      itemCount: questions.length,
      separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s3),
      itemBuilder: (_, i) {
        final q = questions[i];
        return SurveyQuestionCard(
          question: q,
          controller: getController(q.id),
          selectedChoice: getChoice(q.id),
          answered: isAnswered(q),
          onChoiceSelected: (choice) => onChoiceSelected(q.id, choice),
        );
      },
    );
  }
}
