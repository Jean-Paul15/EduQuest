import 'package:eduquest/app/router/app_routes.dart';
import 'package:eduquest/features/auth/data/auth_repository.dart';
import 'package:eduquest/features/class_selection/presentation/class_selection_panel.dart';
import 'package:eduquest/features/notifications/data/notification_service.dart';
import 'package:eduquest/features/profile/presentation/widgets/profile_actions.dart';
import 'package:eduquest/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:eduquest/features/profile/presentation/widgets/profile_settings_card.dart';
import 'package:eduquest/features/profile/presentation/widgets/whatsapp_phone_card.dart';
import 'package:eduquest/features/widget/data/home_widget_service.dart';
import 'package:eduquest/features/user/data/user_profile_repository.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.onThemeToggle, required this.themeMode});
  final VoidCallback onThemeToggle;
  final ThemeMode themeMode;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = AuthRepository();
  final _widget = HomeWidgetService();
  final _user = UserProfileRepository();
  final _notif = NotificationService();
  String _name = 'Étudiant', _countryCode = 'TG', _levelCode = 'Terminale', _serieCode = 'D', _phone = '';

  @override
  void initState() { super.initState(); _reloadProfile(); }
  @override
  void dispose() { super.dispose(); }

  Future<void> _reloadProfile() async {
    final u = await _user.load();
    final uid = _auth.currentUser?.id;
    if (uid != null) await _notif.setExternalUserId(uid);
    await _notif.setLearningTags(country: u.countryCode, level: u.levelCode, serie: u.serieCode);
    if (!mounted) return;
    setState(() {
      _name = u.displayName; _countryCode = u.countryCode;
      _levelCode = u.levelCode; _serieCode = u.serieCode;
      _phone = u.whatsappPhone ?? '';
    });
  }

  Future<void> _pinWidget() async {
    if (!await _widget.canPin()) {
      if (mounted) ModernSnackbar.show(context, 'Non supporté par ce lanceur.', success: false);
      return;
    }
    await _widget.requestPin();
    if (mounted) ModernSnackbar.show(context, "Widget proposé sur l'écran d'accueil.");
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const RuachAppBar(title: 'Profil'),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      ProfileHeaderCard(name: _name, countryCode: _countryCode, levelCode: _levelCode, serieCode: _serieCode),
      const SizedBox(height: 12),
      WhatsAppPhoneCard(countryCode: _countryCode, phone: _phone, onPhoneChanged: _reloadProfile),
      const SizedBox(height: 16),
      ProfileSettingsCard(themeMode: widget.themeMode, onThemeToggle: widget.onThemeToggle, displayName: _name),
      const SizedBox(height: 16),
      ClassSelectionPanel(onChanged: _reloadProfile),
      const SizedBox(height: 12),
      ProfileActions(
        onWidgetUpdate: () => _widget.update(title: 'RuachEdu • $_name', focusLabel: 'Rappel', focusValue: 'Révision du jour'),
        onWidgetPin: _pinWidget,
        onOpenTerms: () => context.pushNamed(AppRoutes.legal, pathParameters: {'docType': 'terms'}),
        onOpenPrivacy: () => context.pushNamed(AppRoutes.legal, pathParameters: {'docType': 'privacy'}),
        onSignOut: _auth.signOut,
      ),
    ]),
  );
}
