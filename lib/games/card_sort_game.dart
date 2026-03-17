// lib/games/card_sort_game.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/game_scaffold.dart';
import '../widgets/feedback_overlay.dart';
import '../services/sound_service.dart';
import '../core/utils/responsive.dart';

class CardSortGameScreen extends StatefulWidget {
  const CardSortGameScreen({super.key});

  @override
  State<CardSortGameScreen> createState() => _CardSortGameState();
}

class _CardSortGameStateData {
  final int value; // عدد الرموز على البطاقة
  bool flipped;
  _CardSortGameStateData(this.value, {this.flipped = false});
}

class _CardSortGameState extends State<CardSortGameScreen>
    with TickerProviderStateMixin, FeedbackMixin {
  final Random _rnd = Random();
  int _target = 1;
  int _score = 0;
  int _lives = 3;
  bool _locked = false;
  FeedbackType? _lastFeedback;
  List<_CardSortGameStateData> _cards = [];
  Timer? _timer;
  double _timeLeft = 1.0;
  final int _roundDurationSeconds = 10;

  @override
  void initState() {
    super.initState();
    initFeedback();
    _resetCards();
    _next();
  }

  void _resetCards() {
    _cards = List.generate(6, (i) => _CardSortGameStateData(i + 1));
  }

  void _restart() {
    setState(() {
      _score = 0;
      _lives = 3;
      _resetCards();
    });
    _next();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 1.0;
    int elapsedMs = 0;
    const interval = Duration(milliseconds: 50);
    _timer = Timer.periodic(interval, (t) {
      elapsedMs += 50;
      setState(() {
        _timeLeft = 1 - (elapsedMs / (_roundDurationSeconds * 1000));
        if (_timeLeft <= 0) {
          _timeLeft = 0;
          t.cancel();
          _onTimeout();
        }
      });
    });
  }

  void _onTimeout() {
    if (_locked) return;
    setState(() {
      _locked = true;
      _lives--;
      _lastFeedback = FeedbackType.wrong;
    });
    feedbackController.show(FeedbackType.wrong);
    SoundService.instance.playWrong();

    Future.delayed(const Duration(milliseconds: 950), () {
      if (_lives <= 0) {
        _showGameOver();
      } else {
        _next();
      }
    });
  }

  void _next() {
    final target = _rnd.nextInt(6) + 1; // عدد التفاحات المطلوبة
    setState(() {
      _target = target;
      _locked = false;
      _cards.shuffle();
      _lastFeedback = null;
    });
    _startTimer();
  }

  void _showGameOver() {
    _timer?.cancel();
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('انتهت اللعبة', style: GoogleFonts.cairo()),
        content: Text('النقاط: $_score', style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(c).pop();
              _restart();
            },
            child: Text('العب مجدداً', style: GoogleFonts.cairo()),
          )
        ],
      ),
    );
  }

  Future<void> _onDrop(int value) async {
    if (_locked) return;
    _timer?.cancel();
    setState(() {
      _locked = true;
    });

    if (value == _target) {
      _score++;
      _lastFeedback = FeedbackType.correct;
      feedbackController.show(FeedbackType.correct);
      await SoundService.instance.playCorrect();
    } else {
      _lives--;
      _lastFeedback = FeedbackType.wrong;
      feedbackController.show(FeedbackType.wrong);
      await SoundService.instance.playWrong();
    }

    await Future.delayed(const Duration(milliseconds: 950), () {
      if (_lives <= 0) {
        _showGameOver();
      } else {
        _next();
      }
    });
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
      title: 'فرز البطاقات التعليمية',
      score: _score,
      lives: _lives,
      accentColor: Colors.green,
      backgroundColor: Colors.green.shade50,
      onRestart: _restart,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Column(
              children: [
                Text(
                  'اسحب البطاقة التي تحتوي على $_target تفاحات 🍎',
                  style: GoogleFonts.cairo(
                      textStyle: TextStyle(fontSize: SizeConfig.sp(18))),
                ),
                SizedBox(height: 2.h),

                // شريط عد تنازلي بصري
                Container(
                  height: 2.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(1.w)),
                  child: FractionallySizedBox(
                    widthFactor: _timeLeft.clamp(0.0, 1.0),
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(1.w),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 2.h),
                Wrap(
                  spacing: 2.w,
                  children: _cards.map((c) {
                    return Draggable<int>(
                      data: c.value,
                      feedback: Material(child: _buildCard(c, flipped: true)),
                      childWhenDragging:
                          Opacity(opacity: 0.4, child: _buildCard(c)),
                      child: _buildCard(c),
                    );
                  }).toList(),
                ),
                SizedBox(height: 3.h),
                DragTarget<int>(
                  onAccept: _onDrop,
                  builder: (context, candidate, rejected) {
                    return Container(
                      height: 30.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3.w),
                          border: Border.all(color: Colors.grey.shade300)),
                      child: Center(
                        child: Text('ضع البطاقة هنا',
                            style: GoogleFonts.cairo(
                                textStyle: TextStyle(
                                    fontSize: SizeConfig.sp(18)))),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          FeedbackOverlay(
              controllerHolder: feedbackController,
              lastTypeHolder: _lastFeedback),
        ],
      ),
    );
  }

  Widget _buildCard(_CardSortGameStateData c, {bool flipped = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      margin: EdgeInsets.all(1.5.w),
      width: 18.w,
      height: 18.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 2,
          runSpacing: 2,
          children: List.generate(
            c.value,
            (_) => Icon(Icons.apple, color: Colors.red, size: 20),
          ),
        ),
      ),
    );
  }
}