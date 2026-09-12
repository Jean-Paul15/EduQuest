import 'package:flutter/material.dart';
import '../constants.dart';

/// Blanc de saisie inline (cloze/fill-blank) qui s'élargit avec son contenu
/// jusqu'à une largeur max, puis wrap sur plusieurs lignes plutôt que de
/// faire défiler le texte tapé hors champ de vision.
WidgetSpan inlineAnswerField({
  required TextEditingController controller,
  required TextStyle style,
  required VoidCallback onChanged,
}) => WidgetSpan(
  alignment: PlaceholderAlignment.middle,
  child: ConstrainedBox(
    constraints: const BoxConstraints(minWidth: 90, maxWidth: 220),
    child: IntrinsicWidth(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: surfaceBase,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cream200),
        ),
        child: TextField(
          controller: controller,
          onChanged: (_) => onChanged(),
          minLines: 1,
          maxLines: 3,
          style: style.copyWith(fontSize: 15),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 6),
            border: InputBorder.none,
          ),
        ),
      ),
    ),
  ),
);
