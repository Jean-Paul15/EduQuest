import 'package:eduquest/features/user/data/user_profile_repository.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:eduquest/shared/validation/phone_validator.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class WhatsAppPhoneCard extends StatefulWidget {
  const WhatsAppPhoneCard({
    super.key,
    required this.countryCode,
    required this.phone,
    required this.onPhoneChanged,
  });
  final String countryCode;
  final String phone;
  final VoidCallback onPhoneChanged;
  @override
  State<WhatsAppPhoneCard> createState() => _WhatsAppPhoneCardState();
}

class _WhatsAppPhoneCardState extends State<WhatsAppPhoneCard> {
  final _user = UserProfileRepository();
  final _phoneCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _phoneCtrl.text = widget.phone;
  }

  @override
  void didUpdateWidget(WhatsAppPhoneCard old) {
    super.didUpdateWidget(old);
    if (old.phone != widget.phone) _phoneCtrl.text = widget.phone;
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _savePhone() async {
    if (_saving) return;
    final msg = phoneValidationMessage(countryCode: widget.countryCode, phone: _phoneCtrl.text);
    if (msg != null) {
      ModernSnackbar.show(context, msg, success: false);
      return;
    }
    setState(() => _saving = true);
    final phone = normalizePhone(_phoneCtrl.text).replaceAll('+', '');
    final ok = await _user.saveWhatsappPhone(phone);
    if (!mounted) return;
    setState(() => _saving = false);
    ModernSnackbar.show(
      context,
      ok ? 'Numéro WhatsApp enregistré.' : 'Échec enregistrement numéro.',
      success: ok,
    );
    widget.onPhoneChanged();
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(RuachRadius.lg),
      border: Border.all(color: RuachColors.cream200),
    ),
    child: Row(children: [
      Expanded(
        child: TextField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Numéro WhatsApp',
            hintText: 'Ex: 90123456',
            prefixIcon: Icon(PhosphorIconsRegular.phone, size: 18),
          ),
        ),
      ),
      const SizedBox(width: 10),
      RuachButton(
        label: _saving ? '...' : 'Sauver',
        onPressed: _saving ? null : _savePhone,
      ),
    ]),
  );
}
