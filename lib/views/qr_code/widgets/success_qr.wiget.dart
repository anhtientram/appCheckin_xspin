import 'dart:async';

import 'package:checkin/app/app_language.dart';
import 'package:checkin/app/app_sp.dart';
import 'package:checkin/app/app_sp_key.dart';
import 'package:checkin/constants/app_color.dart';
import 'package:checkin/viewmodel/qr_code.vm.dart';
import 'package:checkin/views/history/widgets/manual_checkin_success.widget.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class SuccessScreenQR extends StatefulWidget {
  final QRCodeViewModel qrCodeViewModel;
  final bool autoClose;
  final Duration autoCloseDuration;

  const SuccessScreenQR({
    super.key,
    required this.qrCodeViewModel,
    this.autoClose = false,
    this.autoCloseDuration = const Duration(milliseconds: 2500),
  });

  @override
  State<SuccessScreenQR> createState() => _SuccessScreenQRState();
}

class _SuccessScreenQRState extends State<SuccessScreenQR> {
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
    if (mounted) {
      Navigator.maybePop(context);
    }
  }

  Future<void> _refreshAndContinue() async {
    await _refreshUsers();
  }

  Future<void> _refreshAndReturnToList() async {
    await _refreshUsers(returnToList: true);
  }

  Future<void> _refreshUsers({bool returnToList = false}) async {
    try {
      final indexViewModel = widget.qrCodeViewModel.indexViewModel;
      final loaiCheckin = AppSP.get(AppSPKey.loaiCheckin)?.toString();

      if (loaiCheckin == 'NL') {
        await indexViewModel.usersViewModel.getUsers();
        await indexViewModel.usersViewModel.getCountUserCheckIn();
      } else if (loaiCheckin == '1L') {
        await indexViewModel.historyViewModel.getUsers();
        await indexViewModel.historyViewModel.getCountUserCheckIn();
      } else {
        throw Exception(AppLanguage.getText('KhongTheTaiDuLieuNguoiDung'));
      }

      if (returnToList) {
        await indexViewModel.setIndex(0);
      }
    } catch (error) {
      if (mounted) {
        _showSnackBar('${AppLanguage.getText('CoLoiXayRa')}: $error');
      }
      rethrow;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<QRCodeViewModel>.reactive(
      disposeViewModel: false,
      viewModelBuilder: () => widget.qrCodeViewModel,
      onViewModelReady: (viewModel) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) {
            return;
          }
          await viewModel.indexViewModel.loginViewModel.loadUser();
        });
      },
      builder: (context, viewModel, child) {
        final currentUser = viewModel.currentUser;
        if (viewModel.isBusy || currentUser == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: viewModel.isBusy
                  ? const CircularProgressIndicator(
                      color: AppColor.successQRCode,
                    )
                  : Text(AppLanguage.getText('ChuaCoDuLieuCheckin')),
            ),
          );
        }

        return ManualCheckinSuccessPage(
          user: currentUser,
          showAutoCloseMessage: widget.autoClose,
          autoCloseDuration: widget.autoCloseDuration,
          onContinueCheckin: _refreshAndContinue,
          onBackToList: _refreshAndReturnToList,
        );
      },
    );
  }
}
