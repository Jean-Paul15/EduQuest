import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TestableMainNav extends StatefulWidget {
  const TestableMainNav({super.key, required this.pages});
  final List<WidgetBuilder> pages;

  @override
  State<TestableMainNav> createState() => _TestableMainNavState();
}

class _TestableMainNavState extends State<TestableMainNav> {
  int _index = 0;

  Future<void> _confirmExit() async {
    await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Quitter RuachEdu ?'),
        content: const Text('Tu es sûr de vouloir fermer l’application ?'),
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
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _confirmExit();
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [for (final page in widget.pages) Builder(builder: page)],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Assistant',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              label: 'Apprendre',
            ),
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              label: 'Hub',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
