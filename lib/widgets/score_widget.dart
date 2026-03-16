import 'package:flutter/material.dart';

/// Simple score widget that shows up to 3 stars.
class ScoreWidget extends StatelessWidget {
  final int stars; // 0..3
  const ScoreWidget({super.key, this.stars = 0});

  @override
  Widget build(BuildContext context) {
    final safeStars = stars.clamp(0, 3);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final filled = i < safeStars;
        return Icon(
          Icons.star,
          color: filled ? Colors.amber : Colors.grey.shade300,
          size: 28,
        );
      }),
    );
  }
}
