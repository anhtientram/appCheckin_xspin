import 'package:checkin/app/app_language.dart';
import 'package:checkin/app/app_sp.dart';
import 'package:checkin/app/app_sp_key.dart';
import 'package:checkin/base/app_responsive.dart';
import 'package:checkin/base/base_page.dart';
import 'package:checkin/constants/app_color.dart';
import 'package:checkin/viewmodel/index.vm.dart';
import 'package:checkin/viewmodel/login.vm.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class ProfilePage extends StatefulWidget {
  final IndexViewModel indexViewModel;
  final LoginViewModel loginViewModel;

  const ProfilePage({
    super.key,
    required this.indexViewModel,
    required this.loginViewModel,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> _refreshData() async {
    await widget.indexViewModel.refreshSession(reloadList: false);
    await _loadCounters();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadCounters() async {
    if (AppSP.get(AppSPKey.loaiCheckin) == '1L') {
      await widget.indexViewModel.historyViewModel.getCountUser();
      await widget.indexViewModel.historyViewModel.getCountUserCheckIn();
      return;
    }

    await widget.indexViewModel.usersViewModel.getCountUser();
    await widget.indexViewModel.usersViewModel.getCountUserCheckIn();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LoginViewModel>.reactive(
      disposeViewModel: false,
      viewModelBuilder: () => widget.loginViewModel,
      onViewModelReady: (viewModel) {
        viewModel.viewContext = context;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) {
            return;
          }
          await widget.indexViewModel.refreshSession(reloadList: false);
          await _loadCounters();
          if (mounted) {
            setState(() {});
          }
        });
      },
      builder: (context, viewModel, child) {
        final responsive = context.responsive;
        final isSingleCheckin = AppSP.get(AppSPKey.loaiCheckin) == '1L';
        final checkedIn = isSingleCheckin
            ? widget.indexViewModel.historyViewModel.countCheckin?.countData
            : widget.indexViewModel.usersViewModel.countCheckin?.countData;
        final total = isSingleCheckin
            ? widget.indexViewModel.historyViewModel.count?.countData
            : widget.indexViewModel.usersViewModel.count?.countData;
        final checkedInValue = checkedIn ?? 0;
        final totalValue = total ?? 0;
        final progress = totalValue > 0
            ? (checkedInValue / totalValue).clamp(0.0, 1.0)
            : 0.0;
        final event = viewModel.userLogin;
        final eventCode = AppSP.get(AppSPKey.tenTK)?.toString() ?? '';
        final lineName = AppSP.get(AppSPKey.tenLineCheckin)?.toString() ?? '';
        final lineId = AppSP.get(AppSPKey.idLineCheckin)?.toString() ?? '';

        return BasePage(
          title: AppLanguage.getText('ThongTinSuKien'),
          showLogout: true,
          showLogo: true,
          body: RefreshIndicator(
            onRefresh: _refreshData,
            color: AppColor.primaryColor,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                responsive.value(phone: 12, tablet: 16, largeTablet: 20),
                responsive.value(phone: 14, tablet: 14, largeTablet: 18),
                responsive.value(phone: 12, tablet: 16, largeTablet: 20),
                responsive.value(phone: 20, tablet: 22, largeTablet: 26),
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: responsive.contentMaxWidth(
                        phone: double.infinity,
                        tablet: double.infinity,
                        largeTablet: double.infinity,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _EventProgressCard(
                          eventName: event?.tenSukien,
                          checkedIn: checkedInValue,
                          total: totalValue,
                          progress: progress,
                        ),
                        const SizedBox(height: 16),
                        _EventInfoCard(
                          title: AppLanguage.getText('ThongTinSuKien'),
                          children: [
                            _EventInfoTile(
                              icon: Icons.business_outlined,
                              label: AppLanguage.getText('MaKhachHang'),
                              value: event?.maKhachHang,
                            ),
                            _EventInfoTile(
                              icon: Icons.confirmation_number_outlined,
                              label: AppLanguage.getText('MaSuKien'),
                              value: eventCode,
                            ),
                            _EventInfoTile(
                              icon: Icons.calendar_month_outlined,
                              label: AppLanguage.getText('ThoiGianCheckin'),
                              value: event?.ngayDienRa,
                            ),
                            _EventInfoTile(
                              icon: Icons.location_on_outlined,
                              label: AppLanguage.getText('DiaDiem'),
                              value: event?.diaDiem,
                            ),
                            if (lineName.isNotEmpty)
                              _EventInfoTile(
                                icon: Icons.alt_route_outlined,
                                label: AppLanguage.getText('LineCheckin'),
                                value: lineName,
                                secondary:
                                    lineId.isEmpty ? null : 'ID: $lineId',
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EventProgressCard extends StatelessWidget {
  const _EventProgressCard({
    required this.eventName,
    required this.checkedIn,
    required this.total,
    required this.progress,
  });

  final String? eventName;
  final int checkedIn;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final percent = (progress * 100).round();

    return Container(
      padding: EdgeInsets.all(
        responsive.value(phone: 16, tablet: 18, largeTablet: 20),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.primaryColor,
            AppColor.primaryColor.withValues(alpha: 0.78),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          responsive.value(phone: 24, tablet: 28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.event_available_outlined,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  eventName?.trim().isNotEmpty == true
                      ? eventName!.trim()
                      : AppLanguage.getText('ThongTinSuKien'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.value(phone: 20, tablet: 26),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  AppLanguage.getText('SoLuotDaCheckin'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: responsive.value(phone: 15, tablet: 18),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: responsive.value(phone: 30, tablet: 38),
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$checkedIn',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.value(phone: 38, tablet: 48),
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                TextSpan(
                  text: ' / $total',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: responsive.value(phone: 22, tablet: 28),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: responsive.value(phone: 11, tablet: 14),
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventInfoCard extends StatelessWidget {
  const _EventInfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              color: const Color(0xFF3E4249),
              fontSize: responsive.value(phone: 18, tablet: 22),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _EventInfoTile extends StatelessWidget {
  const _EventInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.secondary,
  });

  final IconData icon;
  final String label;
  final String? value;
  final String? secondary;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final displayValue = value?.trim().isNotEmpty == true ? value!.trim() : '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(
        horizontal: responsive.value(phone: 14, tablet: 14, largeTablet: 16),
        vertical: responsive.value(phone: 12, tablet: 12, largeTablet: 14),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE7E3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: AppColor.primaryColor, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: const Color(0xFF858990),
                    fontSize: responsive.value(phone: 12, tablet: 14),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  displayValue,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF25282E),
                    fontSize: responsive.value(phone: 15, tablet: 18),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (secondary?.isNotEmpty == true) ...[
                  const SizedBox(height: 2),
                  Text(
                    secondary!,
                    style: TextStyle(
                      color: const Color(0xFF92969D),
                      fontSize: responsive.value(phone: 11, tablet: 14),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
