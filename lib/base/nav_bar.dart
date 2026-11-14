import 'package:checkin/app/app_language.dart';
import 'package:checkin/base/app_responsive.dart';
import 'package:checkin/constants/app_fontsize.dart';
import 'package:flutter/material.dart';
import 'package:checkin/constants/app_color.dart';

class HomeNavigationBar extends StatefulWidget {
  const HomeNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });
  final int currentIndex;
  final Future<void> Function(int) onTabSelected;

  @override
  State<HomeNavigationBar> createState() => _HomeNavigationBarState();
}

class _HomeNavigationBarState extends State<HomeNavigationBar> {
  @override
  Widget build(BuildContext context) {
    final isTablet = context.responsive.isTablet;
    final selectedFontSize = isTablet ? (AppFontSize.sizeSmall ?? 16) : 14.0;
    final unselectedFontSize = isTablet ? (AppFontSize.sizeSmall ?? 16) : 12.0;
    final sideIconSize = isTablet ? 30.0 : 24.0;
    final qrIconSize = isTablet ? 38.0 : 30.0;
    final qrPadding = isTablet ? 10.0 : 8.0;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.transparent.withValues(
              alpha: 0.1,
            ), // Hoặc màu mong muốn cho gạch ngang
            width: 1.0, // Độ rộng của gạch ngang
          ),
        ),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColor.extraColor,
        currentIndex: widget.currentIndex,
        fixedColor: AppColor.primaryColor,
        unselectedItemColor: AppColor.darkColor,
        selectedFontSize: selectedFontSize,
        unselectedFontSize: unselectedFontSize,
        selectedIconTheme: IconThemeData(size: sideIconSize),
        unselectedIconTheme: IconThemeData(size: sideIconSize),
        selectedLabelStyle: TextStyle(
          fontSize: selectedFontSize,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: unselectedFontSize,
          fontWeight: FontWeight.w800,
        ),
        onTap: (index) async {
          await widget.onTabSelected(index);
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: sideIconSize),
            label: AppLanguage.getText('NguoiThamDu'),
          ),
          BottomNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                color: AppColor.selectColor,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(qrPadding),
              child: Center(
                child: Icon(
                  Icons.qr_code,
                  color: Colors.white, // Màu của icon
                  size: qrIconSize, // Kích thước icon
                ),
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_rounded, size: sideIconSize),
            label: AppLanguage.getText('DanhMuc'),
          ),
        ],
      ),
    );
  }
}
