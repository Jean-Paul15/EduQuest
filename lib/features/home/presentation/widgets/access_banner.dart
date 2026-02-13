import 'package:eduquest/features/access/data/access_repository.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

class AccessBanner extends StatelessWidget {
  const AccessBanner({super.key, required this.access});
  final AccessState access;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final promo = access.tier == 'CAMPAIGN_FREE';
    final expiry =
        access.expiresAt?.toLocal().toString().split(' ').first ?? '--';
    final active = access.hasAccess;
    final subtitle = promo
        ? 'Promotion active: acces ouvert a tous'
        : active && access.expiresAt == null
        ? 'Acces actif'
        : active
        ? 'Expire le $expiry'
        : 'Acces inactif';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.success.withValues(alpha: .1)
                  : AppColors.error.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Icon(
              active ? Icons.verified_rounded : Icons.error_outline_rounded,
              color: active ? AppColors.success : AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  access.tier,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: s.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(AppRadius.xs),
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
