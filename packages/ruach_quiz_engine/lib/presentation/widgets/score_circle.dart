import 'package:flutter/material.dart';
import '../constants.dart';

/// Circular score indicator showing percentage with pass/fail coloring.
class ScoreCircle extends StatelessWidget {
  const ScoreCircle({super.key, required this.percent, required this.passed});
  final double percent;
  final bool passed;
  static const _size = 116.0;

  @override
  Widget build(BuildContext context) {
    final color = passed ? success600 : error400;
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: _size,
            height: _size,
            child: CircularProgressIndicator(
              value: percent / 100,
              strokeWidth: 8,
              backgroundColor: surfaceStroke,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${percent.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Score',
                style: TextStyle(
                  color: cream700,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
