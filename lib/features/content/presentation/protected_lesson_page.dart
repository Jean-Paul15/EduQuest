import 'package:eduquest/shared/security/sensitive_scope.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:flutter/material.dart';

class ProtectedLessonPage extends StatelessWidget {
  const ProtectedLessonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SensitiveScope(
      child: Scaffold(
        appBar: const RuachAppBar(title: 'Cours protégé', showBack: true),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Capture écran/vidéo protégée pour ce contenu.'),
          ),
        ),
      ),
    );
  }
}
