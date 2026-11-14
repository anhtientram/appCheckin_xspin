import 'dart:math' as math;

import 'package:checkin/base/app_responsive.dart';
import 'package:flutter/material.dart';

class AppFontSize {
  static double? sizeTitle = 40;
  static double? sizeMedium = 20;
  static double? sizeSmall = 16;
  static double? sizeTable = 18;
  static double? sizeLarge = 24;
  static double? sizeSuperLarge = 32;
  static double? sizeSuperSmall = 14;
  static double? sizeSuperSmalls = 12;
  static double? sizeStatus = 13;

  static double deviceTextScale(BuildContext context) {
    return context.responsive.deviceTextScale;
  }

  static double effectiveTextScale(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final systemScale = mediaQuery.textScaler.scale(1.0);
    final clampedSystemScale = systemScale.clamp(0.9, 1.2).toDouble();
    final deviceScale = deviceTextScale(context);
    return math.max(0.9, math.min(clampedSystemScale * deviceScale, 1.6));
  }
}

class AppFontWeight {
  static const bold = FontWeight.bold;
}
