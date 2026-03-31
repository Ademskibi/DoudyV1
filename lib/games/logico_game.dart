// lib/games/logico_game.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/game_scaffold.dart';
import '../widgets/feedback_overlay.dart';
import '../services/sound_service.dart';
import '../core/utils/responsive.dart';

class LogicoGameScreen extends StatefulWidget {
  const LogicoGameScreen({super.key});

  @override
  State<LogicoGameScreen> createState() => _LogicoGameScreenState();
}

class _LogicoGameScreenState extends State<LogicoGameScreen>
    with TickerProviderStateMixin, FeedbackMixin {
  final Random _rnd = Random();

  int _score = 0;
  int _lives = 3;
  bool _locked = false;

  FeedbackType? _lastFeedback;
  List<int> _left = [];
  List<int> _right = [];
  int? _selectedLeft;

  Set<int> _matchedLeft = {};
  Set<int> _matchedRight = {};

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
    final base = List.generate(9, (i) => i + 1)..shuffle();
    final numbers = base.take(3).toList();

    setState(() {
      _left = List.from(numbers)..shuffle();
      _right = List.from(numbers)..shuffle();

      _selectedLeft = null;
      _matchedLeft = {};
      _matchedRight = {};
      _locked = false;
    });
  }

  void _showGameOver() {
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

  Future<void> _onMatch(int leftIndex, int rightIndex) async {
    if (_locked) return;
    if (_matchedLeft.contains(leftIndex)) return;
    if (_matchedRight.contains(rightIndex)) return;

    final leftValue = _left[leftIndex];
    final rightValue = _right[rightIndex];

    if (leftValue == rightValue) {
      setState(() {
        _matchedLeft.add(leftIndex);
        _matchedRight.add(rightIndex);
        _selectedLeft = null;
      });

      await SoundService.instance.playCorrect();

      // 🎉 All matched
      if (_matchedLeft.length == _left.length) {
        _score++;
        _lastFeedback = FeedbackType.correct;
        feedbackController.show(FeedbackType.correct);

        await Future.delayed(const Duration(milliseconds: 900));
        _next();
      }
    } else {
      _lives--;

      setState(() {
        _selectedLeft = null;
      });

      _lastFeedback = FeedbackType.wrong;
      feedbackController.show(FeedbackType.wrong);

      await SoundService.instance.playWrong();

      await Future.delayed(const Duration(milliseconds: 900));

      if (_lives <= 0) {
        _showGameOver();
      }
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
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Column(
              children: [
                Text(
                  'طابق الرقم مع عدد الدوائر',
                  style: GoogleFonts.cairo(
                    textStyle: TextStyle(fontSize: SizeConfig.sp(18)),
                  ),
                ),
                SizedBox(height: 2.h),

                Expanded(
                  child: Row(
                    children: [
                      /// LEFT SIDE
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _left.asMap().entries.map((entry) {
                            int index = entry.key;
                            int n = entry.value;

                            final isMatched =
                                _matchedLeft.contains(index);

                            return Padding(
                              padding: EdgeInsets.all(1.5.w),
                              child: GestureDetector(
                                onTap: isMatched
                                    ? null
                                    : () {
                                        setState(() {
                                          _selectedLeft = index;
                                        });
                                      },
                                child: Container(
                                  padding: EdgeInsets.all(1.5.w),
                                  decoration: BoxDecoration(
                                    color: isMatched
                                        ? Colors.grey.shade200
                                        : _selectedLeft == index
                                            ? Colors.teal.shade100
                                            : Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(2.w),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$n',
                                      style: GoogleFonts.cairo(
                                        textStyle: TextStyle(
                                          fontSize: SizeConfig.sp(20),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      VerticalDivider(width: 4.w),

                      /// RIGHT SIDE
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _right.asMap().entries.map((entry) {
                            int index = entry.key;
                            int n = entry.value;

                            final isMatched =
                                _matchedRight.contains(index);

                            return Padding(
                              padding: EdgeInsets.all(1.5.w),
                              child: GestureDetector(
                                onTap: isMatched
                                    ? null
                                    : () {
                                        if (_selectedLeft == null) return;
                                        _onMatch(_selectedLeft!, index);
                                      },
                                child: Container(
                                  padding: EdgeInsets.all(1.5.w),
                                  decoration: BoxDecoration(
                                    color: isMatched
                                        ? Colors.grey.shade200
                                        : Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(2.w),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: List.generate(
                                      n,
                                      (i) => Padding(
                                        padding: EdgeInsets.only(right: 1.w),
                                        child: Icon(
                                          Icons.circle,
                                          size: 2.5.w,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
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
              ],
            ),
          ),

          /// Feedback overlay
          FeedbackOverlay(
            controllerHolder: feedbackController,
            lastTypeHolder: _lastFeedback,
          ),
        ],
      ),
    );
  }
}