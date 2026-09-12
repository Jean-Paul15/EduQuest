import 'dart:async';
import 'package:eduquest/app/app.dart';
import 'package:eduquest/app/bootstrap/app_startup_warmup.dart';
import 'package:eduquest/features/notifications/data/notification_service.dart';
import 'package:eduquest/firebase_options.dart';
import 'package:eduquest/shared/supabase/supabase_bootstrap.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await dotenv.load(fileName: '.env');
  await initializeDateFormatting('fr_FR');
  await _initCrashlytics();
  await SupabaseBootstrap.initialize();
  await NotificationService().initialize();
  runApp(const RuachEduApp());
  WidgetsBinding.instance.addPostFrameCallback((_) {
    NotificationService().notifyUiReady();
  });
  unawaited(_startBackgroundInit());
}

Future<void> _initCrashlytics() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kIsWeb) return;
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      !kDebugMode,
    );
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true),
      );
      return true;
    };
  } catch (e, stack) {
    FlutterError.dumpErrorToConsole(
      FlutterErrorDetails(exception: e, stack: stack),
    );
  }
}

Future<void> _startBackgroundInit() async {
  await _safe(() => AppStartupWarmup().run());
}

Future<void> _safe(Future<void> Function() fn) async {
  try {
    await fn();
  } catch (_) {}
}
