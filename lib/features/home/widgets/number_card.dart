import 'package:flutter/material.dart';

class NumberCard extends StatefulWidget {
  final int number;
  final VoidCallback? onTap;
  const NumberCard({required this.number, this.onTap, super.key});

  @override
  State<NumberCard> createState() => _NumberCardState();
}

class _NumberCardState extends State<NumberCard> with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _tapDown(TapDownDetails _) => setState(() => _scale = 0.95);
  void _tapUp(TapUpDetails _) => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    final color = Colors.primaries[widget.number % Colors.primaries.length];
    return GestureDetector(
      onTapDown: _tapDown,
      onTapUp: _tapUp,
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.shade200, color.shade400]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: Offset(0, 6))],
          ),
          child: Center(
            child: Text('${widget.number}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
