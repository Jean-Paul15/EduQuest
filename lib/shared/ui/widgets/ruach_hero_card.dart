import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_chip.dart';

/// Hero course card — full width, 220dp height, display-sm Fraunces title.
class RuachHeroCard extends StatelessWidget {
  const RuachHeroCard({
    super.key,
    required this.title,
    this.imageUrl,
    this.badge,
    this.onTap,
  });
  final String title;
  final String? imageUrl, badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(RuachRadius.xl),
          color: RuachColors.ink300,
          image: imageUrl != null
              ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [RuachColors.transparent, RuachColors.ink100],
                  ),
                ),
              ),
            ),
            Positioned(
              left: RuachSpace.s4,
              bottom: RuachSpace.s4,
              right: RuachSpace.s4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (badge != null)
                    RuachChip(label: badge!.toUpperCase()),
                  const SizedBox(height: RuachSpace.s2),
                  Text(title, style: Theme.of(context).textTheme.displaySmall, maxLines: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
