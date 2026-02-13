import 'package:eduquest/features/referral/data/referral_repository.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:flutter/material.dart';

class ReferralPage extends StatefulWidget {
  const ReferralPage({super.key});
  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  final _repo = ReferralRepository();
  final _codeCtrl = TextEditingController();
  String _myCode = '';
  int _count = 0;

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _codeCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    final c = await _repo.myCode();
    final n = await _repo.invitedCount();
    if (!mounted) return;
    setState(() { _myCode = c; _count = n; });
  }

  Future<void> _apply() async {
    final msg = await _repo.applyCode(_codeCtrl.text.trim());
    if (!mounted) return;
    ModernSnackbar.show(
      context, msg, success: !msg.toLowerCase().contains('invalide'),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Text(
                'Mon code',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: s.primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  '$_count invites',
                  style: TextStyle(
                    color: s.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Text(
              _myCode.isEmpty ? 'Indisponible' : _myCode,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _myCode.isEmpty
                    ? AppColors.textTertiary
                    : AppColors.textPrimary,
                letterSpacing: _myCode.isEmpty ? 0 : 1.5,
              ),
            ),
            if (_myCode.isEmpty) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Actualiser'),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(children: [
          TextField(
            controller: _codeCtrl,
            decoration: const InputDecoration(hintText: 'Code parrain'),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _apply,
              icon: const Icon(Icons.redeem_rounded, size: 18),
              label: const Text('Appliquer'),
            ),
          ),
        ]),
      ),
    ]);
  }
}
