import 'package:eduquest/features/user/data/user_profile_repository.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
      padding: const EdgeInsets.all(RuachSpace.s4),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
      itemBuilder: (_, i) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(color: RuachColors.cream200),
          borderRadius: BorderRadius.circular(RuachRadius.lg)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: RuachColors.gold500.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(RuachRadius.sm)),
            child: Icon(widget.icon, size: 20, color: RuachColors.gold500)),
          title: Text('${widget.title} ${i + 1}', style: const TextStyle(
            color: RuachColors.cream900, fontWeight: FontWeight.w500)),
          subtitle: Text(_subtitle, style: const TextStyle(
            fontSize: 12, color: RuachColors.cream700)),
          trailing: const Icon(PhosphorIconsRegular.caretRight, color: RuachColors.cream700)),
      ),
    );
  }
}
