import 'package:checkin/base/app_responsive.dart';
import 'package:flutter/material.dart';

/// Shared visual defaults for modal dialogs used throughout the app.
class AppDialog {
  AppDialog._();

  static const Color backgroundColor = Colors.white;

  static double? width(BuildContext context) {
    final responsive = context.responsive;
    if (!responsive.isTablet) return null;

    final maxWidth = responsive.value(
      phone: 420.0,
      tablet: 760.0,
      largeTablet: 860.0,
      extraLargeTablet: 980.0,
    );
    final availableWidth = responsive.width - 24;
    return availableWidth < maxWidth ? availableWidth : maxWidth;
  }

  static BorderRadiusGeometry borderRadius(BuildContext context) {
    return BorderRadius.circular(
      context.responsive.value(phone: 14, tablet: 22, largeTablet: 26),
    );
  }

  static EdgeInsetsGeometry padding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: 5,
      vertical: context.responsive.value(phone: 6, tablet: 14, largeTablet: 16),
    );
  }

  static double bodyHeaderDistance(BuildContext context) {
    return context.responsive.value(phone: 15, tablet: 22, largeTablet: 24);
  }
}
