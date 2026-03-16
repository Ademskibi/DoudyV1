import 'package:flutter/material.dart';
import '../core/utils/responsive.dart';

/// A reusable large number widget styled for children.
class NumberWidget extends StatelessWidget {
  final int number;
  final double? size;
  final Color color;

  const NumberWidget({super.key, required this.number, this.size, this.color = Colors.orange});

  @override
  Widget build(BuildContext context) {
    final double finalSize = size ?? 20.h;

    return Container(
      width: finalSize,
      height: finalSize,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
      ),
      alignment: Alignment.center,
      child: Text(
        number.toString(),
        style: TextStyle(fontSize: finalSize * 0.5, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
