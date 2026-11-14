import 'dart:async';
import 'dart:math' as math;

import 'package:checkin/app/app_route_observer.dart';
import 'package:checkin/base/app_responsive.dart';
import 'package:checkin/constants/app_color.dart';
import 'package:checkin/viewmodel/index.vm.dart';
import 'package:checkin/viewmodel/login.vm.dart';
import 'package:checkin/viewmodel/qr_code.vm.dart';
import 'package:checkin/views/qr_code/checkin_background_layer.dart';
import 'package:checkin/views/qr_code/scan_window_barcode_filter.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:stacked/stacked.dart';

class AutoCheckinPage extends StatefulWidget {
  const AutoCheckinPage({
    super.key,
    required this.indexViewModel,
  });

  final IndexViewModel indexViewModel;

  @override
  State<AutoCheckinPage> createState() => _AutoCheckinPageState();
}

class _AutoCheckinPageState extends State<AutoCheckinPage>
    with WidgetsBindingObserver, RouteAware {
  final QRCodeViewModel _qrViewModel = QRCodeViewModel();
  ModalRoute<dynamic>? _route;

  @override
  void initState() {
    super.initState();
    _qrViewModel.indexViewModel = widget.indexViewModel;
    final loginViewModel = widget.indexViewModel.loginViewModel;
    _qrViewModel.initScanner(
      facing: _resolveCameraFacing(loginViewModel.userLogin?.cameraCheckin),
    );
    WidgetsBinding.instance.addObserver(this);
    if (loginViewModel.userLogin == null) {
      unawaited(
        loginViewModel.loadUser().then((_) => _syncPreferredCamera()),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (_route != route && route is PageRoute) {
      if (_route is PageRoute) {
        appRouteObserver.unsubscribe(this);
      }
      _route = route;
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_route is PageRoute) {
      appRouteObserver.unsubscribe(this);
    }
    _qrViewModel.unbindScannerPage();
    unawaited(_qrViewModel.disposeScanner());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_resumeScannerIfVisible());
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      _qrViewModel.unbindScannerPage();
      unawaited(_qrViewModel.stopScannerSafely());
    }
  }

  @override
  void didPushNext() {
    _qrViewModel.unbindScannerPage();
    unawaited(_qrViewModel.stopScannerSafely());
  }

  @override
  void didPopNext() {
    unawaited(_resumeScannerIfVisible());
  }

  Future<void> _resumeScannerIfVisible() async {
    if (!mounted) {
      return;
    }

    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;
    if (!isCurrentRoute) {
      return;
    }

    _qrViewModel.bindScannerPage(context);
    await _qrViewModel.startScannerSafely();
  }

  void _scheduleScannerWarmup() {
    for (final delay in const [
      Duration(milliseconds: 250),
      Duration(milliseconds: 700),
    ]) {
      Future<void>.delayed(delay, () {
        if (!mounted) {
          return;
        }
        unawaited(_resumeScannerIfVisible());
      });
    }
  }

  CameraFacing _resolveCameraFacing(String? cameraSetting) {
    switch (cameraSetting?.trim()) {
      case 'CameraSau':
        return CameraFacing.back;
      case 'CameraTruoc':
      default:
        return CameraFacing.front;
      // default:
      //   return CameraFacing.front;
    }
  }

  Future<void> _syncPreferredCamera() async {
    if (!mounted) {
      return;
    }

    await _qrViewModel.configureScannerFacing(
      _resolveCameraFacing(
        widget.indexViewModel.loginViewModel.userLogin?.cameraCheckin,
      ),
    );
  }

  Future<void> _closeScanner() async {
    _qrViewModel.unbindScannerPage();
    await _qrViewModel.stopScannerSafely();
    if (mounted) {
      Navigator.maybePop(context);
    }
  }

  Future<void> _handleDetection(
    BarcodeCapture capture, {
    required Rect scanWindow,
    required Size previewSize,
  }) async {
    if (_qrViewModel.isScanQr) {
      return;
    }

    final barcodes = capture.barcodes.where((barcode) {
      return isBarcodeInsideScanWindow(
        barcode: barcode,
        cameraPreviewSize: capture.size,
        widgetSize: previewSize,
        scanWindow: scanWindow,
        fit: BoxFit.cover,
        mirrorHorizontally: _qrViewModel.isFrontCamera,
      );
    });

    for (final barcode in barcodes) {
      final rawValue = barcode.rawValue?.trim();
      if (rawValue == null || rawValue.isEmpty) {
        continue;
      }

      _qrViewModel.isScanQr = true;
      _qrViewModel.currentQRCode = rawValue;
      try {
        await _qrViewModel.getUsers(flowMode: QRCodeFlowMode.automatic);
      } finally {
        _qrViewModel.isScanQr = false;
      }
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<QRCodeViewModel>.reactive(
      viewModelBuilder: () => _qrViewModel,
      onViewModelReady: (viewModel) {
        viewModel.bindScannerPage(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          unawaited(_resumeScannerIfVisible());
          _scheduleScannerWarmup();
        });
      },
      builder: (context, viewModel, child) {
        viewModel.bindScannerPage(context);
        final isTablet = context.responsive.isTablet;

        return Scaffold(
          backgroundColor: Colors.black,
          body: ViewModelBuilder<LoginViewModel>.reactive(
            disposeViewModel: false,
            viewModelBuilder: () => widget.indexViewModel.loginViewModel,
            builder: (context, loginViewModel, child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final maxScanSize = isTablet ? 420.0 : 320.0;
                  final scanSize = math.min(
                    constraints.maxWidth * 0.76,
                    maxScanSize,
                  );
                  final scanWindow = Rect.fromCenter(
                    center: Offset(
                      constraints.maxWidth / 2,
                      constraints.maxHeight / 2,
                    ),
                    width: scanSize,
                    height: scanSize,
                  );

                  final scanner = MobileScanner(
                    controller: viewModel.scannerController!,
                    fit: BoxFit.cover,
                    scanWindow: scanWindow,
                    scanWindowUpdateThreshold: 8,
                    onDetect: (capture) => _handleDetection(
                      capture,
                      scanWindow: scanWindow,
                      previewSize: constraints.biggest,
                    ),
                  );

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      scanner,
                      CheckinBackgroundLayer(
                        imageQr: loginViewModel.userLogin?.imageQr,
                        cutoutRect: scanWindow,
                      ),
                      Positioned.fromRect(
                        rect: scanWindow,
                        child: _ScanGuideFrame(
                          size: scanSize,
                          accentColor: viewModel.isBusy
                              ? AppColor.oriColor
                              : AppColor.primaryColor,
                        ),
                      ),
                      SafeArea(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16, right: 16),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: _closeScanner,
                                child: Ink(
                                  width: 42,
                                  height: 42,
                                  child: Padding(
                                    padding: const EdgeInsets.all(9),
                                    child: Image.asset(
                                      'assets/logo_close.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Positioned(
                      //   left: 16,
                      //   right: 16,
                      //   bottom: bottomInset + 18,
                      //   child: _AutoDemoQRCodeInput(
                      //     controller: _demoQRCodeController,
                      //     isBusy: viewModel.isBusy,
                      //     isTablet: isTablet,
                      //     onSubmitted: () => _submitDemoQRCode(viewModel),
                      //   ),
                      // ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

// class _AutoDemoQRCodeInput extends StatelessWidget {
//   const _AutoDemoQRCodeInput({
//     required this.controller,
//     required this.isBusy,
//     required this.isTablet,
//     required this.onSubmitted,
//   });

//   final TextEditingController controller;
//   final bool isBusy;
//   final bool isTablet;
//   final VoidCallback onSubmitted;

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: ConstrainedBox(
//         constraints: BoxConstraints(maxWidth: isTablet ? 620 : double.infinity),
//         child: Material(
//           color: Colors.black.withValues(alpha: 0.64),
//           borderRadius: BorderRadius.circular(16),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//             child: Row(
//               children: [
//                 // Expanded(
//                 //   child: TextField(
//                 //     controller: controller,
//                 //     enabled: !isBusy,
//                 //     keyboardType: TextInputType.number,
//                 //     textInputAction: TextInputAction.done,
//                 //     onSubmitted: (_) => onSubmitted(),
//                 //     style: const TextStyle(color: Colors.white),
//                 //     decoration: InputDecoration(
//                 //       isDense: true,
//                 //       hintText: 'Nhập mã QR demo',
//                 //       hintStyle: TextStyle(
//                 //         color: Colors.white.withValues(alpha: 0.76),
//                 //       ),
//                 //       prefixIcon: const Icon(
//                 //         Icons.qr_code_2_rounded,
//                 //         color: Colors.white,
//                 //       ),
//                 //       filled: true,
//                 //       fillColor: Colors.white.withValues(alpha: 0.12),
//                 //       border: OutlineInputBorder(
//                 //         borderRadius: BorderRadius.circular(12),
//                 //         borderSide: BorderSide.none,
//                 //       ),
//                 //       contentPadding: const EdgeInsets.symmetric(
//                 //         horizontal: 12,
//                 //         vertical: 12,
//                 //       ),
//                 //     ),
//                 //   ),
//                 // ),
//                 const SizedBox(width: 10),
//                 ElevatedButton(
//                   onPressed: isBusy ? null : onSubmitted,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColor.successQRCode,
//                     foregroundColor: Colors.white,
//                     disabledBackgroundColor: Colors.grey.shade500,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 18,
//                       vertical: 13,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: Text(
//                     isBusy ? 'Đang gửi' : 'Demo',
//                     style: TextStyle(
//                       fontSize: AppFontSize.sizeSmall,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class _ScanGuideFrame extends StatelessWidget {
  const _ScanGuideFrame({
    required this.size,
    required this.accentColor,
  });

  final double size;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Stack(
          children: [
            _FrameCorner(
              alignment: Alignment.topLeft,
              accentColor: accentColor,
            ),
            _FrameCorner(
              alignment: Alignment.topRight,
              accentColor: accentColor,
            ),
            _FrameCorner(
              alignment: Alignment.bottomLeft,
              accentColor: accentColor,
            ),
            _FrameCorner(
              alignment: Alignment.bottomRight,
              accentColor: accentColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _FrameCorner extends StatelessWidget {
  const _FrameCorner({
    required this.alignment,
    required this.accentColor,
  });

  final Alignment alignment;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment.x < 0;
    final isTop = alignment.y < 0;

    return Align(
      alignment: alignment,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? BorderSide(color: accentColor, width: 5)
                : BorderSide.none,
            bottom: !isTop
                ? BorderSide(color: accentColor, width: 5)
                : BorderSide.none,
            left: isLeft
                ? BorderSide(color: accentColor, width: 5)
                : BorderSide.none,
            right: !isLeft
                ? BorderSide(color: accentColor, width: 5)
                : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isLeft && isTop ? 28 : 0),
            topRight: Radius.circular(!isLeft && isTop ? 28 : 0),
            bottomLeft: Radius.circular(isLeft && !isTop ? 28 : 0),
            bottomRight: Radius.circular(!isLeft && !isTop ? 28 : 0),
          ),
        ),
      ),
    );
  }
}
