import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_progress.dart';

class BootLoadingScreen extends StatelessWidget {
  const BootLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [RuachColors.ink300, RuachColors.ink200],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PhosphorIconsRegular.graduationCap,
                size: 42,
                color: RuachColors.gold500,
              ),
              SizedBox(height: RuachSpace.s3),
              Text(
                'RuachEdu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: RuachColors.cream100,
                ),
              ),
              SizedBox(height: RuachSpace.s4),
              RuachLoader(size: 62),
              SizedBox(height: RuachSpace.s3),
              Text(
                'Préparation de ton espace',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: RuachColors.cream100,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
