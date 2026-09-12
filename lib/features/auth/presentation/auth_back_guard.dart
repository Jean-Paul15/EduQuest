import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class AuthBackGuard extends StatelessWidget {
  const AuthBackGuard({
    super.key,
    required this.child,
    this.canStepBack = false,
    this.onStepBack,
  });

  final Widget child;
  final bool canStepBack;
  final VoidCallback? onStepBack;

  Future<void> _handleBack(BuildContext context) async {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    if (keyboardOpen || FocusManager.instance.primaryFocus != null) {
      FocusManager.instance.primaryFocus?.unfocus();
      return;
    }
    if (canStepBack && onStepBack != null) {
      onStepBack!();
      return;
    }
    final shouldExit = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Quitter RuachEdu ?'),
        content: const Text('Tu veux fermer l’application ?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Rester'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
    if (shouldExit == true) await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack(context);
      },
      child: child,
    );
  }
}
