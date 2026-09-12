import 'package:eduquest/features/referral/data/referral_repository.dart';
import 'package:eduquest/features/referral/presentation/apply_code_card.dart';
import 'package:eduquest/features/referral/presentation/my_code_card.dart';
import 'package:eduquest/features/referral/presentation/reward_progress_card.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReferralPage extends StatefulWidget {
  const ReferralPage({super.key, this.embedded = false});
  final bool embedded;
  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  final _repo = ReferralRepository();
  final _codeCtrl = TextEditingController();
  String _myCode = '';
  int _count = 0;
  int _qualified = 0;
  List<ReferralProgressItem> _items = const [];
  bool _applying = false;

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
    final progress = await _repo.loadProgress();
    if (!mounted) return;
    setState(() {
      _myCode = c;
      _count = progress.invitedCount;
      _qualified = progress.qualifiedCount;
      _items = progress.items;
    });
  }

  Future<void> _apply() async {
    if (_applying) return;
    setState(() => _applying = true);
    try {
      final msg = await _repo.applyCode(_codeCtrl.text.trim());
      if (!mounted) return;
      ModernSnackbar.show(
        context,
        msg,
        success: !msg.toLowerCase().contains('invalide'),
      );
      await _load();
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  Future<void> _copyCode() async {
    if (_myCode.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _myCode));
    if (!mounted) return;
    ModernSnackbar.show(context, 'Code parrain copié.');
  }

  @override
  Widget build(BuildContext context) {
    final body = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MyCodeCard(
          myCode: _myCode,
          count: _count,
          onRefresh: _load,
          onCopyCode: _copyCode,
        ),
        const SizedBox(height: 12),
        RewardProgressCard(
          invitedCount: _count,
          qualifiedCount: _qualified,
          items: _items,
        ),
        const SizedBox(height: 12),
        ApplyCodeCard(codeCtrl: _codeCtrl, loading: _applying, onApply: _apply),
      ],
    );
    if (widget.embedded) return body;
    return Scaffold(
      appBar: const RuachAppBar(title: 'Parrainage', showBack: true),
      body: body,
    );
  }
}
