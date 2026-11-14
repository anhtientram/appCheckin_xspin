import 'package:checkin/app/app_language.dart';
import 'package:checkin/app/app_sp.dart';
import 'package:checkin/app/app_sp_key.dart';
import 'package:checkin/base/app_responsive.dart';
import 'package:checkin/constants/app_color.dart';
import 'package:checkin/constants/app_fontsize.dart';
import 'package:checkin/model/line_checkin.model.dart';
import 'package:checkin/requests/login.request.dart';
import 'package:checkin/views/auth/sign_in.dart';
import 'package:checkin/views/index/index.page.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LineSelectionPage extends StatefulWidget {
  const LineSelectionPage({
    super.key,
    this.allowBack = false,
  });

  final bool allowBack;

  @override
  State<LineSelectionPage> createState() => _LineSelectionPageState();
}

class _LineSelectionPageState extends State<LineSelectionPage> {
  final LoginRequest _loginRequest = LoginRequest();
  List<LineCheckin> _lines = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _selectedLineId;

  @override
  void initState() {
    super.initState();
    _loadLines();
  }

  Future<void> _loadLines() async {
    setState(() {
      _isLoading = true;
    });

    final lines = await _loginRequest.getLineCheckins(
      idSuKien: AppSP.get(AppSPKey.idSuKien) ?? '',
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _lines = lines;
      final savedLineId = AppSP.get(AppSPKey.idLineCheckin);
      _selectedLineId = savedLineId ?? _selectedLineId;
      if ((_selectedLineId == null || _selectedLineId!.isEmpty) &&
          lines.length == 1) {
        _selectedLineId = lines.first.idLineCheckin;
      }
      _isLoading = false;
    });
  }

  Future<void> _confirmSelection() async {
    if (_selectedLineId == null || _selectedLineId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLanguage.getText('BanVuiLongChonLineCheckinPhuHop'))),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final selectedLine = _lines.firstWhere(
      (line) => line.idLineCheckin == _selectedLineId,
      orElse: () => LineCheckin(idLineCheckin: _selectedLineId!, tenLine: ''),
    );

    await AppSP.set(AppSPKey.idLineCheckin, selectedLine.idLineCheckin);
    await AppSP.set(AppSPKey.tenLineCheckin, selectedLine.tenLine);

    if (!mounted) {
      return;
    }

    if (widget.allowBack) {
      Navigator.pop(context, true);
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const IndexPage()),
    );
  }

  Future<void> _logout() async {
    await AppSP.set(AppSPKey.tenTK, '');
    await AppSP.set(AppSPKey.password, '');
    await AppSP.set(AppSPKey.idSuKien, '');
    await AppSP.set(AppSPKey.loaiCheckin, '');
    await AppSP.set(AppSPKey.isNhieuLine, '');
    await AppSP.set(AppSPKey.isCheckinTuDong, '');
    await AppSP.set(AppSPKey.isCheckinThuCong, '');
    await AppSP.set(AppSPKey.idLineCheckin, '');
    await AppSP.set(AppSPKey.tenLineCheckin, '');

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SignInView()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final accentBackground = const Color(0xFFF7E4E7);
    final accentDark = const Color(0xFF7A1621);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F3F1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColor.primaryColor,
        centerTitle: true,
        leading: widget.allowBack
            ? IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              )
            : null,
        title: Text(
          widget.allowBack
              ? AppLanguage.getText('DoiLine')
              : AppLanguage.getText('LineCheckin'),
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: responsive.value(phone: 20, tablet: 25),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF8F3F1),
                Color(0xFFFFFFFF),
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(
              responsive.value(phone: 16, tablet: 24, largeTablet: 30),
            ),
            child: _isLoading
                ? Center(
                    child: LoadingAnimationWidget.threeRotatingDots(
                      color: AppColor.primaryColor,
                      size: responsive.value(phone: 50, tablet: 62),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(
                          responsive.value(
                              phone: 18, tablet: 28, largeTablet: 34),
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColor.primaryColor,
                              accentDark,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(
                            responsive.value(phone: 24, tablet: 30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColor.primaryColor.withValues(alpha: 0.18),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(
                                responsive.value(phone: 10, tablet: 14),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(
                                  responsive.value(phone: 16, tablet: 20),
                                ),
                              ),
                              child: Icon(
                                Icons.alt_route_rounded,
                                color: Colors.white,
                                size: responsive.value(phone: 26, tablet: 34),
                              ),
                            ),
                            SizedBox(
                              height: responsive.value(phone: 16, tablet: 22),
                            ),
                            Text(
                              widget.allowBack
                                  ? AppLanguage.getText('DoiLine')
                                  : AppLanguage.getText('LineCheckin'),
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: responsive.value(
                                  phone: AppFontSize.sizeLarge ?? 24,
                                  tablet: 30,
                                ),
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: responsive.value(phone: 8, tablet: 12),
                            ),
                            Text(
                              AppLanguage.getText(
                                  'BanVuiLongChonLineCheckinPhuHop'),
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: responsive.value(
                                  phone: AppFontSize.sizeSmall ?? 16,
                                  tablet: 20,
                                ),
                                color: Colors.white.withValues(alpha: 0.88),
                                height: 1.45,
                              ),
                            ),
                            if ((AppSP.get(AppSPKey.tenTK) ?? '')
                                .toString()
                                .isNotEmpty) ...[
                              SizedBox(
                                height: responsive.value(phone: 12, tablet: 16),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      responsive.value(phone: 10, tablet: 14),
                                  vertical:
                                      responsive.value(phone: 6, tablet: 9),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(
                                    responsive.value(phone: 14, tablet: 18),
                                  ),
                                ),
                                child: Text(
                                  '${AppLanguage.getText('SuKien')}: ${AppSP.get(AppSPKey.tenTK) ?? ''}',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(
                        height: responsive.value(phone: 18, tablet: 24),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            Text(
                              AppLanguage.getText('DanhSachLine'),
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: responsive.value(
                                  phone: AppFontSize.sizeMedium ?? 20,
                                  tablet: 25,
                                ),
                                fontWeight: FontWeight.w800,
                                color: accentDark,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    responsive.value(phone: 10, tablet: 14),
                                vertical: responsive.value(phone: 6, tablet: 9),
                              ),
                              decoration: BoxDecoration(
                                color: accentBackground,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                '${_lines.length} line',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: accentDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: responsive.value(phone: 12, tablet: 16),
                      ),
                      Expanded(
                        child: _lines.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(AppLanguage.getText('ChuaCoLine')),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: _loadLines,
                                      child:
                                          Text(AppLanguage.getText('TaiLai')),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                itemCount: _lines.length,
                                separatorBuilder: (_, __) => SizedBox(
                                  height:
                                      responsive.value(phone: 12, tablet: 16),
                                ),
                                itemBuilder: (context, index) {
                                  final line = _lines[index];
                                  final isSelected =
                                      _selectedLineId == line.idLineCheckin;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                        responsive.value(phone: 22, tablet: 28),
                                      ),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColor.primaryColor
                                            : const Color(0xFFE6D9D6),
                                        width: isSelected ? 1.6 : 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected
                                              ? AppColor.primaryColor
                                                  .withValues(alpha: 0.12)
                                              : Colors.black.withValues(
                                                  alpha: 0.035,
                                                ),
                                          blurRadius: isSelected ? 18 : 10,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(
                                          responsive.value(
                                              phone: 22, tablet: 28),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _selectedLineId =
                                                line.idLineCheckin;
                                          });
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                            responsive.value(
                                                phone: 16, tablet: 24),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: responsive.value(
                                                    phone: 48, tablet: 62),
                                                height: responsive.value(
                                                    phone: 48, tablet: 62),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? AppColor.primaryColor
                                                      : accentBackground,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    responsive.value(
                                                        phone: 16, tablet: 20),
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.qr_code_rounded,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : accentDark,
                                                ),
                                              ),
                                              SizedBox(
                                                width: responsive.value(
                                                    phone: 14, tablet: 20),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      line.tenLine,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        fontSize:
                                                            responsive.value(
                                                          phone: (AppFontSize
                                                                      .sizeMedium ??
                                                                  20) -
                                                              1,
                                                          tablet: 25,
                                                        ),
                                                        color: const Color(
                                                          0xFF211A19,
                                                        ),
                                                      ),
                                                    ),
                                                    // const SizedBox(height: 6),
                                                    // Text(
                                                    //   'Mã line: ${line.idLineCheckin}',
                                                    //   style: TextStyle(
                                                    //     color: Colors.grey[700],
                                                    //     fontWeight:
                                                    //         FontWeight.w500,
                                                    //   ),
                                                    // ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: responsive.value(
                                                    phone: 12, tablet: 18),
                                              ),
                                              AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 180,
                                                ),
                                                width: responsive.value(
                                                    phone: 28, tablet: 36),
                                                height: responsive.value(
                                                    phone: 28, tablet: 36),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? AppColor.primaryColor
                                                      : Colors.transparent,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? AppColor.primaryColor
                                                        : Colors.grey.shade400,
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.check,
                                                  size: responsive.value(
                                                      phone: 16, tablet: 21),
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.transparent,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      SizedBox(
                        height: responsive.value(phone: 16, tablet: 22),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColor.primaryColor,
                                accentDark,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                              responsive.value(phone: 18, tablet: 22),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.primaryColor
                                    .withValues(alpha: 0.18),
                                blurRadius: 16,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _confirmSelection,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              backgroundColor: Colors.transparent,
                              disabledBackgroundColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(
                                vertical:
                                    responsive.value(phone: 16, tablet: 21),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  responsive.value(phone: 18, tablet: 22),
                                ),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    widget.allowBack
                                        ? AppLanguage.getText('LuuThayDoiLine')
                                        : AppLanguage.getText(
                                            'XacNhanLineCheckin'),
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: widget.allowBack
                              ? () => Navigator.maybePop(context)
                              : _logout,
                          child: Text(
                            widget.allowBack
                                ? AppLanguage.getText('Huy')
                                : AppLanguage.getText('DangXuat'),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: accentDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
