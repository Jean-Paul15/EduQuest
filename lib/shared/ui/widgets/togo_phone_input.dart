import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class TogoPhoneInput extends StatelessWidget {
  const TogoPhoneInput({
    super.key,
    required this.controller,
    this.label,
    this.hint = '90123456',
  });

  final TextEditingController controller;
  final String? label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fill = isDark ? const Color(0xFF152235) : RuachColors.cream100;
    final border = isDark ? const Color(0xFF24405E) : RuachColors.cream200;
    final hintColor = isDark ? RuachColors.cream500 : RuachColors.cream700;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            keyboardType: TextInputType.phone,
            maxLength: 8,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? RuachColors.cream100 : RuachColors.cream900,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: hint,
              hintStyle: TextStyle(color: hintColor, fontSize: 14),
              prefixIconConstraints: const BoxConstraints(minWidth: 108),
              prefixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 14),
                  const Icon(PhosphorIconsRegular.phone, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    '+228',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(width: 1, height: 22, color: border),
                  const SizedBox(width: 10),
                ],
              ),
              filled: true,
              fillColor: fill,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: RuachSpace.s4,
                vertical: RuachSpace.s4,
              ),
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
                borderSide: const BorderSide(
                  color: RuachColors.gold500,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
