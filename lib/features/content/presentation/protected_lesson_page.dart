import 'package:eduquest/shared/security/sensitive_scope.dart';
import 'package:flutter/material.dart';

class ProtectedLessonPage extends StatelessWidget {
  const ProtectedLessonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SensitiveScope(
      child: Scaffold(
        appBar: AppBar(title: const Text('Cours protégé')),
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
