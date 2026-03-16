// lib/games/chairs_game.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/game_scaffold.dart';
import '../widgets/game_number_button.dart';
import '../widgets/feedback_overlay.dart';
import '../services/sound_service.dart';
import '../core/utils/responsive.dart';
import '../core/utils/responsive.dart';

class ChairsGameScreen extends StatefulWidget {
  const ChairsGameScreen({super.key});

  @override
  State<ChairsGameScreen> createState() => _ChairsGameScreenState();
}

class _ChairsGameScreenState extends State<ChairsGameScreen> with TickerProviderStateMixin, FeedbackMixin {
  final Random _rnd = Random();
  int _target = 1;
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
    setState(() {
      _score = 0;
      _lives = 3;
    });
    _next();
  }

  void _next() {
    final target = _rnd.nextInt(10) + 1;
    final choices = <int>{target};
    while (choices.length < 4) choices.add(_rnd.nextInt(10) + 1);
    final list = choices.toList()..shuffle();
    setState(() {
      _target = target;
      _choices = list;
      _locked = false;
    });
  }

  void _showGameOver() {
    showDialog<void>(context: context, builder: (c) {
      return AlertDialog(
        title: Text('انتهت اللعبة', style: GoogleFonts.cairo()),
        content: Text('النقاط: $_score', style: GoogleFonts.cairo()),
        actions: [TextButton(onPressed: () { Navigator.of(c).pop(); _restart(); }, child: Text('العب مجدداً', style: GoogleFonts.cairo()))],
      );
    });
  }

  Future<void> _onTap(int n) async {
    if (_locked) return;
    setState(() { _locked = true; });
    if (n == _target) {
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
      title: 'لعبة الكراسي',
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
            // Visual: chairs row
            Wrap(spacing: 2.w, children: List.generate(_target, (i) => Icon(Icons.chair, size: 8.w, color: Colors.brown))),
            SizedBox(height: 3.h),
            Text('اضغط على العدد الصحيح من الكراسي', style: GoogleFonts.cairo(textStyle: TextStyle(fontSize: SizeConfig.sp(18)))),
            SizedBox(height: 2.h),
            Expanded(
              child: GridView.count(
                crossAxisCount: cols,
                mainAxisSpacing: 2.h,
                crossAxisSpacing: 2.w,
                children: _choices.map((n) => Center(child: GameNumberButton(number: n, onTap: _onTap, color: Colors.deepOrange))).toList(),
              ),
            ),
          ]),
        ),
        // feedback overlay uses last feedback type for visuals
        FeedbackOverlay(controllerHolder: feedbackController, lastTypeHolder: _lastFeedback),
      ]),
    );
  }
}
