import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruach_quiz_engine/presentation/widgets/option_picker_sheet.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  const longWord = 'anticonstitutionnellement';

  testWidgets('long French word is never clipped in the closed field or the sheet',
      (tester) async {
    String? selected;
    await tester.pumpWidget(_wrap(StatefulBuilder(builder: (context, setState) {
      return OptionPickerField(
        options: const [('a', longWord), ('b', 'court')],
        selectedId: selected,
        onSelected: (v) => setState(() => selected = v),
      );
    })));

    await tester.tap(find.byType(OptionPickerField));
    await tester.pumpAndSettle();

    final optionFinder = find.text(longWord);
    expect(optionFinder, findsOneWidget);
    final optionText = tester.widget<Text>(optionFinder);
    expect(optionText.maxLines, isNull, reason: 'option text must never be line-capped');
    expect(optionText.overflow, isNot(TextOverflow.ellipsis));

    await tester.tap(optionFinder);
    await tester.pumpAndSettle();

    final closedFinder = find.descendant(
      of: find.byType(OptionPickerField),
      matching: find.text(longWord),
    );
    expect(closedFinder, findsOneWidget);
    final closedText = tester.widget<Text>(closedFinder);
    expect(closedText.maxLines, isNull);
  });
}
