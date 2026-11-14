import 'package:flutter/material.dart';

abstract final class AppBreakpoints {
  static const double compactPhone = 360;
  static const double tablet = 600;
  static const double largeTablet = 820;
  static const double extraLargeTablet = 1000;
}

enum AppDeviceClass {
  compactPhone,
  phone,
  tablet,
  largeTablet,
  extraLargeTablet,
}

@immutable
class AppResponsive {
  const AppResponsive._(this.size);

  factory AppResponsive.of(BuildContext context) {
    return AppResponsive._(MediaQuery.sizeOf(context));
  }

  factory AppResponsive.fromSize(Size size) {
    return AppResponsive._(size);
  }

  final Size size;

  double get width => size.width;
  double get height => size.height;
  double get shortestSide => size.shortestSide;

  AppDeviceClass get deviceClass {
    if (shortestSide >= AppBreakpoints.extraLargeTablet) {
      return AppDeviceClass.extraLargeTablet;
    }
    if (shortestSide >= AppBreakpoints.largeTablet) {
      return AppDeviceClass.largeTablet;
    }
    if (shortestSide >= AppBreakpoints.tablet) {
      return AppDeviceClass.tablet;
    }
    if (shortestSide < AppBreakpoints.compactPhone) {
      return AppDeviceClass.compactPhone;
    }
    return AppDeviceClass.phone;
  }

  bool get isCompactPhone => deviceClass == AppDeviceClass.compactPhone;
  bool get isPhone => shortestSide < AppBreakpoints.tablet;
  bool get isTablet => shortestSide >= AppBreakpoints.tablet;
  bool get isLargeTablet => shortestSide >= AppBreakpoints.largeTablet;
  bool get isExtraLargeTablet =>
      shortestSide >= AppBreakpoints.extraLargeTablet;

  T value<T>({
    required T phone,
    T? compactPhone,
    T? tablet,
    T? largeTablet,
    T? extraLargeTablet,
  }) {
    switch (deviceClass) {
      case AppDeviceClass.extraLargeTablet:
        return extraLargeTablet ?? largeTablet ?? tablet ?? phone;
      case AppDeviceClass.largeTablet:
        return largeTablet ?? tablet ?? phone;
      case AppDeviceClass.tablet:
        return tablet ?? phone;
      case AppDeviceClass.compactPhone:
        return compactPhone ?? phone;
      case AppDeviceClass.phone:
        return phone;
    }
  }

  EdgeInsets pagePadding({
    double compactPhone = 14,
    double phone = 20,
    double tablet = 32,
    double largeTablet = 40,
  }) {
    final horizontal = value(
      phone: phone,
      compactPhone: compactPhone,
      tablet: tablet,
      largeTablet: largeTablet,
    );
    return EdgeInsets.symmetric(horizontal: horizontal);
  }

  double contentMaxWidth({
    double phone = double.infinity,
    double tablet = 620,
    double largeTablet = 720,
  }) {
    return value(
      phone: phone,
      tablet: tablet,
      largeTablet: largeTablet,
    );
  }

  double get deviceTextScale {
    return value(
      phone: 1,
      tablet: 1.25,
      largeTablet: 1.32,
      extraLargeTablet: 1.4,
    );
  }
}

extension AppResponsiveContext on BuildContext {
  AppResponsive get responsive => AppResponsive.of(this);
}
