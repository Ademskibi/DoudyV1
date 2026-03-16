// lib/games/pizza_game.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/game_scaffold.dart';
import '../widgets/game_number_button.dart';
import '../widgets/feedback_overlay.dart';
import '../services/sound_service.dart';
import '../core/utils/responsive.dart';

class PizzaPainter extends CustomPainter {
  final int slices;
  PizzaPainter(this.slices);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < slices; i++) {
      paint.color = Colors.orange.withOpacity(1 - (i % 2) * 0.08);
      final start = (2 * pi / slices) * i - pi / 2;
      final sweep = 2 * pi / slices;
      final path = Path()..moveTo(center.dx, center.dy)..arcTo(Rect.fromCircle(center: center, radius: radius), start, sweep, false)..close();
      canvas.drawPath(path, paint);
    }
    // pepperoni dots
    final dotPaint = Paint()..color = Colors.red;
    for (int i = 0; i < slices; i++) {
      final angle = (2 * pi / slices) * i - pi / 2 + (pi / slices);
      final px = center.dx + cos(angle) * radius * 0.5;
      final py = center.dy + sin(angle) * radius * 0.5;
      canvas.drawCircle(Offset(px, py), radius * 0.06, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PizzaPainter oldDelegate) => oldDelegate.slices != slices;
}

class PizzaGameScreen extends StatefulWidget {
  const PizzaGameScreen({super.key});

  @override
  State<PizzaGameScreen> createState() => _PizzaGameScreenState();
}

class _PizzaGameScreenState extends State<PizzaGameScreen> with TickerProviderStateMixin, FeedbackMixin {
  final Random _rnd = Random();
  int _slices = 6;
  int _score = 0;
  int _lives = 3;
  bool _locked = false;
  FeedbackType? _lastFeedback;
  List<int> _choices = [];

  @override
  void initState() {
    super.initState();
    initFeedback();
    _next();
  }

  void _restart() {
    setState(() { _score = 0; _lives = 3; });
    _next();
  }

  void _next() {
    final target = _rnd.nextInt(10) + 1;
    final choices = <int>{target};
    while (choices.length < 4) choices.add(_rnd.nextInt(10) + 1);
    final list = choices.toList()..shuffle();
    setState(() { _slices = target; _choices = list; _locked = false; });
  }

  void _showGameOver() {
    showDialog<void>(context: context, builder: (c) => AlertDialog(title: Text('انتهت اللعبة', style: GoogleFonts.cairo()), content: Text('النقاط: $_score', style: GoogleFonts.cairo()), actions: [TextButton(onPressed: () { Navigator.of(c).pop(); _restart(); }, child: Text('العب مجدداً', style: GoogleFonts.cairo()))]));
  }

  Future<void> _onTap(int n) async {
    if (_locked) return;
    setState(() { _locked = true; });
    if (n == _slices) {
      _score++;
      _lastFeedback = FeedbackType.correct;
      feedbackController.show(FeedbackType.correct);
      await SoundService.instance.playCorrect();
      await Future.delayed(const Duration(milliseconds: 950));
      _next();
    } else {
      _lives--;
      _lastFeedback = FeedbackType.wrong;
      feedbackController.show(FeedbackType.wrong);
      await SoundService.instance.playWrong();
      await Future.delayed(const Duration(milliseconds: 950));
      if (_lives <= 0) _showGameOver(); else _next();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cols = SizeConfig.gridColumns(itemMinWidth: 90);
    return GameScaffold(
      title: 'لعبة البيتزا',
      score: _score,
      lives: _lives,
      accentColor: Colors.deepOrange,
      backgroundColor: Colors.orange.shade50,
      onRestart: _restart,
      child: Stack(children: [
        Padding(
          padding: EdgeInsets.all(3.w),
          child: Column(children: [
            SizedBox(height: 2.h),
            SizedBox(height: 30.h, child: Center(child: AspectRatio(aspectRatio: 1, child: CustomPaint(painter: PizzaPainter(_slices))))),
            SizedBox(height: 2.h),
            Text('كم شريحة؟', style: GoogleFonts.cairo(textStyle: TextStyle(fontSize: SizeConfig.sp(18)))),
            SizedBox(height: 2.h),
            Expanded(child: GridView.count(crossAxisCount: cols, mainAxisSpacing: 2.h, crossAxisSpacing: 2.w, children: _choices.map((n) => Center(child: GameNumberButton(number: n, onTap: _onTap, color: Colors.deepOrange))).toList())),
          ]),
        ),
        FeedbackOverlay(controllerHolder: feedbackController, lastTypeHolder: _lastFeedback),
      ]),
    );
  }
}
