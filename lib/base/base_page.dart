import 'package:flutter/material.dart';
import 'package:checkin/constants/app_color.dart';

class BasePage extends StatefulWidget {
  final bool showLogo;
  final bool showSearch;
  final String? title;
  final bool showLogout;
  final bool showAppBar;
  final Widget body;
  final Widget? floating;
  final Widget? bottomNav;
  final bool showLeading;
  final VoidCallback? onPressedLeading;
  final Widget? bottomSheet;
  final bool showFloating;
  const BasePage({
    super.key,
    this.showLogo = false,
    this.showSearch = false,
    this.floating,
    this.title,
    this.showLogout = false,
    this.showAppBar = true,
    this.showFloating = false,
    this.bottomSheet,
    required this.body,
    this.bottomNav,
    this.showLeading = true,
    this.onPressedLeading,
  });

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.extraColor,
      appBar: widget.showAppBar
          ? AppBar(
              toolbarHeight: 60,
              backgroundColor: AppColor.primaryColor,
              centerTitle: true,
              iconTheme: const IconThemeData(
                color: AppColor.extraColor,
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title ?? '',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        color: AppColor.extraColor,
                        fontWeight: FontWeight.bold),
                  ),
                  widget.showLogo
                      ? Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Image.asset(
                            'assets/logo_xspin.png',
                            width: 120,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        )
                      : SizedBox.shrink()
                ],
              ),
            )
          : null,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: widget.body,
      ),
      floatingActionButton: widget.showFloating ? widget.floating : null,
      bottomNavigationBar: widget.bottomNav,
      bottomSheet: widget.bottomSheet,
    );
  }
}
