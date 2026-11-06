import 'package:checkin/app/app_language.dart';
import 'package:checkin/app/app_sp.dart';
import 'package:checkin/app/app_sp_key.dart';
import 'package:checkin/viewmodel/history_user_checkin.vm.dart';
import 'package:checkin/viewmodel/history_users.vm.dart';
import 'package:checkin/viewmodel/login.vm.dart';
import 'package:checkin/viewmodel/qr_code.vm.dart';
import 'package:checkin/views/history/history.page.dart';
import 'package:checkin/views/history1/history1.page.dart';
import 'package:checkin/views/menu/menu.page.dart';
import 'package:checkin/views/qr_code/qr_code.page.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class IndexViewModel extends BaseViewModel {
  late BuildContext viewContext;
  int currentIndex = 0;
  late QRCodeViewModel qrCodeViewModel;
  late UsersViewModel usersViewModel;
  late HistoryCheckinViewModel historyViewModel;
  late LoginViewModel loginViewModel;
  bool _isQRCodePageInitialized = false;
  bool status = true;
  bool get isQRCodePageInitialized => _isQRCodePageInitialized;
  IndexViewModel() {
    qrCodeViewModel = QRCodeViewModel();
    usersViewModel = UsersViewModel();
    loginViewModel = LoginViewModel();
    historyViewModel = HistoryCheckinViewModel();
  }
  Future<void> refreshAppLanguage() async {
    await AppLanguage.refreshLanguages();
    notifyListeners();
  }

  /// Refresh config từ DangNhap rồi cập nhật UI (đổi NL/1L, nút check-in thủ công, ...).
  Future<void> refreshSession({bool reloadList = true}) async {
    await loginViewModel.loadUser();
    await refreshAppLanguage();
    notifyListeners();

    if (!reloadList) {
      return;
    }

    final loaiCheckin = AppSP.get(AppSPKey.loaiCheckin)?.toString() ?? '';
    if (loaiCheckin == 'NL') {
      await usersViewModel.reloadUsers();
    } else if (loaiCheckin == '1L') {
      await historyViewModel.reloadUsers();
    }
  }

  Future<void> _reloadCurrentPage() async {
    await refreshSession(reloadList: currentIndex == 0);
    if (currentIndex == 1) {
      await _syncManualCheckinCamera();
      await qrCodeViewModel.startScannerSafely();
    }
    if (currentIndex == 0) {
      _isQRCodePageInitialized = false;
    }
    if (currentIndex == 2) {
      final loaiCheckin = AppSP.get(AppSPKey.loaiCheckin)?.toString() ?? '';
      if (loaiCheckin == '1L') {
        await historyViewModel.getCountUserCheckIn();
        await historyViewModel.getCountUser();
      } else {
        await usersViewModel.getCountUserCheckIn();
        await usersViewModel.getCountUser();
      }
    }
  }

  Future<void> setIndex(int index) async {
    if (index == currentIndex) {
      await _reloadCurrentPage();
    } else {
      if (currentIndex == 1 && index != 1) {
        await qrCodeViewModel.stopScannerSafely();
      }
      if (index == 1 && !_isQRCodePageInitialized) {
        _isQRCodePageInitialized = true;
      } else if (index == 2) {
        await loginViewModel.loadUser();
        final loaiCheckin = AppSP.get(AppSPKey.loaiCheckin)?.toString() ?? '';
        if (loaiCheckin == '1L') {
          historyViewModel.getCountUserCheckIn();
          historyViewModel.getCountUser();
        } else {
          usersViewModel.getCountUserCheckIn();
          usersViewModel.getCountUser();
        }
        _isQRCodePageInitialized = false;
      } else if (index == 0) {
        _isQRCodePageInitialized = false;
      }

      if (index == 1) {
        await loginViewModel.loadUser();
        await _syncManualCheckinCamera();
      }

      currentIndex = index;
      notifyListeners();

      if (index == 1) {
        await qrCodeViewModel.startScannerSafely();
      }
    }
  }

  Future<void> _syncManualCheckinCamera() async {
    await qrCodeViewModel.configureScannerFromSetting(
      loginViewModel.userLogin?.cameraCheckinThuCong,
    );
  }

  List<Widget> getPages() {
    return [
      AppSP.get(AppSPKey.loaiCheckin) == 'NL'
          ? HistoryPage(
              usersViewModel: usersViewModel,
              indexViewModel: this,
            )
          : HistoryPage1(
              usersViewModel: historyViewModel, indexViewModel: this),
      _isQRCodePageInitialized
          ? QrCodePage(
              qrViewModel: qrCodeViewModel,
              indexViewModel: this,
            )
          : Container(),
      MenuPage(
        loginViewModel: loginViewModel,
        indexViewModel: this,
      ),
      // MorePage()
    ];
  }
}
