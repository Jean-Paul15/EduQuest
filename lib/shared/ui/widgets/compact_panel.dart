import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';

class CompactPanel extends StatelessWidget {
  const CompactPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(RuachSpace.s4),
    this.margin = const EdgeInsets.only(bottom: 10),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(RuachRadius.lg),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}
