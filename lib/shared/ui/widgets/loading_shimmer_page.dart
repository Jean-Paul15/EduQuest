import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/shimmer_strip.dart';
import 'package:flutter/material.dart';

class LoadingShimmerPage extends StatefulWidget {
  const LoadingShimmerPage({super.key});
  @override
  State<LoadingShimmerPage> createState() => _LoadingShimmerPageState();
}

class _LoadingShimmerPageState extends State<LoadingShimmerPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(RuachSpace.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerStrip(progress: _c, height: 28, width: 180),
              const SizedBox(height: 10),
              ShimmerStrip(progress: _c, height: 14, width: 240),
              const SizedBox(height: 24),
              ShimmerStrip(progress: _c, height: 96),
              const SizedBox(height: 14),
              ShimmerStrip(progress: _c, height: 130),
              const SizedBox(height: 14),
              ShimmerStrip(progress: _c, height: 64),
              const SizedBox(height: 14),
              ShimmerStrip(progress: _c, height: 64),
            ],
          ),
        ),
      ),
    );
  }
}
