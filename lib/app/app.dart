import 'package:eduquest/app/router/app_router.dart';
import 'package:eduquest/app/theme/ruach_theme.dart';
import 'package:eduquest/app/widgets/boot_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RuachEduApp extends StatefulWidget {
  const RuachEduApp({super.key});

  @override
  State<RuachEduApp> createState() => _RuachEduAppState();
}

class _RuachEduAppState extends State<RuachEduApp> {
  static const _themeKey = 'app_theme_mode';
  final _themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);
  bool _loaded = false;

  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_themeKey);
    final mode = stored == 'dark'
        ? ThemeMode.dark
        : stored == 'light'
        ? ThemeMode.light
        : ThemeMode.light;
    if (!mounted) return;
    _themeNotifier.value = mode;
    _router = appRouter(
      themeNotifier: _themeNotifier,
      onThemeToggle: _toggleTheme,
    );
    setState(() => _loaded = true);
  }

  Future<void> _toggleTheme() async {
    final next = _themeNotifier.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    _themeNotifier.value = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, next == ThemeMode.dark ? 'dark' : 'light');
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _router == null) {
      return MaterialApp(
        title: 'RuachEdu',
        debugShowCheckedModeBanner: false,
        theme: RuachTheme.light(),
        darkTheme: RuachTheme.dark(),
        themeMode: _themeNotifier.value,
        home: const BootLoadingScreen(),
      );
    }
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp.router(
          title: 'RuachEdu',
          debugShowCheckedModeBanner: false,
          theme: RuachTheme.light(),
          darkTheme: RuachTheme.dark(),
          themeMode: mode,
          routerConfig: _router,
        );
      },
    );
  }
}
