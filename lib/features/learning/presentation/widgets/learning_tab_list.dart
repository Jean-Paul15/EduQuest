import 'package:eduquest/features/user/data/user_profile_repository.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

class LearningTabList extends StatefulWidget {
  const LearningTabList({super.key, required this.title, required this.icon});
  final String title;
  final IconData icon;
  @override
  State<LearningTabList> createState() => _LearningTabListState();
}

class _LearningTabListState extends State<LearningTabList> {
  String _subtitle = 'Contenu personnalise';

  @override
  void initState() { super.initState();
    UserProfileRepository().load().then((u) => mounted
      ? setState(() => _subtitle = '${u.levelCode} ${u.serieCode} \u2022 Parcours perso') : null);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpace.l),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpace.s),
      itemBuilder: (_, i) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(AppRadius.card)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(AppRadius.xs)),
            child: Icon(widget.icon, size: 20, color: AppColors.primary)),
          title: Text('${widget.title} ${i + 1}', style: const TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
          subtitle: Text(_subtitle, style: const TextStyle(
            fontSize: 12, color: AppColors.textTertiary)),
          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary)),
      ),
    );
  }
}
