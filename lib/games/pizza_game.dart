import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PizzaGameScreen extends StatefulWidget {
  const PizzaGameScreen({super.key});

  @override
  State<PizzaGameScreen> createState() => _PizzaGameScreenState();
}

class _PizzaGameScreenState extends State<PizzaGameScreen> {
  final Random _random = Random();

  int correctAnswer = 3;
  List<int> options = [];

  bool showFeedback = false;
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

void _generateQuestion() {
  correctAnswer = _random.nextInt(8) + 2; // 2 → 9 slices

  Set<int> uniqueOptions = {correctAnswer};

  while (uniqueOptions.length < 4) {
    int value = _random.nextInt(9) + 1;

    // avoid duplicates automatically (Set)
    uniqueOptions.add(value);
  }

  options = uniqueOptions.toList();
  options.shuffle();

  setState(() {});
}

  void _checkAnswer(int value) {
    setState(() {
      isCorrect = value == correctAnswer;
      showFeedback = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        showFeedback = false;
      });
      _generateQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF3E0),
              Color(0xFFFFE0B2),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 🎯 Question
              Text(
                "كم شريحة؟",
                style: GoogleFonts.cairo(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),

              // 🍕 Pizza
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CustomPaint(
                      painter: PizzaPainter(correctAnswer),
                    ),
                  ),

                  // ✨ Feedback Animation
                  if (showFeedback)
                    AnimatedScale(
                      scale: isCorrect ? 1.3 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? Colors.green : Colors.red,
                        size: 100,
                      ),
                    ),
                ],
              ),

              // 🔘 Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: options
                      .map((e) => GameNumberButton(
                            number: e,
                            onTap: () => _checkAnswer(e),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
// 🍕 Pizza Painter
//
class PizzaPainter extends CustomPainter {
  final int slices;

  PizzaPainter(this.slices);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final sliceAngle = (2 * pi) / slices;

    // 🎨 Fill slices
    for (int i = 0; i < slices; i++) {
      final paint = Paint()
        ..color = i % 2 == 0
            ? Colors.orange
            : Colors.deepOrangeAccent;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sliceAngle,
        sliceAngle,
        true,
        paint,
      );
    }

    // ✨ Slice borders (LINES BETWEEN SLICES)
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < slices; i++) {
      final angle = i * sliceAngle;

      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      canvas.drawLine(center, Offset(x, y), linePaint);
    }

    // 🍕 Outer border
    final border = Paint()
      ..color = Colors.brown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

//
// 🔘 Number Button
//
class GameNumberButton extends StatefulWidget {
  final int number;
  final VoidCallback onTap;

  const GameNumberButton({
    super.key,
    required this.number,
    required this.onTap,
  });

  @override
  State<GameNumberButton> createState() => _GameNumberButtonState();
}

class _GameNumberButtonState extends State<GameNumberButton> {
  double scale = 1.0;

  void _tapDown(TapDownDetails d) {
    setState(() => scale = 0.9);
  }

  void _tapUp(TapUpDetails d) {
    setState(() => scale = 1.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _tapDown,
      onTapUp: _tapUp,
      onTapCancel: () => setState(() => scale = 1.0),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.orange, Colors.deepOrange],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.number.toString(),
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}