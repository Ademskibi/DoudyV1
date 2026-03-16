// lib/core/utils/responsive.dart
import 'dart:math' as math;
import 'package:flutter/widgets.dart';

/// Responsive helper for DOUDY app.
/// Initialize with `SizeConfig.init(context)` once (e.g. in `main`) after a
/// MediaQuery is available. Use the extensions on `num` such as `5.w`, `3.h`,
/// `18.sp` and the clamped variants `5.wc(min,max)`.
class SizeConfig {
  static double screenWidth = 800;
  static double screenHeight = 600;
  static double safeWidth = 800;
  static double safeHeight = 600;
  static double _blockX = 8;
  static double _blockY = 6;

  static bool get isTablet => screenWidth >= 600;

  /// Call at app start inside a Builder where MediaQuery is available.
  static void init(BuildContext context) {
    final mq = MediaQuery.of(context);
    screenWidth = mq.size.width;
    screenHeight = mq.size.height;
    final padding = mq.padding;
    safeWidth = math.max(1, screenWidth - padding.left - padding.right);
    safeHeight = math.max(1, screenHeight - padding.top - padding.bottom);
    _blockX = safeWidth / 100.0;
    _blockY = safeHeight / 100.0;
  }

  /// Returns a size in logical pixels that is `percent` of safeWidth.
  static double w(double percent, {double? min, double? max}) {
    final v = (_blockX * percent).clamp(min ?? double.negativeInfinity, max ?? double.infinity);
    return v;
  }

  /// Returns a size in logical pixels that is `percent` of safeHeight.
  static double h(double percent, {double? min, double? max}) {
    final v = (_blockY * percent).clamp(min ?? double.negativeInfinity, max ?? double.infinity);
    return v;
  }

  /// Returns a scaled font size. On tablet it multiplies by 1.3.
  static double sp(double size, {double? min, double? max}) {
    final base = (( _blockX + _blockY ) / 2.0) * (size / 10.0);
    final scaled = isTablet ? base * 1.3 : base;
    return scaled.clamp(min ?? double.negativeInfinity, max ?? double.infinity);
  }

  /// Compute number of columns for a grid given an item min width.
  static int gridColumns({required double itemMinWidth}) {
    final cols = (safeWidth / math.max(1, itemMinWidth)).floor();
    return math.max(1, cols);
  }
}

extension NumResponsive on num {
  /// Percentage width: `5.w` -> 5% of safe width in logical pixels.
  double get w => SizeConfig.w(toDouble());

  /// Percentage height: `3.h` -> 3% of safe height in logical pixels.
  double get h => SizeConfig.h(toDouble());

  /// Scaled font size: `18.sp` -> scaled size.
  double get sp => SizeConfig.sp(toDouble());

  /// Clamped width: `5.wc(min,max)` returns SizeConfig.w(5, min:max)
  double wc([double? min, double? max]) => SizeConfig.w(toDouble(), min: min, max: max);

  /// Clamped height.
  double hc([double? min, double? max]) => SizeConfig.h(toDouble(), min: min, max: max);

  /// Clamped font size.
  double spc([double? min, double? max]) => SizeConfig.sp(toDouble(), min: min, max: max);
}

