import 'package:eduquest/features/home/presentation/widgets/quote_card.dart';
import 'package:flutter/material.dart';

/// Conteneur anime pour la citation motivationnelle
/// Gere le fade-in initial et l'effet de respiration continu
class MotivationalQuote extends StatefulWidget {
  const MotivationalQuote({super.key});

  @override
  State<MotivationalQuote> createState() => _MotivationalQuoteState();
}

class _MotivationalQuoteState extends State<MotivationalQuote>
    with TickerProviderStateMixin {
  late final AnimationController _fade;
  late final AnimationController _pulse;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _fadeAnim = CurvedAnimation(parent: _fade, curve: Curves.easeOut);
    _glowAnim = Tween(
      begin: 0.3,
      end: 0.75,
    ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _fade.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, __) => QuoteCard(
          glowIntensity: _glowAnim.value,
          floatOffset: _pulse.value * 3,
        ),
      ),
    );
  }
}
