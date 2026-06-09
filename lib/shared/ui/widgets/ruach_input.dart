import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';

/// TextField wrapper — 56dp, 12dp radius, outline border, gold focus.
class RuachInput extends StatelessWidget {
  const RuachInput({
    super.key,
    this.controller,
    this.hint,
    this.label,
    this.error,
    this.obscure = false,
    this.keyboardType,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
  });
  final TextEditingController? controller;
  final String? hint, label, error;
  final bool obscure;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon, suffixIcon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          const SizedBox(height: RuachSpace.s2),
        ],
        SizedBox(
          height: 56,
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: TextStyle(fontSize: 16, color: isDark ? RuachColors.cream100 : RuachColors.cream900),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: isDark ? RuachColors.ink400 : RuachColors.cream100,
              contentPadding: const EdgeInsets.symmetric(horizontal: RuachSpace.s4, vertical: RuachSpace.s4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(RuachRadius.md),
                borderSide: BorderSide(color: isDark ? RuachColors.ink500 : RuachColors.cream200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(RuachRadius.md),
                borderSide: BorderSide(color: isDark ? RuachColors.ink500 : RuachColors.cream200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(RuachRadius.md),
                borderSide: BorderSide(color: error != null ? RuachColors.error400 : RuachColors.gold500, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(RuachRadius.md),
                borderSide: const BorderSide(color: RuachColors.error400),
              ),
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: RuachSpace.s1),
            child: Text(error!, style: const TextStyle(color: RuachColors.error400, fontSize: 11)),
          ),
      ],
    );
  }
}
