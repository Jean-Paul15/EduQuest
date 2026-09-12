import 'package:flutter/material.dart';
import 'constants.dart';
import 'quiz_icons.dart';

/// Shows quiz progress: linear progress bar + timer + question counter.
class ProgressHeader extends StatelessWidget {
  const ProgressHeader({
    super.key,
    required this.currentIndex,
    required this.totalQuestions,
    required this.secondsLeft,
    required this.totalSeconds,
  });

  final int currentIndex; // 0-based
  final int totalQuestions;
  final int secondsLeft;
  final int totalSeconds;

  double get _progress =>
      totalQuestions < 2 ? 0 : currentIndex / (totalQuestions - 1);

  String get _counterLabel => 'Question ${currentIndex + 1}/$totalQuestions';

  String get _timerLabel => '${secondsLeft}s';

  Color get _timerColor =>
      secondsLeft <= 5 ? error400 : secondsLeft <= 10 ? gold500 : cream700;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ink800,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Container(height: 6, color: surfaceStroke),
                FractionallySizedBox(
                  widthFactor: _progress.clamp(0, 1),
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [gold600, gold500]),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: surfaceBase,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: surfaceStroke),
                ),
                child: Row(
                  children: [
                    Icon(QuizIcons.timer, color: cream700, size: 15),
                    const SizedBox(width: 4),
                    Text(
                      _timerLabel,
                      style: TextStyle(
                        color: _timerColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                _counterLabel,
                style: TextStyle(
                  color: cream900,
                  fontSize: 13,
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
