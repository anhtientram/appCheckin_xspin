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
        final maxContentWidth = responsive.contentMaxWidth(
          phone: double.infinity,
          tablet: 860,
          largeTablet: 1040,
        );
        final pagePadding = responsive.value(
          phone: 16.0,
          tablet: 34.0,
          largeTablet: 52.0,
        );
        final titleFontSize = responsive.value(
          phone: AppFontSize.sizeLarge ?? 24,
          tablet: 30.0,
          largeTablet: 34.0,
        );
        final qrFontSize = responsive.value(
          phone: 25.0,
          tablet: 34.0,
          largeTablet: 40.0,
        );
        final buttonFontSize = responsive.value(
          phone: 17.0,
          tablet: 21.0,
          largeTablet: 23.0,
        );
        final loginConfig = loginViewModel.userLogin;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFFF5FBF6),
            body: SafeArea(
              child: loginViewModel.isBusy
                  ? Center(
                      child: LoadingAnimationWidget.threeRotatingDots(
                        color: AppColor.primaryColor,
                        size: 50,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        pagePadding,
                        responsive.value(
                            phone: 18, tablet: 30, largeTablet: 38),
                        pagePadding,
                        responsive.value(
                            phone: 20, tablet: 34, largeTablet: 42),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(maxWidth: maxContentWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                AppLanguage.getText('XacNhanCheckin')
                                    .toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF21743B),
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(
                                height: responsive.value(
                                    phone: 18, tablet: 26, largeTablet: 30),
                              ),
                              _buildQrCard(responsive, qrFontSize),
                              SizedBox(
                                height: responsive.value(
                                    phone: 16, tablet: 24, largeTablet: 28),
                              ),
                              _buildInfoCard(loginConfig, responsive),
                              SizedBox(
                                height: responsive.value(
                                    phone: 22, tablet: 34, largeTablet: 42),
                              ),
                              _buildConfirmButton(buttonFontSize, responsive),
                              SizedBox(
                                height: responsive.value(
                                    phone: 12, tablet: 16, largeTablet: 20),
                              ),
                              _buildCloseButton(buttonFontSize, responsive),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQrCard(AppResponsive responsive, double qrFontSize) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.value(phone: 18, tablet: 28, largeTablet: 34),
        vertical: responsive.value(phone: 14, tablet: 20, largeTablet: 24),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          responsive.value(phone: 22, tablet: 28, largeTablet: 32),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D8E4A).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: responsive.value(phone: 46, tablet: 62, largeTablet: 70),
            height: responsive.value(phone: 46, tablet: 62, largeTablet: 70),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAE31),
              borderRadius: BorderRadius.circular(
                responsive.value(phone: 12, tablet: 16, largeTablet: 18),
              ),
            ),
            child: Icon(
              Icons.qr_code_2_rounded,
              color: Colors.white,
              size: responsive.value(phone: 29, tablet: 40, largeTablet: 46),
            ),
          ),
          SizedBox(
              width: responsive.value(phone: 16, tablet: 22, largeTablet: 28)),
          Expanded(
            child: Text(
              widget.user.maQR,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFF237A3D),
                fontSize: qrFontSize,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(dynamic loginConfig, AppResponsive responsive) {
    final fields = <MapEntry<String?, String?>>[
      MapEntry(loginConfig?.field2, widget.user.field2),
      MapEntry(loginConfig?.field3, widget.user.field3),
      MapEntry(loginConfig?.field4, widget.user.field4),
      MapEntry(loginConfig?.field5, widget.user.field5),
      MapEntry(loginConfig?.field6, widget.user.field6),
      MapEntry(loginConfig?.field7, widget.user.field7),
      MapEntry(loginConfig?.field8, widget.user.field8),
      MapEntry(loginConfig?.field9, widget.user.field9),
      MapEntry(loginConfig?.field10, widget.user.field10),
      MapEntry(loginConfig?.field11, widget.user.field11),
      MapEntry(loginConfig?.field12, widget.user.field12),
      MapEntry(loginConfig?.field13, widget.user.field13),
      MapEntry(loginConfig?.field14, widget.user.field14),
      MapEntry(loginConfig?.field15, widget.user.field15),
    ].where((field) => field.value?.trim().isNotEmpty == true).toList();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.value(phone: 20, tablet: 30, largeTablet: 38),
        vertical: responsive.value(phone: 8, tablet: 12, largeTablet: 16),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          responsive.value(phone: 24, tablet: 30, largeTablet: 34),
        ),
        border: Border.all(color: const Color(0xFFECE4D7)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B7F70).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: fields.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppLanguage.getText('ChuaCoDuLieuCheckin'),
                style: TextStyle(
                  color: const Color(0xFF77716D),
                  fontSize: responsive.value(phone: 15, tablet: 19),
                ),
              ),
            )
          : Column(
              children: List.generate(
                fields.length,
                (index) => _buildFieldRow(
                  fields[index].key,
                  fields[index].value!,
                  responsive,
                  isLast: index == fields.length - 1,
                ),
              ),
            ),
    );
  }

  Widget _buildFieldRow(
    String? loginField,
    String userField,
    AppResponsive responsive, {
    required bool isLast,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: responsive.value(phone: 12, tablet: 17, largeTablet: 21),
      ),
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFEDE8E0)),
              ),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (loginField?.trim().isNotEmpty == true
                    ? loginField!.trim()
                    : AppLanguage.getText('ThongTin'))
                .toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF9A9A9A),
              fontSize:
                  responsive.value(phone: 13, tablet: 17, largeTablet: 19),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userField.trim(),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF292627),
              fontSize:
                  responsive.value(phone: 19, tablet: 25, largeTablet: 29),
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(double fontSize, AppResponsive responsive) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _handleConfirm,
        icon: _isSubmitting
            ? SizedBox(
                width: responsive.value(phone: 22, tablet: 28),
                height: responsive.value(phone: 22, tablet: 28),
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Icon(
                Icons.qr_code_2_rounded,
                size: responsive.value(phone: 24, tablet: 32, largeTablet: 36),
              ),
        label: Text(
          AppLanguage.getText('XacNhan').toUpperCase(),
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF4CAF2A),
          disabledBackgroundColor: const Color(0xFF99C58C),
          elevation: 2,
          padding: EdgeInsets.symmetric(
            vertical: responsive.value(phone: 16, tablet: 21, largeTablet: 24),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              responsive.value(phone: 18, tablet: 24, largeTablet: 28),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton(double fontSize, AppResponsive responsive) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isSubmitting ? null : () => Navigator.pop(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColor.primaryColor,
          side: BorderSide(
            color: AppColor.primaryColor,
            width: responsive.value(phone: 1.5, tablet: 2),
          ),
          padding: EdgeInsets.symmetric(
            vertical: responsive.value(phone: 15, tablet: 20, largeTablet: 23),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              responsive.value(phone: 18, tablet: 24, largeTablet: 28),
            ),
          ),
        ),
        child: Text(
          AppLanguage.getText('Dong').toUpperCase(),
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
