import 'package:flutter/material.dart';
import '../core/utils/responsive.dart';

/// Large friendly button for kids (min touch target 60px)
class LargeButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color color;

  const LargeButton({super.key, required this.child, this.onPressed, this.color = Colors.lightBlue});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 12.w, minHeight: 6.h),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.w)),
          padding: EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 3.w),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
