import 'dart:async';

import 'package:checkin/app/app_language.dart';
import 'package:checkin/base/app_responsive.dart';
import 'package:checkin/constants/app_color.dart';
import 'package:checkin/constants/app_fontsize.dart';
import 'package:checkin/viewmodel/qr_code.vm.dart';
import 'package:flutter/material.dart';

class FailedQrCode extends StatefulWidget {
  final QRCodeViewModel qrCodeViewModel;
  final String title;
  final String desc;
  final bool autoClose;
  final Duration autoCloseDuration;

  const FailedQrCode({
    super.key,
    required this.qrCodeViewModel,
    required this.title,
    required this.desc,
    this.autoClose = false,
    this.autoCloseDuration = const Duration(milliseconds: 2500),
  });

  @override
  State<FailedQrCode> createState() => _FailedQrCodeState();
}

class _FailedQrCodeState extends State<FailedQrCode> {
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    if (widget.autoClose) {
      _dismissTimer = Timer(widget.autoCloseDuration, _closeIfMounted);
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  void _closeIfMounted() {
    if (!mounted) {
      return;
    }
    Navigator.maybePop(context);
  }

  Future<void> _onContinuePressed() async {
    _closeIfMounted();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.responsive.isTablet;

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 40.0 : 24.0,
              vertical: isTablet ? 28.0 : 20.0,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 620.0 : double.infinity,
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center vertically
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Center horizontally
                children: [
                  // Decorative icon
                  Icon(
                    Icons.error_outline,
                    size: isTablet ? 92 : 80,
                    color: AppColor.primaryColor.withValues(alpha: 0.8),
                  ),
                  SizedBox(height: isTablet ? 24 : 20),
                  // Title
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isTablet
                          ? (AppFontSize.sizeSuperLarge ?? 32) + 4
                          : (AppFontSize.sizeSuperLarge ?? 32),
                      fontWeight: FontWeight.w900,
                      color: AppColor.primaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: isTablet ? 14 : 12),
                  // Description
                  Text(
                    widget.desc,
                    textAlign: TextAlign.center,
                    softWrap: true, // Allow text to wrap
                    style: TextStyle(
                      fontSize: isTablet
                          ? (AppFontSize.sizeMedium ?? 20) + 2
                          : (AppFontSize.sizeMedium ?? 20),
                      fontWeight: FontWeight.w500,
                      color: AppColor.primaryColor.withValues(alpha: 0.7),
                      height: 1.5, // Improve readability
                    ),
                  ),
                  SizedBox(height: isTablet ? 48 : 40),
                  // Continue Button
                  if (widget.autoClose)
                    Text(
                      AppLanguage.getText('TuDongDongSau'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isTablet
                            ? (AppFontSize.sizeSmall ?? 16)
                            : (AppFontSize.sizeSuperSmall ?? 14),
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColor.primaryColor,
                            AppColor.primaryColor.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _onContinuePressed,
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 40),
                          ),
                          backgroundColor:
                              WidgetStateProperty.all(Colors.transparent),
                          foregroundColor:
                              WidgetStateProperty.all(Colors.white),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          elevation: WidgetStateProperty.all(
                              0), // Elevation handled by boxShadow
                        ),
                        child: Text(
                          AppLanguage.getText('TiepTucCheckIn'),
                          style: TextStyle(
                            fontSize: isTablet
                                ? (AppFontSize.sizeMedium ?? 20) + 1
                                : (AppFontSize.sizeMedium ?? 20),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
