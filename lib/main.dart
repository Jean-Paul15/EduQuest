import 'dart:async';
import 'package:eduquest/app/app.dart';
import 'package:eduquest/app/bootstrap/app_startup_warmup.dart';
import 'package:eduquest/features/notifications/data/notification_service.dart';
import 'package:eduquest/shared/supabase/supabase_bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await dotenv.load(fileName: '.env');
  await SupabaseBootstrap.initialize();
  runApp(const EduQuestApp());
  unawaited(_startBackgroundInit());
}

Future<void> _startBackgroundInit() async {
  await Future.wait([
    _safe(() => NotificationService().initialize()),
    _safe(() => AppStartupWarmup().run()),
  ]);
}

Future<void> _safe(Future<void> Function() fn) async {
  try {
    await fn();
  } catch (_) {}
}
