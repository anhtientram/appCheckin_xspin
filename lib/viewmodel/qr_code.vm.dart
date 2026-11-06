import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:checkin/views/qr_code/widgets/failed_qr.widget.dart';
import 'package:flutter/material.dart';
import 'package:checkin/app/app_language.dart';
import 'package:checkin/app/app_sp.dart';
import 'package:checkin/app/app_sp_key.dart';

import 'package:checkin/model/user.model.dart';
import 'package:checkin/requests/history_user.requets.dart';
import 'package:checkin/requests/qrcode.request.dart';
import 'package:checkin/viewmodel/index.vm.dart';
import 'package:checkin/views/qr_code/widgets/success_qr.wiget.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:stacked/stacked.dart';

enum QRCodeFlowMode { manual, automatic }

class QRCodeViewModel extends BaseViewModel {
  late BuildContext viewContext;
  QRCodeRequest qrCodeRequest = QRCodeRequest();
  final AudioPlayer _audioPlayer = AudioPlayer();
  CameraFacing _scannerFacing = CameraFacing.back;
  List<Users>? listUser;
  Users? currentUser;
  String? currentQRCode;
  bool? scanQrCode;
  // late Users detailUser;
  UserRequest userRequest = UserRequest();
  MobileScannerController? scannerController;
  late IndexViewModel indexViewModel;
  bool isFlashOn = false;
  bool isFrontCamera = false;
  bool isScanQr = false;
  String? lastScannedQRCode;
  bool _isScannerPageActive = false;

  @override
  void dispose() {
    unawaited(disposeScanner());
    unawaited(_audioPlayer.dispose());
    super.dispose();
  }

  Future<void> _playSuccessSound() async {
    print('hi pass');
    await _audioPlayer.setVolume(1.0);
    await _audioPlayer.play(AssetSource('pass.mp3'));
  }

  Future<void> _playErrorSound() async {
    print('hi ngheeeeee');
    await _audioPlayer.setVolume(1.0);
    await _audioPlayer.play(AssetSource('fail.mp3'));
  }

  void bindScannerPage(BuildContext context) {
    viewContext = context;
    _isScannerPageActive = true;
    initScanner(facing: _scannerFacing);
  }

  void unbindScannerPage() {
    _isScannerPageActive = false;
  }

  void initScanner({CameraFacing facing = CameraFacing.back}) {
    _scannerFacing = facing;
    isFrontCamera = facing == CameraFacing.front;
    if (scannerController == null) {
      scannerController = MobileScannerController(
        autoStart: false,
        facing: _scannerFacing,
        formats: const [BarcodeFormat.qrCode],
        // DetectionSpeed.noDuplicates bị bỏ vì nó cache QR value ở native layer
        // và không fire onDetect cho cùng mã QR ngay cả sau stop/start.
        // Dùng normal + timeout để scanner luôn sẵn sàng sau mỗi chu kỳ.
        detectionSpeed: DetectionSpeed.normal,
        detectionTimeoutMs: 800,
        cameraResolution: const Size(640, 480),
        returnImage: false,
      );
    }
  }

  CameraFacing resolveCameraFacing(String? cameraSetting) {
    switch (cameraSetting?.trim()) {
      case 'CameraSau':
        return CameraFacing.back;
      case 'CameraTruoc':
      default:
        return CameraFacing.front;
    }
  }

  Future<void> configureScannerFromSetting(String? cameraSetting) async {
    await configureScannerFacing(resolveCameraFacing(cameraSetting));
  }

  Future<void> configureScannerFacing(CameraFacing facing) async {
    if (_scannerFacing == facing && scannerController != null) {
      return;
    }

    final wasScannerPageActive = _isScannerPageActive;
    _scannerFacing = facing;
    isFrontCamera = facing == CameraFacing.front;

    if (scannerController != null) {
      await disposeScanner();
    }
    _isScannerPageActive = wasScannerPageActive;
    initScanner(facing: facing);
    notifyListeners();

    if (wasScannerPageActive) {
      await startScannerSafely();
    }
  }

  Future<void> startScannerSafely({int retryCount = 2}) async {
    for (var attempt = 0; attempt <= retryCount; attempt++) {
      final controller = scannerController;
      if (!_isScannerPageActive || controller == null) {
        return;
      }
      if (controller.value.isRunning) {
        return;
      }

      if (!controller.value.isStarting) {
        try {
          await controller.start();
        } catch (e) {
          debugPrint(
            'Start scanner skipped on attempt ${attempt + 1}: $e',
          );
        }
      }

      await Future<void>.delayed(const Duration(milliseconds: 180));
      if (controller.value.isRunning) {
        return;
      }
    }
  }

  Future<void> stopScannerSafely() async {
    final controller = scannerController;
    if (controller == null) {
      return;
    }
    if (!controller.value.isInitialized || !controller.value.isRunning) {
      return;
    }

    try {
      await controller.stop();
    } catch (e) {
      debugPrint('Stop scanner skipped: $e');
    }
  }

  Future<void> disposeScanner() async {
    final controller = scannerController;
    scannerController = null;
    isScanQr = false;
    isFlashOn = false;
    _isScannerPageActive = false;

    if (controller == null) {
      return;
    }

    try {
      if (controller.value.isInitialized && controller.value.isRunning) {
        await controller.stop();
      }
    } catch (e) {
      debugPrint('Stop scanner before dispose skipped: $e');
    }

    try {
      await controller.dispose();
    } catch (e) {
      debugPrint('Dispose scanner skipped: $e');
    }
  }

  Future<void> toggleTorchSafely() async {
    final controller = scannerController;
    if (controller == null ||
        !controller.value.isInitialized ||
        !controller.value.isRunning) {
      return;
    }

    try {
      await controller.toggleTorch();
    } catch (e) {
      debugPrint('Toggle torch skipped: $e');
    }
  }

  Future<void> refreshCheckinData() async {
    final loaiCheckin = AppSP.get(AppSPKey.loaiCheckin);

    try {
      if (loaiCheckin == 'NL') {
        await Future.wait([
          indexViewModel.usersViewModel.getCountUserCheckIn(),
          indexViewModel.usersViewModel.getUsers(),
        ]);
        return;
      }

      if (loaiCheckin == '1L') {
        await Future.wait([
          indexViewModel.historyViewModel.getCountUserCheckIn(),
          indexViewModel.historyViewModel.reloadUsers(),
        ]);
      }
    } catch (e) {
      debugPrint('Refresh check-in data skipped: $e');
    }
  }

  Future<void> loadQrCode(String maQR) async {
    final result = await qrCodeRequest.checkIn(
      idSuKien: AppSP.get(AppSPKey.idSuKien),
      maQR: maQR,
      idLineCheckin: AppSP.get(AppSPKey.idLineCheckin),
    );
    currentUser = result.user;
  }

  Future<void> runDemoCheckIn(
    String maQR, {
    QRCodeFlowMode flowMode = QRCodeFlowMode.manual,
  }) async {
    final demoQRCode = maQR.trim();
    if (demoQRCode.isEmpty || isBusy || isScanQr) {
      return;
    }

    isScanQr = true;
    currentQRCode = demoQRCode;
    await stopScannerSafely();

    try {
      await getUsers(flowMode: flowMode);
    } finally {
      isScanQr = false;
    }
  }

  Users _mergeUserData({
    required Users originalUser,
    Users? checkedInUser,
  }) {
    if (checkedInUser == null) {
      return originalUser;
    }

    return Users(
      maQR: checkedInUser.maQR.isNotEmpty
          ? checkedInUser.maQR
          : originalUser.maQR,
      isCheckin: checkedInUser.isCheckin,
      idNguoiThamDu: checkedInUser.idNguoiThamDu.isNotEmpty
          ? checkedInUser.idNguoiThamDu
          : originalUser.idNguoiThamDu,
      thoiDiemCheckin:
          checkedInUser.thoiDiemCheckin ?? originalUser.thoiDiemCheckin,
      tenTinhTrang: checkedInUser.tenTinhTrang ?? originalUser.tenTinhTrang,
      maTinhTrang: checkedInUser.maTinhTrang ?? originalUser.maTinhTrang,
      tinhTrang: checkedInUser.tinhTrang ?? originalUser.tinhTrang,
      field2: checkedInUser.field2 ?? originalUser.field2,
      field3: checkedInUser.field3 ?? originalUser.field3,
      field4: checkedInUser.field4 ?? originalUser.field4,
      field5: checkedInUser.field5 ?? originalUser.field5,
      field6: checkedInUser.field6 ?? originalUser.field6,
      field7: checkedInUser.field7 ?? originalUser.field7,
      field8: checkedInUser.field8 ?? originalUser.field8,
      field9: checkedInUser.field9 ?? originalUser.field9,
      field10: checkedInUser.field10 ?? originalUser.field10,
      field11: checkedInUser.field11 ?? originalUser.field11,
      field12: checkedInUser.field12 ?? originalUser.field12,
      field13: checkedInUser.field13 ?? originalUser.field13,
      field14: checkedInUser.field14 ?? originalUser.field14,
      field15: checkedInUser.field15 ?? originalUser.field15,
      soLuotCheckIntoida:
          checkedInUser.soLuotCheckIntoida ?? originalUser.soLuotCheckIntoida,
      ngayCheckin: checkedInUser.ngayCheckin ?? originalUser.ngayCheckin,
      dacheckIn: checkedInUser.dacheckIn ?? originalUser.dacheckIn,
      chuaCheckin: checkedInUser.chuaCheckin ?? originalUser.chuaCheckin,
      lichSuCheckin: checkedInUser.lichSuCheckin != null &&
              checkedInUser.lichSuCheckin!.isNotEmpty
          ? checkedInUser.lichSuCheckin
          : originalUser.lichSuCheckin,
    );
  }

  String _normalizeErrorMessage(Object error) {
    final rawMessage = error.toString().trim();
    if (rawMessage.startsWith('Exception: ')) {
      return rawMessage.substring('Exception: '.length).trim();
    }
    return rawMessage;
  }

  String _buildCheckInFailureMessage(
    int status, {
    String? serverMessage,
  }) {
    final normalizedServerMessage = serverMessage?.trim();
    if (normalizedServerMessage != null && normalizedServerMessage.isNotEmpty) {
      return normalizedServerMessage;
    }

    switch (status) {
      case 0:
        return AppLanguage.getText('QRCodeKhongHopLe');
      case -1:
      case -2:
        return AppLanguage.getText('CheckinThatBaiLienHeAdmin');
      default:
        return AppLanguage.getText('CheckinThatBaiLienHeAdmin');
    }
  }

  Future<void> _showFailedResult(
    String description, {
    required QRCodeFlowMode flowMode,
  }) async {
    setBusy(false);
    notifyListeners();
    await _playErrorSound();
    if (flowMode == QRCodeFlowMode.automatic) {
      await showAutomaticResult(
        isSuccess: false,
        description: description,
      );
      return;
    }

    await _showResultPage(
      FailedQrCode(
        qrCodeViewModel: this,
        title: AppLanguage.getText('ThongBao'),
        desc: description,
      ),
    );
  }

  Future<void> getUsers({
    QRCodeFlowMode flowMode = QRCodeFlowMode.manual,
  }) async {
    final qrCode = currentQRCode;
    if (qrCode == null || qrCode.isEmpty) {
      return;
    }

    setBusy(true);
    currentUser = null;
    print('Vô get');
    try {
      final userDetail = await qrCodeRequest.getUser(
        idSuKien: AppSP.get(AppSPKey.idSuKien),
        maQR: qrCode,
      );

      if (userDetail != null) {
        currentUser = userDetail;
        final checkedInCount = userDetail.dacheckIn ?? 0;
        final maxCheckinCount = userDetail.soLuotCheckIntoida ?? 1;

        if (checkedInCount < maxCheckinCount) {
          final checkInResult = flowMode == QRCodeFlowMode.automatic
              ? await qrCodeRequest.autoCheckIn(
                  idSuKien: AppSP.get(AppSPKey.idSuKien),
                  maQR: qrCode,
                  idLineCheckin: AppSP.get(AppSPKey.idLineCheckin),
                )
              : await qrCodeRequest.checkIn(
                  idSuKien: AppSP.get(AppSPKey.idSuKien),
                  maQR: qrCode,
                  idLineCheckin: AppSP.get(AppSPKey.idLineCheckin),
                );

          if (checkInResult.status == 1) {
            currentUser = _mergeUserData(
              originalUser: userDetail,
              checkedInUser: checkInResult.user,
            );
            setBusy(false);
            notifyListeners();
            unawaited(refreshCheckinData());
            await _playSuccessSound();
            if (flowMode == QRCodeFlowMode.automatic) {
              await showAutomaticResult(isSuccess: true);
            } else {
              await showSuccessScanQrCode();
            }
          } else {
            currentUser = userDetail;
            await _showFailedResult(
              _buildCheckInFailureMessage(
                checkInResult.status,
                serverMessage: checkInResult.message,
              ),
              flowMode: flowMode,
            );
          }
        } else {
          final desc = AppSP.get(AppSPKey.loaiCheckin) == 'NL'
              ? '${AppLanguage.getText('MaQR')} $qrCode ${AppLanguage.getText('DaHetLuotCheckin')}'
              : '${AppLanguage.getText('MaQR')} $qrCode ${AppLanguage.getText('DaDuocCheckinRoi')}';
          await _showFailedResult(desc, flowMode: flowMode);
        }
      } else {
        await _showFailedResult(
          AppLanguage.getText('QRCodeKhongHopLe'),
          flowMode: flowMode,
        );
      }
    } catch (e) {
      String errorMessage = _normalizeErrorMessage(e);
      if (errorMessage.isEmpty) {
        errorMessage = AppLanguage.getText('QRCodeKhongHopLe');
      }
      if (errorMessage.contains('Lỗi kết nối internet')) {
        errorMessage = AppLanguage.getText('LoiKetNoiInternet');
      }

      await _showFailedResult(
        errorMessage,
        flowMode: flowMode,
      );
    }
  }

  Future<void> _showResultPage(
    Widget page, {
    bool restartScannerAfterClose = false,
  }) async {
    await stopScannerSafely();
    if (!_isScannerPageActive || !viewContext.mounted) {
      return;
    }

    await Navigator.push(
      viewContext,
      MaterialPageRoute(builder: (context) => page),
    );

    if (!restartScannerAfterClose || !viewContext.mounted) {
      return;
    }

    // Reset scan lock BEFORE restarting — isScanQr=true còn kẹt vì
    // finally block trong _handleDetection chạy sau khi showAutomaticResult
    // hoàn tất (tức là sau đây). Nếu không reset sớm, scanner chạy nhưng
    // mọi detection đều bị block ngay.
    isScanQr = false;

    bindScannerPage(viewContext);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await startScannerSafely();
  }

  Future<void> showSuccessScanQrCode() async {
    print('Nhảy');
    await _showResultPage(SuccessScreenQR(qrCodeViewModel: this));
  }

  Future<void> showAutomaticResult({
    required bool isSuccess,
    String? description,
  }) async {
    await _showResultPage(
      isSuccess
          ? SuccessScreenQR(
              qrCodeViewModel: this,
              autoClose: true,
            )
          : FailedQrCode(
              qrCodeViewModel: this,
              title: AppLanguage.getText('ThongBao'),
              desc: description ??
                  AppLanguage.getText('VuiLongThuLaiVoiMaQRKhac'),
              autoClose: true,
            ),
      restartScannerAfterClose: true,
    );
  }

  void showQRCodeAlreadyScannedDialog(BuildContext context, String desc) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.topSlide,
      title: AppLanguage.getText('MaDaQuet'),
      desc: desc,
      btnOkOnPress: () {
        unawaited(startScannerSafely());
        // Navigator.maybePop(context);
      },
      dismissOnTouchOutside: false,
    )..show();
  }

  void showQRCodeFailed(BuildContext context, String desc) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.topSlide,
      title: AppLanguage.getText('QRCodeKhongTonTai'),
      desc: desc,
      btnOkOnPress: () {
        unawaited(startScannerSafely());
      },
      dismissOnTouchOutside: false,
    )..show();
  }
}
