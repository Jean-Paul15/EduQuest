import 'package:eduquest/app/router/app_routes.dart';
import 'package:eduquest/features/auth/data/auth_repository.dart';
import 'package:eduquest/features/class_selection/data/class_selection_repository.dart';
import 'package:eduquest/features/class_selection/presentation/class_selection_panel.dart';
import 'package:eduquest/features/home/data/home_snapshot_cache.dart';
import 'package:eduquest/features/home/presentation/helpers/home_snapshot.dart';
import 'package:eduquest/features/notifications/data/notification_service.dart';
import 'package:eduquest/features/profile/presentation/widgets/profile_actions.dart';
import 'package:eduquest/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:eduquest/features/profile/presentation/widgets/profile_settings_card.dart';
import 'package:eduquest/features/profile/presentation/widgets/whatsapp_phone_card.dart';
import 'package:eduquest/features/user/data/user_profile_repository.dart';
import 'package:eduquest/features/widget/data/home_widget_service.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:eduquest/shared/media/cache_info_service.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:eduquest/shared/ui/widgets/loading_shimmer_page.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.onThemeToggle,
    required this.themeMode,
    this.auth,
    this.widgetService,
    this.userRepository,
    this.notificationService,
    this.classRepository,
  });
  final VoidCallback onThemeToggle;
  final ThemeMode themeMode;
  final AuthRepository? auth;
  final HomeWidgetService? widgetService;
  final UserProfileRepository? userRepository;
  final NotificationService? notificationService;
  final ClassSelectionRepository? classRepository;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final AuthRepository _auth;
  late final HomeWidgetService _widget;
  late final UserProfileRepository _user;
  late final NotificationService _notif;
  bool _loading = true;
  String _name = 'Étudiant', _countryCode = 'TG', _levelCode = 'Terminale', _serieCode = 'D', _phone = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _auth = widget.auth ?? AuthRepository();
    _widget = widget.widgetService ?? HomeWidgetService();
    _user = widget.userRepository ?? UserProfileRepository();
    _notif = widget.notificationService ?? NotificationService();
    _reloadProfile();
  }

  Future<void> _reloadProfile() async {
    final u = await _user.load();
    final uid = _auth.currentUser?.id;
    final tasks = <Future<void>>[_notif.setLearningTags(country: u.countryCode, level: u.levelCode, serie: u.serieCode)];
    if (uid != null) tasks.add(_notif.setExternalUserId(uid));
    await Future.wait(tasks);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _name = u.displayName; _email = u.email; _countryCode = u.countryCode; _levelCode = u.levelCode; _serieCode = u.serieCode; _phone = u.whatsappPhone ?? '';
    });
  }

  Future<void> _refreshWidget() async {
    final snap = await HomeSnapshotCache().read();
    if (snap == null) {
      if (mounted) {
        ModernSnackbar.show(context, "Ouvre l'accueil une fois pour alimenter le widget.", success: false);
      }
      return;
    }
    await _widget.update(widgetPayload(snap));
    if (mounted) ModernSnackbar.show(context, 'Widget mis à jour.', success: true);
  }

  Future<void> _pinWidget() async {
    if (!await _widget.canPin()) {
      if (mounted) ModernSnackbar.show(context, 'Non supporté par ce lanceur.', success: false);
      return;
    }
    final ok = await _widget.requestPin();
    if (!mounted) return;
    ModernSnackbar.show(
      context,
      ok ? "Widget proposé sur l'écran d'accueil." : 'Widget indisponible pour le moment.',
      success: ok,
    );
  }

  Future<void> _confirmSignOut() async {
    final leave = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RuachRadius.xl)),
      title: const Text('Se déconnecter ?'),
      content: const Text('Tu devras te reconnecter pour reprendre ta progression synchronisée.'),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Rester')),
        TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Déconnexion')),
      ],
    ));
    if (leave == true) await _auth.signOut();
  }

  Future<void> _confirmClearCache() async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RuachRadius.xl)),
      title: const Text('Vider le cache ?'),
      content: const Text('Les cours, PDF et vidéos déjà téléchargés devront être rechargés depuis internet à la prochaine ouverture.'),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Annuler')),
        TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Vider')),
      ],
    ));
    if (confirm != true) return;
    await Future.wait([
      LocalJsonCache().clearAll(),
      const CacheInfoService().clearAllCaches(),
    ]);
    if (mounted) ModernSnackbar.show(context, 'Cache vidé.', success: true);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingShimmerPage();
    return Scaffold(
      appBar: RuachAppBar(title: 'Profil', actions: [IconButton(onPressed: _reloadProfile, icon: const Icon(PhosphorIconsRegular.arrowsClockwise))]),
      body: RefreshIndicator(
        onRefresh: _reloadProfile,
        child: ListView(padding: const EdgeInsets.all(RuachSpace.s4), children: [
          ProfileHeaderCard(name: _name, email: _email, countryCode: _countryCode, levelCode: _levelCode, serieCode: _serieCode),
          const SizedBox(height: RuachSpace.s3),
          WhatsAppPhoneCard(
            countryCode: _countryCode,
            phone: _phone,
            onPhoneChanged: _reloadProfile,
            repository: _user,
          ),
          const SizedBox(height: RuachSpace.s4),
          ProfileSettingsCard(themeMode: widget.themeMode, onThemeToggle: widget.onThemeToggle, displayName: _name),
          const SizedBox(height: RuachSpace.s4),
          ClassSelectionPanel(
            onChanged: _reloadProfile,
            repository: widget.classRepository,
          ),
          const SizedBox(height: RuachSpace.s3),
          ProfileActions(
            onWidgetUpdate: _refreshWidget,
            onWidgetPin: _pinWidget,
            onOpenTerms: () => context.pushNamed(AppRoutes.legal, pathParameters: {'docType': 'terms'}),
            onOpenPrivacy: () => context.pushNamed(AppRoutes.legal, pathParameters: {'docType': 'privacy'}),
            onOpenMyData: () => context.pushNamed(AppRoutes.myData),
            onClearCache: _confirmClearCache,
            onSignOut: _confirmSignOut,
          ),
        ]),
      ),
    );
  }
}
