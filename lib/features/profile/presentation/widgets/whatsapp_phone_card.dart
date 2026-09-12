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
    this.repository,
  });
  final String countryCode;
  final String phone;
  final VoidCallback onPhoneChanged;
  final UserProfileRepository? repository;

  @override
  State<WhatsAppPhoneCard> createState() => _WhatsAppPhoneCardState();
}

class _WhatsAppPhoneCardState extends State<WhatsAppPhoneCard> {
  late final UserProfileRepository _user;
  final _phoneCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _user = widget.repository ?? UserProfileRepository();
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
    final msg =
        phoneValidationMessage(countryCode: widget.countryCode, phone: _phoneCtrl.text);
    if (msg != null) {
      ModernSnackbar.show(context, msg, success: false);
      return;
    }
    setState(() => _saving = true);
    final phone = normalizePhone(_phoneCtrl.text).replaceAll('+', '');
    try {
      final ok = await _user.saveWhatsappPhone(phone);
      if (!mounted) return;
      setState(() => _saving = false);
      if (ok) {
        ModernSnackbar.show(context, 'Numéro WhatsApp enregistré.', success: true);
        widget.onPhoneChanged();
      } else {
        ModernSnackbar.show(
          context,
          'Impossible d\'enregistrer. Vérifie ta connexion et réessaie.',
          success: false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ModernSnackbar.show(context, 'Erreur: ${e.toString()}', success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(RuachSpace.s3),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(RuachRadius.lg),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Numéro WhatsApp',
              hintText: widget.countryCode == 'TG'
                  ? 'Ex: 90123456'
                  : 'Entrez votre numéro',
              prefixIcon: const Icon(PhosphorIconsRegular.phone, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(RuachRadius.md),
              ),
            ),
          ),
          const SizedBox(height: RuachSpace.s3),
          SizedBox(
            width: double.infinity,
            child: RuachButton(
              label: 'Enregistrer',
              loading: _saving,
              onPressed: _savePhone,
              icon: PhosphorIconsRegular.floppyDisk,
            ),
          ),
        ],
      ),
    );
  }
}
