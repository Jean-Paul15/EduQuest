import 'package:eduquest/features/referral/data/referral_repository.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  int _qualified = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final c = await _repo.myCode();
    final values = await Future.wait([
      _repo.invitedCount(),
      _repo.qualifiedCount(),
    ]);
    if (!mounted) return;
    setState(() {
      _myCode = c;
      _count = values[0];
      _qualified = values[1];
    });
  }

  Future<void> _apply() async {
    final msg = await _repo.applyCode(_codeCtrl.text.trim());
    if (!mounted) return;
    ModernSnackbar.show(
      context,
      msg,
      success: !msg.toLowerCase().contains('invalide'),
    );
    await _load();
  }

  Future<void> _copyCode() async {
    if (_myCode.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _myCode));
    if (!mounted) return;
    ModernSnackbar.show(context, 'Code parrain copié.');
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final progress = (_qualified / 5).clamp(0, 1).toDouble();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
              Row(
                children: [
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
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: s.primary.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Text(
                      '$_count invités',
                      style: TextStyle(
                        color: s.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
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
              ] else ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: _copyCode,
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Copier le code'),
                    ),
                  ],
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Progression récompense',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$_qualified/5 filleuls qualifiés (ticket activé)',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: progress,
                  backgroundColor: AppColors.divider,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'À 5, bonus FULL +30 jours attribué automatiquement.',
                style: TextStyle(color: s.primary, fontWeight: FontWeight.w600),
              ),
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
          child: Column(
            children: [
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
            ],
          ),
        ),
      ],
    );
  }
}
