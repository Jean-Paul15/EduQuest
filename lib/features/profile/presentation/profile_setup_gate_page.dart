import 'package:eduquest/features/class_selection/presentation/class_selection_panel.dart';
import 'package:eduquest/features/profile/data/profile_setup_repository.dart';
import 'package:eduquest/features/profile/presentation/widgets/profile_setup_identity_fields.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:eduquest/shared/ui/widgets/loading_shimmer_page.dart';
import 'package:eduquest/shared/validation/phone_validator.dart';
import 'package:flutter/material.dart';

class ProfileSetupGatePage extends StatefulWidget {
  const ProfileSetupGatePage({super.key, required this.onDone});
  final VoidCallback onDone;
  @override
  State<ProfileSetupGatePage> createState() => _ProfileSetupGatePageState();
}

class _ProfileSetupGatePageState extends State<ProfileSetupGatePage> {
  final _repo = ProfileSetupRepository();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = true, _saving = false, _complete = false;
  String _countryCode = 'TG';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final s = await _repo.load();
    if (!mounted) return;
    _nameCtrl.text = s.fullName;
    _phoneCtrl.text = s.whatsappPhone;
    setState(() {
      _complete = s.complete;
      _countryCode = s.countryCode;
      _loading = false;
    });
  }

  Future<void> _continue() async {
    if (_saving) return;
    if (_nameCtrl.text.trim().length < 3) {
      return ModernSnackbar.show(context, 'Nom trop court.', success: false);
    }
    final err = phoneValidationMessage(
      countryCode: _countryCode,
      phone: _phoneCtrl.text,
    );
    if (err != null) return ModernSnackbar.show(context, err, success: false);
    setState(() => _saving = true);
    await _repo.saveFullName(_nameCtrl.text);
    await _repo.saveWhatsappPhone(
      normalizePhone(_phoneCtrl.text).replaceAll('+', ''),
    );
    await _reload();
    if (!mounted) return;
    setState(() => _saving = false);
    if (_complete) return widget.onDone();
    ModernSnackbar.show(
      context,
      'Complète aussi ta classe/série.',
      success: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingShimmerPage();
    return Scaffold(
      appBar: AppBar(title: const Text('Completer ton profil')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.l),
        children: [
          ProfileSetupIdentityFields(
            nameCtrl: _nameCtrl,
            phoneCtrl: _phoneCtrl,
            countryCode: _countryCode,
          ),
          const SizedBox(height: AppSpace.l),
          ClassSelectionPanel(onChanged: _reload),
          const SizedBox(height: AppSpace.xxl),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saving ? null : _continue,
              icon: const Icon(Icons.check_circle_rounded),
              label: Text(_saving ? 'Validation...' : 'Continuer'),
            ),
          ),
        ],
      ),
    );
  }
}
