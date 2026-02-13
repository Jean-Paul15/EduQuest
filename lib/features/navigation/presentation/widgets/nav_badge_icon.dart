import 'package:flutter/material.dart';

class NavBadgeIcon extends StatelessWidget {
  const NavBadgeIcon({
    super.key,
    required this.icon,
    required this.count,
  });

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return Icon(icon);
    return Badge.count(count: count > 9 ? 9 : count, child: Icon(icon));
  }
}
