import 'package:eduquest/features/home/domain/motivational_quote.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Carte glassmorphisme compacte avec citation Playfair Display
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
    return GlassContainer(
      margin: const EdgeInsets.only(top: RuachSpace.s2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      blur: 18,
      child: _content(dark),
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
            style: GoogleFonts.fraunces(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              height: 0.7,
              color: RuachColors.gold600.withValues(alpha: glowIntensity),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          kMotivationalQuote,
          style: GoogleFonts.fraunces(
            fontSize: 15,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
            height: 1.55,
            letterSpacing: 0.1,
            color: dark ? RuachColors.cream100 : RuachColors.cream900,
          ),
        ),
        const SizedBox(height: 10),
        _authorRow(dark),
      ],
    );
  }

  Widget _authorRow(bool dark) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 2,
          decoration: BoxDecoration(
            color: RuachColors.gold600.withValues(alpha: glowIntensity * 0.6),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const Spacer(),
        Text(
          '— $kMotivationalQuoteAuthor',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            color: dark ? RuachColors.cream500 : RuachColors.cream700,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
