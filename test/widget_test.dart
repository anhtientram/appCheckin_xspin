import 'package:checkin/base/app_responsive.dart';
import 'package:checkin/views/auth/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'Xspin Checkin',
      packageName: 'com.xspin.checkin',
      version: '1.0.17',
      buildNumber: '28',
      buildSignature: '',
    );
  });

  test('responsive helper classifies supported device sizes', () {
    expect(
      AppResponsive.fromSize(const Size(320, 568)).deviceClass,
      AppDeviceClass.compactPhone,
    );
    expect(
      AppResponsive.fromSize(const Size(390, 844)).deviceClass,
      AppDeviceClass.phone,
    );
    expect(
      AppResponsive.fromSize(const Size(768, 1024)).deviceClass,
      AppDeviceClass.tablet,
    );
    expect(
      AppResponsive.fromSize(const Size(1024, 1366)).deviceClass,
      AppDeviceClass.extraLargeTablet,
    );
  });

  for (final testCase in <({String name, Size size})>[
    (name: 'compact phone', size: const Size(320, 568)),
    (name: 'phone', size: const Size(390, 844)),
    (name: 'tablet', size: const Size(768, 1024)),
    (name: 'iPad', size: const Size(1024, 1366)),
  ]) {
    testWidgets('login renders without overflow on ${testCase.name}',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = testCase.size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SignInView(),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('System Login'), findsOneWidget);
      expect(find.text('Event Code'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Version 1.0.17'), findsOneWidget);
    });
  }
}
