// lib/games/logico_game.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/game_scaffold.dart';
import '../widgets/game_number_button.dart';
import '../widgets/feedback_overlay.dart';
import '../services/sound_service.dart';
import '../core/utils/responsive.dart';

class LogicoGameScreen extends StatefulWidget {
  const LogicoGameScreen({super.key});

  @override
  State<LogicoGameScreen> createState() => _LogicoGameScreenState();
}

class _LogicoGameScreenState extends State<LogicoGameScreen> with TickerProviderStateMixin, FeedbackMixin {
  final Random _rnd = Random();
  int _target = 1;
  int _score = 0;
  int _lives = 3;
  bool _locked = false;
  FeedbackType? _lastFeedback;
  List<int> _left = [];
  List<int> _right = [];

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
    final base = List.generate(6, (i) => i + 1)..shuffle();
    setState(() {
      _left = base.take(3).toList();
      _right = base.skip(3).take(3).toList();
      _target = _left[_rnd.nextInt(_left.length)];
      _locked = false;
    });
  }

  void _showGameOver() {
    showDialog<void>(context: context, builder: (c) => AlertDialog(title: Text('انتهت اللعبة', style: GoogleFonts.cairo()), content: Text('النقاط: $_score', style: GoogleFonts.cairo()), actions: [TextButton(onPressed: () { Navigator.of(c).pop(); _restart(); }, child: Text('العب مجدداً', style: GoogleFonts.cairo()))]));
  }

  Future<void> _onMatch(int leftValue, int rightValue) async {
    if (_locked) return;
    setState(() { _locked = true; });
    if (leftValue == rightValue) {
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
    return GameScaffold(
      title: 'نشاط Logico',
      score: _score,
      lives: _lives,
      accentColor: Colors.teal,
      backgroundColor: Colors.teal.shade50,
      onRestart: _restart,
      child: Stack(children: [
        Padding(
          padding: EdgeInsets.all(3.w),
          child: Column(children: [
            Text('طابق الأرقام المماثلة', style: GoogleFonts.cairo(textStyle: TextStyle(fontSize: SizeConfig.sp(18)))),
            SizedBox(height: 2.h),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _left.map((n) {
                        return Padding(
                          padding: EdgeInsets.all(1.5.w),
                          child: GestureDetector(
                            onTap: () { /* select left */ },
                            child: Container(
                              padding: EdgeInsets.all(1.5.w),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2.w)),
                              child: Center(child: Text('$n', style: GoogleFonts.cairo(textStyle: TextStyle(fontSize: SizeConfig.sp(20)))))),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  VerticalDivider(width: 4.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _right.map((n) {
                        return Padding(
                          padding: EdgeInsets.all(1.5.w),
                          child: GestureDetector(
                            onTap: () { _onMatch(_target, n); },
                            child: Container(
                              padding: EdgeInsets.all(1.5.w),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2.w)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.circle, size: 2.5.w),
                                  SizedBox(width: 1.w),
                                  Text('x $n', style: GoogleFonts.cairo(textStyle: TextStyle(fontSize: SizeConfig.sp(18)))),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
        FeedbackOverlay(controllerHolder: feedbackController, lastTypeHolder: _lastFeedback),
      ]),
    );
  }
}
