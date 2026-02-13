import 'dart:ui';

import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Carte glassmorphisme avec citation en Playfair Display
class QuoteCard extends StatelessWidget {
  const QuoteCard({
    super.key,
    required this.glowIntensity,
    required this.floatOffset,
  });

  final double glowIntensity;
  final double floatOffset;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: _glassDeco(dark),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.l),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _content(dark),
          ),
        ),
      ),
    );
  }

  Column _content(bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.translate(
          offset: Offset(0, -floatOffset),
          child: Text(
            '\u00AB',
            style: GoogleFonts.playfairDisplay(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              height: 0.7,
              color: AppColors.accent.withValues(alpha: glowIntensity),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'La réussite, c\'est d\'abord et surtout '
          'd\'être au travail quand les autres '
          'vont à la pêche.',
          style: GoogleFonts.playfairDisplay(
            fontSize: 17,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
            height: 1.6,
            letterSpacing: 0.15,
            color: dark ? Colors.white70 : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _authorRow(),
      ],
    );
  }

  BoxDecoration _glassDeco(bool dark) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? [
                const Color(0xFF1E2A5E).withValues(alpha: 0.55),
                const Color(0xFF0D1B3E).withValues(alpha: 0.45),
              ]
            : [
                Colors.white.withValues(alpha: 0.45),
                const Color(0xFFFFF7EE).withValues(alpha: 0.35),
              ],
      ),
      borderRadius: BorderRadius.circular(AppRadius.l),
      border: Border.all(
        color: (dark ? Colors.white : AppColors.primary).withValues(
          alpha: 0.12,
        ),
      ),
    );
  }

  Widget _authorRow() {
    return Row(
      children: [
        Container(
          width: 32,
          height: 2,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: glowIntensity * 0.6),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const Spacer(),
        Text(
          '— Philippe Bouvard',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            color: AppColors.textTertiary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
