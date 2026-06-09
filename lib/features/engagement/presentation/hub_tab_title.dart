import 'package:eduquest/features/engagement/presentation/hub_tab_model.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

class HubTabTitle extends StatelessWidget {
  const HubTabTitle({super.key, required this.tab});
  final HubTab tab;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    if (tab.count <= 0) {
      return Text(tab.label, style: TextStyle(color: textColor));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(tab.label, style: TextStyle(color: textColor)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: RuachColors.gold600,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '${tab.count}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
