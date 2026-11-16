import 'dart:async';

import 'package:checkin/app/app_route_observer.dart';
import 'package:checkin/base/app_responsive.dart';
import 'package:checkin/constants/app_color.dart';
import 'package:checkin/viewmodel/index.vm.dart';
import 'package:checkin/viewmodel/qr_code.vm.dart';
import 'package:checkin/views/qr_code/checkin_background_layer.dart';
import 'package:checkin/views/qr_code/scan_guide_frame.dart';
import 'package:checkin/views/qr_code/scan_window_barcode_filter.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:stacked/stacked.dart';

class QrCodePage extends StatefulWidget {
  QrCodePage({
    super.key,
    required this.qrViewModel,
    required this.indexViewModel,
  });
  final QRCodeViewModel qrViewModel;
  final IndexViewModel indexViewModel;

  @override
  State<QrCodePage> createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage>
    with WidgetsBindingObserver, RouteAware {
  ModalRoute<dynamic>? _route;

  @override
  void initState() {
    super.initState();
    final loginViewModel = widget.indexViewModel.loginViewModel;
    widget.qrViewModel.initScanner(
      facing: widget.qrViewModel.resolveCameraFacing(
        loginViewModel.userLogin?.cameraCheckinThuCong,
      ),
    );
    WidgetsBinding.instance.addObserver(this);
    if (loginViewModel.userLogin == null) {
      unawaited(
        loginViewModel.loadUser().then((_) => _syncPreferredCamera()),
      );
    }
  }

  Future<void> _syncPreferredCamera() async {
    if (!mounted) {
      return;
    }

    await widget.qrViewModel.configureScannerFromSetting(
      widget.indexViewModel.loginViewModel.userLogin?.cameraCheckinThuCong,
    );
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
    widget.qrViewModel.unbindScannerPage();
    unawaited(widget.qrViewModel.disposeScanner());
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
      widget.qrViewModel.unbindScannerPage();
      unawaited(widget.qrViewModel.stopScannerSafely());
    }
  }

  @override
  void didPushNext() {
    widget.qrViewModel.unbindScannerPage();
    unawaited(widget.qrViewModel.stopScannerSafely());
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
    if (!isCurrentRoute || widget.indexViewModel.currentIndex != 1) {
      return;
    }

    widget.qrViewModel.bindScannerPage(context);
    await widget.qrViewModel.startScannerSafely();
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

  Future<void> _closeScanner() async {
    widget.qrViewModel.unbindScannerPage();
    await widget.qrViewModel.stopScannerSafely();
    if (mounted) {
      await widget.indexViewModel.setIndex(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      disposeViewModel: false,
      viewModelBuilder: () => widget.qrViewModel,
      onViewModelReady: (viewModel) async {
        viewModel.indexViewModel = widget.indexViewModel;
        viewModel.bindScannerPage(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          unawaited(_resumeScannerIfVisible());
          _scheduleScannerWarmup();
        });
      },
      builder: (context, viewModel, child) {
        final isTablet = context.responsive.isTablet;
        final scanAreaSize = isTablet ? 360.0 : 280.0;

        viewModel.bindScannerPage(context);
        return Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final scanArea = scanAreaSize
                              .clamp(
                                220.0,
                                constraints.biggest.shortestSide,
                              )
                              .toDouble();
                          final scanWindow = Rect.fromCenter(
                            center: Offset(
                              constraints.maxWidth / 2,
                              constraints.maxHeight / 2,
                            ),
                            width: scanArea,
                            height: scanArea,
                          );

                          return Stack(
                            children: [
                              MobileScanner(
                                controller: viewModel.scannerController!,
                                fit: BoxFit.cover,
                                scanWindow: scanWindow,
                                scanWindowUpdateThreshold: 8,
                                onDetect: (qrcode) async {
                                  if (!viewModel.isScanQr) {
                                    viewModel.isScanQr = true;
                                    try {
                                      final List<Barcode> barcodes = qrcode
                                          .barcodes
                                          .where(
                                            (barcode) =>
                                                isBarcodeInsideScanWindow(
                                              barcode: barcode,
                                              cameraPreviewSize: qrcode.size,
                                              widgetSize: constraints.biggest,
                                              scanWindow: scanWindow,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                          .toList();
                                      for (final barcode in barcodes) {
                                        final String? rawValue =
                                            barcode.rawValue?.trim();
                                        if (rawValue != null &&
                                            rawValue.isNotEmpty) {
                                          viewModel.currentQRCode = rawValue;
                                          print('QR Code found: $rawValue');
                                          await viewModel.getUsers();
                                          break;
                                        }
                                      }
                                    } finally {
                                      viewModel.isScanQr = false;
                                    }
                                  }
                                },
                              ),
                              CheckinBackgroundLayer(
                                imageQr: widget.indexViewModel.loginViewModel
                                    .userLogin?.imageQr,
                                cutoutRect: scanWindow,
                              ),
                              Positioned.fromRect(
                                rect: scanWindow,
                                child: ScanGuideFrame(
                                  size: scanArea,
                                  accentColor: viewModel.isBusy
                                      ? AppColor.oriColor
                                      : AppColor.primaryColor,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
                // Positioned(
                //   top: 50,
                //   left: 0,
                //   right: 0,
                //   child: Center(
                //     child: Container(
                //       padding:
                //           EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                //       decoration: BoxDecoration(
                //         color: Colors.redAccent.withValues(alpha: 0.5),
                //       ),
                //       child: Text(
                //         AppLanguage.getText('HayDuaMaQRVaoGiuaKhung'),
                //         style: TextStyle(
                //           color: Colors.white,
                //           fontSize: AppFontSize.sizeSmall,
                //         ),
                //         textAlign: TextAlign.center,
                //       ),
                //     ),
                //   ),
                // ),
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
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            viewModel.isFlashOn = !viewModel.isFlashOn;
                          });
                          viewModel.toggleTorchSafely();
                        },
                        icon: viewModel.isFlashOn
                            ? Icon(Icons.flash_on_sharp)
                            : Icon(Icons.flash_off_sharp),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

//   Widget _buildDemoQRCodeInput(
//     BuildContext context,
//     QRCodeViewModel viewModel,
//     bool isTablet,
//   ) {
//     final buttonLabel = viewModel.isBusy ? 'Đang gửi' : 'Demo';

//     return Center(
//       child: ConstrainedBox(
//         constraints: BoxConstraints(maxWidth: isTablet ? 560 : double.infinity),
//         child: Material(
//           color: Colors.black.withValues(alpha: 0.58),
//           borderRadius: BorderRadius.circular(14),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//             child: Row(
//               children: [
//                 // Expanded(
//                 //   child: TextField(
//                 //     controller: _demoQRCodeController,
//                 //     enabled: !viewModel.isBusy,
//                 //     keyboardType: TextInputType.number,
//                 //     textInputAction: TextInputAction.done,
//                 //     onSubmitted: (_) => _submitDemoQRCode(viewModel),
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
//                   onPressed: viewModel.isBusy
//                       ? null
//                       : () => _submitDemoQRCode(viewModel),
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
//                     buttonLabel,
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
}
