import 'package:eduquest/app/router/app_router.dart';
import 'package:eduquest/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class RuachEduApp extends StatefulWidget {
  const RuachEduApp({super.key});

  @override
  State<RuachEduApp> createState() => _RuachEduAppState();
}

class _RuachEduAppState extends State<RuachEduApp> {
  ThemeMode _themeMode = ThemeMode.system;
  late var _router = appRouter(
    onThemeToggle: _toggleTheme,
    themeMode: _themeMode,
  );

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      _router = appRouter(onThemeToggle: _toggleTheme, themeMode: _themeMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'RuachEdu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}
