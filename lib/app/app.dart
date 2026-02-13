import 'package:eduquest/app/app_shell.dart';
import 'package:eduquest/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class EduQuestApp extends StatefulWidget {
  const EduQuestApp({super.key});

  @override
  State<EduQuestApp> createState() => _EduQuestAppState();
}

class _EduQuestAppState extends State<EduQuestApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduQuest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      home: AppShell(onThemeToggle: _toggleTheme, themeMode: _themeMode),
    );
  }
}
