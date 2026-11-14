import 'package:checkin/app/app_language.dart';
import 'package:checkin/base/app_responsive.dart';
import 'package:checkin/model/user.model.dart';
import 'package:checkin/viewmodel/login.vm.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:stacked/stacked.dart';

class ManualCheckinSuccessPage extends StatelessWidget {
  final Users user;
  final Future<void> Function()? onContinueCheckin;
  final Future<void> Function()? onBackToList;
  final DateTime? checkedInAt;
  final bool showAutoCloseMessage;
  final Duration autoCloseDuration;

  const ManualCheckinSuccessPage({
    super.key,
    required this.user,
    this.onContinueCheckin,
    this.onBackToList,
    this.checkedInAt,
    this.showAutoCloseMessage = false,
    this.autoCloseDuration = const Duration(seconds: 3),
  });

  static const _green = Color(0xFF2EAA4F);
  static const _deepGreen = Color(0xFF218B3D);
  static const _pageBackground = Color(0xFFF7FBF6);
  static const _infoBorder = Color(0xFFE9E1D2);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LoginViewModel>.reactive(
      viewModelBuilder: () => LoginViewModel(),
      onViewModelReady: (loginViewModel) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!context.mounted) {
            return;
          }
          await loginViewModel.loadUser();
        });
      },
      builder: (context, loginViewModel, child) {
        final responsive = context.responsive;
        final pageHorizontal = responsive.value(
          phone: 16.0,
          tablet: 40.0,
          largeTablet: 56.0,
        );
        final maxContentWidth = responsive.contentMaxWidth(
          phone: double.infinity,
          tablet: 900,
          largeTablet: 1100,
        );
        final fields = _buildFields(loginViewModel.userLogin);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: _pageBackground,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: _pageBackground,
            body: SafeArea(
              child: loginViewModel.isBusy
                  ? Center(
                      child: LoadingAnimationWidget.threeRotatingDots(
                        color: _green,
                        size: 50,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        pageHorizontal,
                        responsive.value(
                          phone: 16,
                          tablet: 26,
                          largeTablet: 32,
                        ),
                        pageHorizontal,
                        responsive.value(
                          phone: 20,
                          tablet: 28,
                          largeTablet: 34,
                        ),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(maxWidth: maxContentWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SuccessHeader(
                                time: _formatCheckinTime(),
                                green: _green,
                                deepGreen: _deepGreen,
                              ),
                              const SizedBox(height: 16),
                              _QrCodeCard(
                                qrCode: user.maQR,
                                green: _deepGreen,
                              ),
                              const SizedBox(height: 18),
                              _AttendeeInfoCard(
                                fields: fields,
                                borderColor: _infoBorder,
                              ),
                              if (showAutoCloseMessage) ...[
                                const SizedBox(height: 18),
                                _AutoCloseCountdown(
                                  duration: autoCloseDuration,
                                  onComplete: () {
                                    if (context.mounted) {
                                      Navigator.maybePop(context);
                                    }
                                  },
                                ),
                              ],
                              const SizedBox(height: 26),
                              _ActionButton(
                                icon: Icons.qr_code_scanner_rounded,
                                label: AppLanguage.getText(
                                  'TiepTucCheckinThanhCong',
                                ),
                                foregroundColor: Colors.white,
                                backgroundColor: _green,
                                onPressed: () => _leave(
                                  context,
                                  onContinueCheckin,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _ActionButton(
                                icon: Icons.chevron_left_rounded,
                                label: AppLanguage.getText(
                                  'QuayLaiDanhSachThanhCong',
                                ),
                                foregroundColor: const Color(0xFF2D2B2B),
                                backgroundColor: Colors.white,
                                borderColor: _infoBorder,
                                onPressed: () => _leave(
                                  context,
                                  onBackToList,
                                ),
                              ),
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

  List<_InfoField> _buildFields(dynamic loginConfig) {
    final configured = <_InfoField>[
      _InfoField(
        label: loginConfig?.field2 ?? AppLanguage.getText('HoTen'),
        value: user.field2,
      ),
      _InfoField(
        label: loginConfig?.field3 ?? AppLanguage.getText('SoDienThoai'),
        value: user.field3,
      ),
      _InfoField(
        label: loginConfig?.field4 ?? AppLanguage.getText('KhuVuc'),
        value: user.field4,
      ),
      _InfoField(label: loginConfig?.field5, value: user.field5),
      _InfoField(label: loginConfig?.field6, value: user.field6),
      _InfoField(label: loginConfig?.field7, value: user.field7),
      _InfoField(label: loginConfig?.field8, value: user.field8),
      _InfoField(label: loginConfig?.field9, value: user.field9),
      _InfoField(label: loginConfig?.field10, value: user.field10),
      _InfoField(label: loginConfig?.field11, value: user.field11),
      _InfoField(label: loginConfig?.field12, value: user.field12),
      _InfoField(label: loginConfig?.field13, value: user.field13),
      _InfoField(label: loginConfig?.field14, value: user.field14),
      _InfoField(label: loginConfig?.field15, value: user.field15),
    ];

    return configured
        .where((field) => field.value?.trim().isNotEmpty == true)
        .toList();
  }

  String _formatCheckinTime() {
    final raw = user.thoiDiemCheckin ?? user.ngayCheckin;
    final parsed = raw == null ? null : DateTime.tryParse(raw);
    final dateTime = parsed?.toLocal() ?? checkedInAt ?? DateTime.now();
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/${dateTime.year} · $hour:$minute';
  }

  Future<void> _leave(
    BuildContext context,
    Future<void> Function()? callback,
  ) async {
    try {
      await callback?.call();
    } catch (_) {
      return;
    }
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _InfoField {
  const _InfoField({required this.label, required this.value});

  final String? label;
  final String? value;
}

class _AutoCloseCountdown extends StatefulWidget {
  const _AutoCloseCountdown({
    required this.duration,
    required this.onComplete,
  });

  final Duration duration;
  final VoidCallback onComplete;

  @override
  State<_AutoCloseCountdown> createState() => _AutoCloseCountdownState();
}

class _AutoCloseCountdownState extends State<_AutoCloseCountdown> {
  Timer? _timer;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _secondsFromDuration(widget.duration);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      if (_remainingSeconds <= 1) {
        _timer?.cancel();
        widget.onComplete();
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return Text(
      '${AppLanguage.getText('TuDongDongSau')} $_remainingSeconds',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: const Color(0xFF77716D),
        fontSize: responsive.value(phone: 14, tablet: 18),
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  int _secondsFromDuration(Duration duration) {
    final seconds = (duration.inMilliseconds / 1000).ceil();
    return seconds < 1 ? 1 : seconds;
  }
}

class _SuccessHeader extends StatelessWidget {
  const _SuccessHeader({
    required this.time,
    required this.green,
    required this.deepGreen,
  });

  final String time;
  final Color green;
  final Color deepGreen;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Container(
      padding: EdgeInsets.all(
        responsive.value(phone: 17, tablet: 22, largeTablet: 26),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [green, deepGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          responsive.value(phone: 24, tablet: 28, largeTablet: 30),
        ),
        boxShadow: [
          BoxShadow(
            color: green.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: responsive.value(phone: 56, tablet: 68, largeTablet: 74),
            height: responsive.value(phone: 56, tablet: 68, largeTablet: 74),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.42),
                width: 2,
              ),
              color: Colors.white.withValues(alpha: 0.08),
            ),
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: responsive.value(phone: 34, tablet: 42, largeTablet: 46),
            ),
          ),
          SizedBox(width: responsive.value(phone: 14, tablet: 18)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLanguage.getText('CheckInThanhCong'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.value(
                      phone: 21,
                      tablet: 28,
                      largeTablet: 32,
                    ),
                    fontWeight: FontWeight.w800,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: responsive.value(phone: 14, tablet: 18),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QrCodeCard extends StatelessWidget {
  const _QrCodeCard({required this.qrCode, required this.green});

  final String qrCode;
  final Color green;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.value(phone: 18, tablet: 24),
        vertical: responsive.value(phone: 16, tablet: 20),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          responsive.value(phone: 20, tablet: 24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.value(phone: 12, tablet: 15),
              vertical: responsive.value(phone: 6, tablet: 8),
            ),
            decoration: BoxDecoration(
              color: green,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              'QR',
              style: TextStyle(
                color: Colors.white,
                fontSize: responsive.value(phone: 14, tablet: 18),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(width: responsive.value(phone: 16, tablet: 20)),
          Expanded(
            child: Text(
              qrCode,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFF145D31),
                fontSize: responsive.value(
                  phone: 27,
                  tablet: 36,
                  largeTablet: 42,
                ),
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendeeInfoCard extends StatelessWidget {
  const _AttendeeInfoCard({required this.fields, required this.borderColor});

  final List<_InfoField> fields;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Container(
      padding: EdgeInsets.fromLTRB(
        responsive.value(phone: 22, tablet: 28),
        responsive.value(phone: 14, tablet: 20),
        responsive.value(phone: 22, tablet: 28),
        responsive.value(phone: 8, tablet: 12),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          responsive.value(phone: 22, tablet: 26),
        ),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: fields.isEmpty
          ? Text(
              AppLanguage.getText('ChuaCoDuLieuCheckin'),
              style: TextStyle(
                color: const Color(0xFF77716D),
                fontSize: responsive.value(phone: 15, tablet: 18),
              ),
            )
          : Column(
              children: fields
                  .map(
                    (field) => _AttendeeInfoRow(
                      field: field,
                      borderColor: borderColor,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _AttendeeInfoRow extends StatelessWidget {
  const _AttendeeInfoRow({required this.field, required this.borderColor});

  final _InfoField field;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        8,
        responsive.value(phone: 11, tablet: 14),
        8,
        responsive.value(phone: 13, tablet: 16),
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label ?? AppLanguage.getText('ThongTin'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF9A928D),
              fontSize: responsive.value(
                phone: 14,
                tablet: 17,
                largeTablet: 19,
              ),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            field.value!.trim(),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF292627),
              fontSize: responsive.value(
                phone: 19,
                tablet: 24,
                largeTablet: 28,
              ),
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.onPressed,
    this.borderColor,
  });

  final IconData icon;
  final String label;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color? borderColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: responsive.value(phone: 24, tablet: 30),
        ),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: responsive.value(
              phone: 18,
              tablet: 23,
              largeTablet: 26,
            ),
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor,
          elevation: borderColor == null ? 3 : 0,
          shadowColor: const Color(0x332EAA4F),
          side: borderColor == null ? null : BorderSide(color: borderColor!),
          padding: EdgeInsets.symmetric(
            vertical: responsive.value(phone: 17, tablet: 21),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              responsive.value(phone: 18, tablet: 22),
            ),
          ),
        ),
      ),
    );
  }
}
