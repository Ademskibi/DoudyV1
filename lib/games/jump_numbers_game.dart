// lib/games/jump_numbers_game.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/game_scaffold.dart';
import '../widgets/game_number_button.dart';
import '../widgets/feedback_overlay.dart';
import '../services/sound_service.dart';
import '../core/utils/responsive.dart';

class JumpNumbersGameScreen extends StatefulWidget {
  const JumpNumbersGameScreen({super.key});

  @override
  State<JumpNumbersGameScreen> createState() => _JumpNumbersGameScreenState();
}

class _JumpNumbersGameScreenState extends State<JumpNumbersGameScreen> with TickerProviderStateMixin, FeedbackMixin {
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
    setState(() { _score = 0; _lives = 3; });
    _next();
  }

  void _next() {
    final target = _rnd.nextInt(10) + 1;
    final choices = <int>{target};
    while (choices.length < 4) choices.add(_rnd.nextInt(10) + 1);
    final list = choices.toList()..shuffle();
    setState(() { _target = target; _choices = list; _locked = false; });
  }

  void _showGameOver() {
    showDialog<void>(context: context, builder: (c) => AlertDialog(title: Text('انتهت اللعبة', style: GoogleFonts.cairo()), content: Text('النقاط: $_score', style: GoogleFonts.cairo()), actions: [TextButton(onPressed: () { Navigator.of(c).pop(); _restart(); }, child: Text('العب مجدداً', style: GoogleFonts.cairo()))]));
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
      title: 'القفز على الأرقام',
      score: _score,
      lives: _lives,
      accentColor: Colors.purple,
      backgroundColor: Colors.purple.shade50,
      onRestart: _restart,
      child: Stack(children: [
        Padding(
          padding: EdgeInsets.all(3.w),
          child: Column(children: [
            SizedBox(height: 2.h),
            Text('ابحث عن الرقم: $_target', style: GoogleFonts.cairo(textStyle: TextStyle(fontSize: SizeConfig.sp(18)))),
            SizedBox(height: 2.h),
            // Animated character over a number line (simple placeholder)
            Container(height: 18.h, color: Colors.white, child: Center(child: Text('🐾', style: TextStyle(fontSize: 8.w)))),
            SizedBox(height: 2.h),
            Expanded(child: GridView.count(crossAxisCount: cols, mainAxisSpacing: 2.h, crossAxisSpacing: 2.w, children: _choices.map((n) => Center(child: GameNumberButton(number: n, onTap: _onTap, color: Colors.purple))).toList())),
          ]),
        ),
        FeedbackOverlay(controllerHolder: feedbackController, lastTypeHolder: _lastFeedback),
      ]),
    );
  }
}
