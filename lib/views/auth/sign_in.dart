import 'package:checkin/base/app_responsive.dart';
import 'package:checkin/constants/app_color.dart';
import 'package:checkin/viewmodel/login.vm.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final Uri _termsUrl = Uri.parse('https://xspin.vn/dieu-khoan-su-dung');
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) {
      return;
    }
    setState(() => _appVersion = packageInfo.version);
  }

  Future<void> _launchTerms() async {
    if (!await launchUrl(_termsUrl)) {
      throw Exception('Could not launch $_termsUrl');
    }
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LoginViewModel>.reactive(
      viewModelBuilder: LoginViewModel.new,
      onViewModelReady: (viewModel) => viewModel.viewContext = context,
      builder: (context, viewModel, child) {
        final responsive = context.responsive;
        final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
        final isKeyboardVisible = keyboardHeight > 0;
        final headerHeight = responsive.value(
          compactPhone: isKeyboardVisible ? 165.0 : 225.0,
          phone: isKeyboardVisible ? 190.0 : 285.0,
          tablet: isKeyboardVisible ? 270.0 : 400.0,
          largeTablet: isKeyboardVisible ? 300.0 : 440.0,
        );
        final cardOverlap = responsive.value(
          compactPhone: 44.0,
          phone: 55.0,
          tablet: 100.0,
          largeTablet: 115.0,
        );

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: const Color(0xFFF4F5F7),
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _dismissKeyboard,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  // The scaffold already resizes this area when the keyboard
                  // is visible. Keeping the scroll view's inset independent
                  // avoids subtracting the keyboard height twice on iPad.
                  padding: const EdgeInsets.only(bottom: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _LoginHeader(
                          height: headerHeight,
                          responsive: responsive,
                        ),
                        Transform.translate(
                          offset: Offset(0, -cardOverlap),
                          child: Padding(
                            padding: responsive.pagePadding(
                              compactPhone: 14,
                              phone: 20,
                              tablet: 36,
                              largeTablet: 48,
                            ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: responsive.contentMaxWidth(
                                  phone: 560,
                                  tablet: 620,
                                  largeTablet: 680,
                                ),
                              ),
                              child: _LoginCard(viewModel: viewModel),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: responsive.value(
                            compactPhone: 28,
                            phone: 40,
                            tablet: 64,
                            largeTablet: 80,
                          ),
                        ),
                        _LoginFooter(
                          appVersion: _appVersion,
                          onTermsPressed: _launchTerms,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader({
    required this.height,
    required this.responsive,
  });

  final double height;
  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    final logoWidth = responsive.value(
      compactPhone: responsive.width * 0.84,
      phone: responsive.width * 0.8,
      tablet: 510.0,
      largeTablet: 570.0,
    );
    final logoAlignmentY = responsive.value(
      compactPhone: -0.48,
      phone: -0.55,
      tablet: -0.3,
      largeTablet: -0.25,
    );

    return AnimatedContainer(
      width: double.infinity,
      height: height,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      child: CustomPaint(
        painter: const _LoginHeaderPainter(),
        child: SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment(0, logoAlignmentY),
            child: ClipRect(
              child: SizedBox(
                width: logoWidth,
                height: logoWidth * 0.42,
                child: Image.asset(
                  'assets/logo_xspin.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginHeaderPainter extends CustomPainter {
  const _LoginHeaderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColor.primaryColor,
    );

    final circlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(
      Offset(size.width * 0.02, size.height * 0.18),
      size.width * 0.38,
      circlePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.72, -size.height * 0.02),
      size.width * 0.14,
      circlePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.96, size.height * 0.88),
      size.width * 0.25,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LoginHeaderPainter oldDelegate) => false;
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({required this.viewModel});

  final LoginViewModel viewModel;

  Future<void> _submit(BuildContext context) async {
    if (viewModel.isBusy) {
      return;
    }
    FocusScope.of(context).unfocus();
    await viewModel.showSignInSuccessDialog(
      context,
      viewModel.username.text.trim(),
      viewModel.password.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final cardPadding = responsive.value(
      compactPhone: 18.0,
      phone: 24.0,
      tablet: 34.0,
      largeTablet: 40.0,
    );
    final fieldActionSize = responsive.value(
      compactPhone: 36.0,
      phone: 42.0,
      tablet: 46.0,
    );
    final fieldActionMargin = responsive.value(
      compactPhone: 3.0,
      phone: 5.0,
    );

    return Material(
      color: Colors.white,
      elevation: 18,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(
        responsive.value(phone: 24, tablet: 30),
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'System Login',
                style: TextStyle(
                  color: const Color(0xFF17191D),
                  fontSize: responsive.value(phone: 24, tablet: 28),
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the event code and password provided by the organizer.',
                style: TextStyle(
                  color: const Color(0xFF70747D),
                  fontSize: responsive.value(
                    compactPhone: 12,
                    phone: 13,
                    tablet: 15,
                  ),
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: responsive.value(phone: 24, tablet: 30)),
              _LoginTextField(
                label: 'Event Code',
                hintText: 'Enter event code',
                controller: viewModel.username,
                prefixIcon: Icons.calendar_today_outlined,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                suffix: Container(
                  width: fieldActionSize,
                  height: fieldActionSize,
                  margin: EdgeInsets.all(fieldActionMargin),
                  padding: EdgeInsets.all(
                    responsive.value(compactPhone: 8, phone: 10),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(
                    'assets/barcode.png',
                    fit: BoxFit.contain,
                    color: const Color(0xFF555A63),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _LoginTextField(
                label: 'Password',
                hintText: 'Enter password',
                controller: viewModel.password,
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: viewModel.obscureText,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) => _submit(context),
                suffix: SizedBox(
                  width: fieldActionSize,
                  height: fieldActionSize,
                  child: InkWell(
                    onTap: viewModel.showhidePassword,
                    child: Icon(
                      viewModel.obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: const Color(0xFF686D76),
                    ),
                  ),
                ),
              ),
              SizedBox(height: responsive.value(phone: 22, tablet: 28)),
              SizedBox(
                width: double.infinity,
                height: responsive.value(phone: 54, tablet: 60),
                child: FilledButton(
                  onPressed: viewModel.isBusy ? null : () => _submit(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    disabledBackgroundColor:
                        AppColor.primaryColor.withValues(alpha: 0.62),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    elevation: 8,
                    shadowColor: AppColor.primaryColor.withValues(alpha: 0.38),
                  ),
                  child: viewModel.isBusy
                      ? LoadingAnimationWidget.threeRotatingDots(
                          color: Colors.white,
                          size: 30,
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Login',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginTextField extends StatelessWidget {
  const _LoginTextField({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.prefixIcon,
    required this.textInputAction,
    required this.autofillHints,
    required this.suffix,
    this.obscureText = false,
    this.onSubmitted,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final IconData prefixIcon;
  final TextInputAction textInputAction;
  final Iterable<String> autofillHints;
  final Widget suffix;
  final bool obscureText;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final borderRadius = BorderRadius.circular(13);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF4E525A),
            fontSize: responsive.value(phone: 13, tablet: 15),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          onSubmitted: onSubmitted,
          style: TextStyle(
            color: const Color(0xFF30333A),
            fontSize: responsive.value(phone: 15, tablet: 17),
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF9A9EA7),
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: const Color(0xFF646973),
              size: 20,
            ),
            prefixIconConstraints: BoxConstraints(
              minWidth: responsive.value(
                compactPhone: 40,
                phone: 44,
                tablet: 48,
              ),
            ),
            suffixIcon: suffix,
            suffixIconConstraints: BoxConstraints(
              minWidth: responsive.value(
                compactPhone: 42,
                phone: 48,
                tablet: 52,
              ),
            ),
            filled: true,
            fillColor: const Color(0xFFFCFCFD),
            contentPadding: EdgeInsets.symmetric(
              horizontal: responsive.value(compactPhone: 6, phone: 10),
              vertical: 17,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: const BorderSide(color: Color(0xFFD9DCE1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: AppColor.primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginFooter extends StatelessWidget {
  const _LoginFooter({
    required this.appVersion,
    required this.onTermsPressed,
  });

  final String appVersion;
  final VoidCallback onTermsPressed;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final textStyle = TextStyle(
      color: const Color(0xFF6F737C),
      fontSize: responsive.value(
        compactPhone: 11,
        phone: 12,
        tablet: 14,
      ),
      fontWeight: FontWeight.w600,
    );

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          responsive.value(phone: 24, tablet: 36),
          20,
          responsive.value(phone: 18, tablet: 28),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: onTermsPressed,
                style: TextButton.styleFrom(
                  foregroundColor: AppColor.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Terms of Use',
                  style: textStyle.copyWith(
                    color: AppColor.primaryColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(
                width: 30,
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 8),
              //   child: Text('•', style: textStyle),
              // ),
              Text('Version $appVersion', style: textStyle),
            ],
          ),
        ),
      ),
    );
  }
}
