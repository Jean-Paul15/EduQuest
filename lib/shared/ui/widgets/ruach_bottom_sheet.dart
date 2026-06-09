import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';

/// Bottom sheet wrapper — 32dp top radius, handle, slide-from-bottom.
class RuachBottomSheet extends StatelessWidget {
  const RuachBottomSheet({super.key, this.title, required this.child});
  final String? title;
  final Widget child;

  static Future<T?> show<T>(BuildContext context, {required Widget child, String? title}) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RuachBottomSheet(title: title, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? RuachColors.ink300 : RuachColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(RuachRadius.xxl)),
      ),
      padding: const EdgeInsets.all(RuachSpace.s6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: RuachColors.ink500,
                borderRadius: BorderRadius.circular(RuachRadius.full),
              ),
            ),
          ),
          if (title != null) ...[
            const SizedBox(height: RuachSpace.s4),
            Text(title!, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: RuachSpace.s4),
          ],
          child,
        ],
      ),
    );
  }
}
