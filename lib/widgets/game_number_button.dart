// lib/widgets/game_number_button.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/utils/responsive.dart';

enum ButtonState { idle, correct, wrong }

class GameNumberButton extends StatefulWidget {
  final int number;
  final ValueChanged<int>? onTap;
  final Color color;
  final bool disabled;
  final ButtonState state;

  const GameNumberButton({super.key, required this.number, this.onTap, this.color = Colors.blue, this.disabled = false, this.state = ButtonState.idle});

  @override
  State<GameNumberButton> createState() => _GameNumberButtonState();
}

class _GameNumberButtonState extends State<GameNumberButton> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 120), lowerBound: 0.88, upperBound: 1.0, value: 1.0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.disabled) return;
    _c.reverse().then((_) => _c.forward());
    widget.onTap?.call(widget.number);
  }

  @override
  Widget build(BuildContext context) {
    final size = SizeConfig.w(18, min: 56, max: 110);
    Color bg = widget.color;
    if (widget.state == ButtonState.correct) bg = Colors.green;
    if (widget.state == ButtonState.wrong) bg = Colors.red;

    return ScaleTransition(
      scale: _c,
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: bg.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          alignment: Alignment.center,
          child: Text(widget.number.toString(), style: GoogleFonts.cairo(textStyle: TextStyle(color: Colors.white, fontSize: SizeConfig.sp(18), fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }
}
