import 'package:eduquest/features/access/data/access_repository.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AccessBanner extends StatelessWidget {
  const AccessBanner({super.key, required this.access});
  final AccessState access;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final promo = access.tier == 'CAMPAIGN_FREE';
    final trial = access.isTrialFull;
    final expiry =
        access.expiresAt?.toLocal().toString().split(' ').first ?? '--';
    final active = access.hasAccess;
    final subtitle = promo
        ? access.expiresAt == null
              ? 'Promotion active: accès ouvert à tous'
              : 'Promotion active jusqu’au $expiry'
        : trial
        ? 'Accès complet offert jusqu’au $expiry'
        : access.isFreeLight
        ? 'Orientation, assistant et contenus gratuits restent ouverts'
        : active && access.expiresAt == null
        ? 'Accès actif'
        : active
        ? 'Expire le $expiry'
        : 'Accès inactif';
    return GlassContainer(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(RuachSpace.s2),
            decoration: BoxDecoration(
              color: active
                  ? RuachColors.success600.withValues(alpha: .1)
                  : RuachColors.error400.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(RuachRadius.sm),
            ),
            child: Icon(
              active
                  ? PhosphorIconsRegular.sealCheck
                  : PhosphorIconsRegular.warningCircle,
              color: active ? RuachColors.success600 : RuachColors.error400,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  access.displayTier,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: s.onSurface,
                  ),
                ),
                const SizedBox(height: RuachSpace.s1),
                Text(
                  subtitle,
                  style: TextStyle(color: s.onSurfaceVariant, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: RuachSpace.s3,
              vertical: RuachSpace.s1,
            ),
            decoration: BoxDecoration(
              color: s.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(RuachRadius.sm),
            ),
            child: Text(
              active ? 'Actif' : 'Inactif',
              style: TextStyle(
                color: s.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
