import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key, required this.onSupport});

  final VoidCallback onSupport;

  @override
  Widget build(BuildContext context) => RuachAppBar(
        title: 'RuachNova',
        actions: [
          IconButton(
            onPressed: onSupport,
            icon: const Icon(PhosphorIconsRegular.headset),
          ),
        ],
      );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
