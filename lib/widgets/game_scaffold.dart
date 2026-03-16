// lib/widgets/game_scaffold.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/utils/responsive.dart';

class GameScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final int score;
  final int lives;
  final Color backgroundColor;
  final Color accentColor;
  final VoidCallback? onRestart;

  const GameScaffold({super.key, required this.title, required this.child, this.score = 0, this.lives = 3, this.backgroundColor = Colors.white, this.accentColor = Colors.blue, this.onRestart});

  @override
  Widget build(BuildContext context) {
    final topBarHeight = 12.h;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Container(
            height: topBarHeight,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(4.w)),
              boxShadow: [BoxShadow(color: accentColor.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    splashRadius: 20,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(child: Text(title, style: GoogleFonts.cairo(textStyle: TextStyle(color: Colors.white, fontSize: 3.sp, fontWeight: FontWeight.bold)))),
                  // Score chip
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2.w)),
                    child: Row(children: [Icon(Icons.star, color: Colors.yellow.shade700, size: 3.w), SizedBox(width: 1.w), Text('$score', style: GoogleFonts.cairo(textStyle: TextStyle(color: Colors.white, fontSize: 2.sp)))]),
                  ),
                  SizedBox(width: 2.w),
                  // Lives
                  Row(children: List.generate(3, (i) => Padding(padding: EdgeInsets.symmetric(horizontal: 0.6.w), child: Icon(i < lives ? Icons.favorite : Icons.favorite_border, color: Colors.pinkAccent, size: 3.2.w)))),
                  SizedBox(width: 2.w),
                  IconButton(
                    onPressed: onRestart,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
