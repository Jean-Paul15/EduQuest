import 'package:flutter/material.dart';
import '../constants.dart';
import '../tokens.dart';
import '../quiz_icons.dart';

/// Sélecteur d'option en feuille modale : le texte de chaque option est
/// affiché en pleine largeur sans contrainte, donc jamais tronqué —
/// contrairement à un `DropdownButton` contraint en largeur fixe.
/// Utilisé par `cloze_body.dart` (trou à choix) et `matching_body.dart`
/// (association) pour corriger la troncature des mots/libellés longs.
Future<void> showOptionPickerSheet(
  BuildContext context, {
  required List<(String, String)> options,
  required String? selectedId,
  required ValueChanged<String?> onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: ink900,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(QuizRadius.lg)),
    ),
    builder: (sheetContext) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: QuizSpace.s2),
        children: options.map((o) {
          final (id, label) = o;
          final selected = id == selectedId;
          return ListTile(
            title: Text(
              label,
              softWrap: true,
              style: TextStyle(
                color: selected ? gold500 : cream900,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            trailing: selected ? Icon(QuizIcons.checkCircle, color: gold500) : null,
            onTap: () {
              Navigator.of(sheetContext).pop();
              onSelected(id);
            },
          );
        }).toList(),
      ),
    ),
  );
}

/// Champ tappable affichant l'option choisie en texte complet (retour à la
/// ligne libre, jamais de coupure silencieuse) et ouvrant le sélecteur.
class OptionPickerField extends StatelessWidget {
  const OptionPickerField({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onSelected,
    this.locked = false,
    this.hint = 'Choisir',
    this.compact = false,
  });

  final List<(String, String)> options;
  final String? selectedId;
  final ValueChanged<String?> onSelected;
  final bool locked;
  final String hint;
  final bool compact;

  String get _label => options
      .firstWhere((o) => o.$1 == selectedId, orElse: () => ('', ''))
      .$2;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedId != null && selectedId!.isNotEmpty;
    final label = hasSelection ? _label : hint;
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(QuizRadius.sm),
        onTap: locked
            ? null
            : () => showOptionPickerSheet(
                  context,
                  options: options,
                  selectedId: selectedId,
                  onSelected: onSelected,
                ),
        child: Container(
          constraints: BoxConstraints(minWidth: compact ? 90 : 0),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: surfaceBase,
            borderRadius: BorderRadius.circular(QuizRadius.sm),
            border: Border.all(
              color: hasSelection ? gold500 : cream200,
              width: hasSelection ? 1.4 : 1.2,
            ),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Flexible(
              child: Text(
                label,
                softWrap: true,
                style: TextStyle(
                  color: hasSelection ? cream900 : cream700,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(QuizIcons.caretDown, color: gold500, size: 16),
          ]),
        ),
      ),
    );
  }
}
