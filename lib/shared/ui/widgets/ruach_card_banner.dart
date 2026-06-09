import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Image banner for course cards — internal widget used by [RuachCourseCard].
class CourseCardBanner extends StatelessWidget {
  const CourseCardBanner({super.key, this.imageUrl, required this.isDark});
  final String? imageUrl;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      width: double.infinity,
      child: imageUrl != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(isDark),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          isDark ? RuachColors.ink300 : RuachColors.cream100,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : _placeholder(isDark),
    );
  }

  Widget _placeholder(bool isDark) => Container(
        color: isDark ? RuachColors.ink400 : RuachColors.cream100,
        child: const Center(
          child: Icon(PhosphorIconsRegular.book, size: 32, color: RuachColors.cream500),
        ),
      );
}
