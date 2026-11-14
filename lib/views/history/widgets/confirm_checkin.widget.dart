import 'package:checkin/app/app_language.dart';
import 'package:checkin/base/app_responsive.dart';
import 'package:checkin/constants/app_color.dart';
import 'package:checkin/constants/app_fontsize.dart';
import 'package:checkin/model/user.model.dart';
import 'package:checkin/viewmodel/login.vm.dart';
import 'package:checkin/views/history/widgets/manual_checkin_success.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:stacked/stacked.dart';

class ConfirmCheckinPage extends StatefulWidget {
  final Users user;
  final Future<bool> Function(Users user) onConfirm;
  final Future<void> Function()? onBackToList;

  const ConfirmCheckinPage({
    super.key,
    required this.user,
    required this.onConfirm,
    this.onBackToList,
  });

  @override
  State<ConfirmCheckinPage> createState() => _ConfirmCheckinPageState();
}

class _ConfirmCheckinPageState extends State<ConfirmCheckinPage> {
  bool _isSubmitting = false;

  Future<void> _handleConfirm() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final success = await widget.onConfirm(widget.user);
      if (!mounted) return;
      if (success) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ManualCheckinSuccessPage(
              user: widget.user,
              checkedInAt: DateTime.now(),
              onContinueCheckin: widget.onBackToList,
              onBackToList: widget.onBackToList,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LoginViewModel>.reactive(
      viewModelBuilder: () => LoginViewModel(),
      onViewModelReady: (loginViewModel) async {
        await loginViewModel.loadUser();
      },
      builder: (context, loginViewModel, child) {
        final responsive = context.responsive;
        final isTablet = responsive.isTablet;
        final maxContentWidth = responsive.contentMaxWidth(
          phone: double.infinity,
          tablet: 900,
          largeTablet: 1100,
        );
        final pagePadding = responsive.value(
          phone: 20.0,
          tablet: 36.0,
          largeTablet: 48.0,
        );
        final titleFontSize = responsive.value(
          phone: AppFontSize.sizeLarge ?? 24,
          tablet: (AppFontSize.sizeLarge ?? 24) + 6,
          largeTablet: (AppFontSize.sizeLarge ?? 24) + 10,
        );
        final qrFontSize = responsive.value(
          phone: AppFontSize.sizeSuperLarge ?? 32,
          tablet: (AppFontSize.sizeSuperLarge ?? 32) + 6,
          largeTablet: (AppFontSize.sizeSuperLarge ?? 32) + 10,
        );
        final buttonFontSize = responsive.value(
          phone: 16.0,
          tablet: 19.0,
          largeTablet: 21.0,
        );
        final loginConfig = loginViewModel.userLogin;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: loginViewModel.isBusy
                  ? Center(
                      child: LoadingAnimationWidget.threeRotatingDots(
                        color: AppColor.primaryColor,
                        size: 50,
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(pagePadding),
                            child: Center(
                              child: ConstrainedBox(
                                constraints:
                                    BoxConstraints(maxWidth: maxContentWidth),
                                child: Column(
                                  children: [
                                    SizedBox(height: isTablet ? 28 : 20),
                                    Text(
                                      AppLanguage.getText('XacNhanCheckin')
                                          .toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: titleFontSize,
                                        fontWeight: FontWeight.w900,
                                        color: AppColor.successQRCode,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          final codeFontSize = isTablet
                                              ? qrFontSize
                                              : (AppFontSize.sizeMedium ?? 20);
                                          return FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        '${AppLanguage.getText('MaThamDu')}: ',
                                                    style: TextStyle(
                                                      fontSize: codeFontSize,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: AppColor
                                                          .successQRCode,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: widget.user.maQR,
                                                    style: TextStyle(
                                                      fontSize: codeFontSize,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: AppColor.darkColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              maxLines: 1,
                                              softWrap: false,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    _buildFieldRow(loginConfig?.field2,
                                        widget.user.field2),
                                    _buildFieldRow(loginConfig?.field3,
                                        widget.user.field3),
                                    _buildFieldRow(loginConfig?.field4,
                                        widget.user.field4),
                                    _buildFieldRow(loginConfig?.field5,
                                        widget.user.field5),
                                    _buildFieldRow(loginConfig?.field6,
                                        widget.user.field6),
                                    _buildFieldRow(loginConfig?.field7,
                                        widget.user.field7),
                                    _buildFieldRow(loginConfig?.field8,
                                        widget.user.field8),
                                    _buildFieldRow(loginConfig?.field9,
                                        widget.user.field9),
                                    _buildFieldRow(loginConfig?.field10,
                                        widget.user.field10),
                                    _buildFieldRow(loginConfig?.field11,
                                        widget.user.field11),
                                    _buildFieldRow(loginConfig?.field12,
                                        widget.user.field12),
                                    _buildFieldRow(loginConfig?.field13,
                                        widget.user.field13),
                                    _buildFieldRow(loginConfig?.field14,
                                        widget.user.field14),
                                    _buildFieldRow(loginConfig?.field15,
                                        widget.user.field15),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              pagePadding, 8, pagePadding, pagePadding),
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed:
                                      _isSubmitting ? null : _handleConfirm,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColor.successQRCode,
                                    side: BorderSide(
                                      color: AppColor.successQRCode,
                                      width: 1.5,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: _isSubmitting
                                      ? SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColor.successQRCode,
                                          ),
                                        )
                                      : Text(
                                          AppLanguage.getText('XacNhan')
                                              .toUpperCase(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: buttonFontSize,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: _isSubmitting
                                      ? null
                                      : () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColor.primaryColor,
                                    side: BorderSide(
                                      color: AppColor.primaryColor,
                                      width: 1.5,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    AppLanguage.getText('Dong').toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: buttonFontSize,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  /// Same presentation as [SuccessScreenQR] field rows (no gray fill).
  Widget _buildFieldRow(String? loginField, String? userField) {
    if (loginField == null && userField == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (loginField != null) ...[
          Text(
            '$loginField:',
            style: TextStyle(
              fontSize: AppFontSize.sizeSmall,
              color: AppColor.successQRCode,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
        const SizedBox(height: 8),
        if (userField != null && userField.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColor.successQRCode,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              userField,
              style: TextStyle(
                fontSize: AppFontSize.sizeMedium,
              ),
            ),
          ),
        ],
        const Divider(height: 15, thickness: 0.1),
      ],
    );
  }
}
