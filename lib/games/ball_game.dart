// lib/games/ball_game.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/game_scaffold.dart';
import '../widgets/game_number_button.dart';
import '../widgets/feedback_overlay.dart';
import '../services/sound_service.dart';
import '../core/utils/responsive.dart';

class BallGameScreen extends StatefulWidget {
  const BallGameScreen({super.key});

  @override
  State<BallGameScreen> createState() => _BallGameScreenState();
}

class _BallGameScreenState extends State<BallGameScreen> with TickerProviderStateMixin, FeedbackMixin {
  final Random _rnd = Random();
  int _target = 1;
  int _score = 0;
  int _lives = 3;
  bool _locked = false;
  FeedbackType? _lastFeedback;
  Timer? _timer;
  double _ballPos = 0.0;
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

  void _startBall() {
    _timer?.cancel();
    _ballPos = 0.0;
    _timer = Timer.periodic(const Duration(milliseconds: 90), (t) {
      setState(() {
        _ballPos += 0.06;
        if (_ballPos >= 1.0) { _ballPos = 1.0; _timer?.cancel(); }
      });
    });
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
    _startBall();
  }

  void _showGameOver() {
    showDialog<void>(context: context, builder: (c) => AlertDialog(title: Text('انتهت اللعبة', style: GoogleFonts.cairo()), content: Text('النقاط: $_score', style: GoogleFonts.cairo()), actions: [TextButton(onPressed: () { Navigator.of(c).pop(); _restart(); }, child: Text('العب مجدداً', style: GoogleFonts.cairo()))]));
  }

  Future<void> _onTap(int n) async {
    if (_locked) return;
    setState(() { _locked = true; });
    await SoundService.instance.playClick();
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
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cols = SizeConfig.gridColumns(itemMinWidth: 90);
    return GameScaffold(
      title: 'تمرير الكرة',
      score: _score,
      lives: _lives,
      accentColor: Colors.blue,
      backgroundColor: Colors.blue.shade50,
      onRestart: _restart,
      child: Stack(children: [
        Padding(
          padding: EdgeInsets.all(3.w),
          child: Column(children: [
            SizedBox(height: 2.h),
            SizedBox(height: 35.h, child: LayoutBuilder(builder: (context, bc) {
              final x = bc.maxWidth * _ballPos;
              return Stack(children: [
                Container(color: Colors.transparent),
                Positioned(left: x.clamp(1.w, bc.maxWidth - 12.w), top: 3.h, child: CircleAvatar(radius: 6.h, backgroundColor: Colors.red, child: Icon(Icons.sports_baseball, color: Colors.white, size: 5.w))),
              ]);
            })),
            SizedBox(height: 2.h),
            Text('اضغط الرقم قبل توقف الكرة', style: GoogleFonts.cairo(textStyle: TextStyle(fontSize: SizeConfig.sp(18)))),
            SizedBox(height: 2.h),
            Expanded(child: GridView.count(crossAxisCount: cols, mainAxisSpacing: 2.h, crossAxisSpacing: 2.w, children: _choices.map((n) => Center(child: GameNumberButton(number: n, onTap: _onTap, color: Colors.blue))).toList())),
          ]),
        ),
        FeedbackOverlay(controllerHolder: feedbackController, lastTypeHolder: _lastFeedback),
      ]),
    );
  }
}
