import 'package:eduquest/features/class_selection/presentation/class_selection_panel.dart';
import 'package:eduquest/features/profile/data/profile_setup_repository.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
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
  bool _loading = true;
  bool _saving = false;
  bool _complete = false;

  @override
  void initState() { super.initState(); _reload(); }
  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  Future<void> _reload() async {
    final s = await _repo.load();
    if (!mounted) return;
    _nameCtrl.text = s.fullName;
    setState(() { _complete = s.complete; _loading = false; });
  }

  Future<void> _continue() async {
    if (_saving) return;
    if (_nameCtrl.text.trim().length < 3) {
      return ModernSnackbar.show(context, 'Nom trop court.', success: false);
    }
    setState(() => _saving = true);
    await _repo.saveFullName(_nameCtrl.text);
    await _reload();
    if (!mounted) return;
    setState(() => _saving = false);
    if (_complete) { widget.onDone(); return; }
    ModernSnackbar.show(context, 'Complete aussi ta classe/serie.', success: false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Completer ton profil')),
      body: ListView(padding: const EdgeInsets.all(AppSpace.l), children: [
        const Text(
          'Nom complet',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpace.s),
        TextField(
          controller: _nameCtrl,
          decoration: InputDecoration(
            hintText: 'Ex: Kossi Kodjo',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.s),
            ),
          ),
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
      ]),
    );
  }
}
