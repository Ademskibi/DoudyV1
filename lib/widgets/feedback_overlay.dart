// lib/widgets/feedback_overlay.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/utils/responsive.dart';

enum FeedbackType { correct, wrong }

class FeedbackController {
  final AnimationController controller;
  FeedbackController({required this.controller});

  void show(FeedbackType type) {
    controller.stop();
    controller.reset();
    controller.forward();
  }

  void dispose() {
    controller.dispose();
  }
}

mixin FeedbackMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  late FeedbackController feedbackController;

  void initFeedback() {
    final c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    feedbackController = FeedbackController(controller: c);
  }

  void showFeedback(FeedbackType type) {
    feedbackController.show(type);
  }

  @override
  void dispose() {
    try { feedbackController.dispose(); } catch (_) {}
    super.dispose();
  }
}

class FeedbackOverlay extends StatelessWidget {
  final FeedbackController controllerHolder;
  final FeedbackType? lastTypeHolder;
  const FeedbackOverlay({super.key, required this.controllerHolder, this.lastTypeHolder});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: AnimatedBuilder(
        animation: controllerHolder.controller,
        builder: (context, child) {
          final anim = controllerHolder.controller;
          final t = anim.value;
          Color? overlayColor;
          String emoji = '';
          if (anim.status == AnimationStatus.forward || t > 0) {
            // Determine type by sampling lastTypeHolder if provided
            // default to correct when null
            final type = lastTypeHolder ?? FeedbackType.correct;
            overlayColor = type == FeedbackType.correct ? Colors.green.withOpacity(0.25 * (1 - t)) : Colors.red.withOpacity(0.25 * (1 - t));
            emoji = type == FeedbackType.correct ? '🎉' : '💔';
          }

          return Stack(children: [
            // Full screen color flash
            Opacity(opacity: overlayColor == null ? 0.0 : overlayColor.opacity, child: Container(color: overlayColor ?? Colors.transparent)),
            // Center emoji burst
            Positioned.fill(
              child: Center(
                child: Transform.scale(
                  scale: 1 + Curves.elasticOut.transform((1 - (t)).clamp(0.0, 1.0)) * 0.6,
                  child: Opacity(opacity: (1 - t).clamp(0.0, 1.0), child: Text(emoji, style: TextStyle(fontSize: 30.w, fontFamily: GoogleFonts.cairo().fontFamily))),
                ),
              ),
            ),
            // Particles for correct
            if (lastTypeHolder == FeedbackType.correct)
              ...List.generate(12, (i) {
                final angle = (i / 12.0) * pi * 2;
                final radius = 8.w * (0.5 + (i % 3) * 0.5);
                final dx = cos(angle) * radius * (1 - t);
                final dy = sin(angle) * radius * (1 - t) - (t * 40.h * t);
                return Positioned(
                  left: (SizeConfig.safeWidth / 2) + dx,
                  top: (SizeConfig.safeHeight / 2) + dy,
                  child: Opacity(
                    opacity: (1 - t).clamp(0.0, 1.0),
                    child: Container(width: 2.w, height: 2.w, decoration: BoxDecoration(color: Colors.primaries[i % Colors.primaries.length], shape: BoxShape.circle)),
                  ),
                );
              }),
          ]);
        },
      ),
    );
  }
}
