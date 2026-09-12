import 'package:flutter/material.dart';
import '../quiz_controller_interface.dart';
import '../constants.dart';
import '../quiz_icons.dart';
import 'quiz_action_button.dart';

/// Bottom navigation bar for the quiz: skip + validate/next/finish buttons.
class QuizBottomBar extends StatefulWidget {
  const QuizBottomBar({
    super.key,
    required this.controller,
    this.showValidateStep = false,
  });
  final QuizControllerInterface controller;

  /// Vrai seulement pour singleChoice/trueFalse/multiChoice quand un
  /// feedback immédiat est configuré pour ce quiz — le bouton principal
  /// affiche alors "Valider" tant que rien n'est soumis (activé dès qu'un
  /// [QuizControllerInterface.draftAnswer] existe), puis "Continuer" une
  /// fois verrouillé. Sinon (autres types de question, ou pas de feedback
  /// immédiat configuré), il n'y a jamais de palier "Valider" visible : le
  /// bouton reste juste "Continuer", désactivé jusqu'à ce que la réponse
  /// soit déjà soumise par le renderer lui-même.
  final bool showValidateStep;
  @override
  State<QuizBottomBar> createState() => _QuizBottomBarState();
}

class _QuizBottomBarState extends State<QuizBottomBar> {
  bool _finishing = false;

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    await widget.controller.finish();
    if (mounted) setState(() => _finishing = false);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final isLast =
        controller.currentIndex == controller.totalQuestions - 1;
    final cfg = controller.definition.config;
    return Container(
      color: ink800,
      // Padding haut/bas equilibre (avant : 10/20, asymetrique -- donnait
      // l'impression que les boutons etaient plaques en bas de la barre).
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      // Hauteur fixe forcee sur la barre entiere -- filet de securite
      // independant de celui deja pose dans QuizActionButton : quelle que
      // soit la contrainte haute proposee par le Scaffold parent pour son
      // bottomNavigationBar (volontairement large par design Flutter), la
      // barre ne peut jamais s'etirer au-dela de sa taille prevue.
      child: SizedBox(
        height: 52,
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          if (cfg.allowSkip)
            Expanded(
              child: QuizActionButton(
                label: 'Passer',
                primary: false,
                onPressed: controller.canSkip ? controller.skip : null,
              ),
            ),
          if (cfg.allowSkip) const SizedBox(width: 12),
          Expanded(
            child: QuizActionButton(
              label: controller.locked
                  ? (isLast ? 'Terminer' : 'Continuer')
                  : (widget.showValidateStep ? 'Valider' : 'Continuer'),
              loading: isLast && controller.locked && _finishing,
              leading: Icon(
                isLast && controller.locked
                    ? QuizIcons.flag
                    : QuizIcons.arrowForward,
                size: 18,
                color: ink900,
              ),
              onPressed: controller.locked
                  ? (isLast ? _finish : controller.next)
                  : (widget.showValidateStep && controller.draftAnswer != null
                      ? () => controller.answer(controller.draftAnswer!)
                      : null),
            ),
          ),
        ]),
      ),
    );
  }
}
