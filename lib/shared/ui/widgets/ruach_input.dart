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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fill = isDark ? const Color(0xFF152235) : RuachColors.cream100;
    final border = isDark ? const Color(0xFF24405E) : RuachColors.cream200;
    final hintColor = isDark ? RuachColors.cream500 : RuachColors.cream700;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: theme.colorScheme.onSurface,
            ),
          ),
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
              hintStyle: TextStyle(color: hintColor, fontSize: 14),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: fill,
              contentPadding: const EdgeInsets.symmetric(horizontal: RuachSpace.s4, vertical: RuachSpace.s4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(RuachRadius.md),
                borderSide: BorderSide(color: border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(RuachRadius.md),
                borderSide: BorderSide(color: border),
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
