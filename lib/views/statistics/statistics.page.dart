import 'package:checkin/app/app_language.dart';
import 'package:checkin/base/base_page.dart';
import 'package:checkin/constants/app_color.dart';
import 'package:checkin/model/statistics.model.dart';
import 'package:checkin/viewmodel/index.vm.dart';
import 'package:checkin/viewmodel/statistics.vm.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:stacked/stacked.dart';

class StatisticsPage extends StatefulWidget {
  final IndexViewModel? indexViewModel;

  const StatisticsPage({super.key, this.indexViewModel});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final StatisticsViewModel _viewModel = StatisticsViewModel();

  // void _openTabletDemo() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => const StatisticsTabletDemoPage(),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF8F3F1);

    return ViewModelBuilder<StatisticsViewModel>.reactive(
      disposeViewModel: false,
      viewModelBuilder: () => _viewModel,
      onViewModelReady: (viewModel) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) {
            return;
          }
          await widget.indexViewModel?.refreshSession(reloadList: false);
          if (!mounted) {
            return;
          }
          await viewModel.loadStatistics();
        });
      },
      builder: (context, viewModel, child) {
        final mediaQuery = MediaQuery.of(context);
        final isTablet = mediaQuery.size.shortestSide >= 600;
        final listPadding = EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 16,
          vertical: isTablet ? 20 : 16,
        );
        final overview = viewModel.overview;
        final summary = overview?.thongKe;

        return BasePage(
          title: AppLanguage.getText('ThongKe'),
          showLogo: true,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  background,
                  Colors.white,
                ],
              ),
            ),
            child: RefreshIndicator(
              onRefresh: () async {
                await widget.indexViewModel?.refreshSession(reloadList: false);
                await viewModel.loadStatistics();
              },
              color: AppColor.primaryColor,
              child: viewModel.isBusy
                  ? Center(
                      child: LoadingAnimationWidget.threeRotatingDots(
                        color: AppColor.primaryColor,
                        size: 50,
                      ),
                    )
                  : ListView(
                      padding: listPadding,
                      children: [
                        // Align(
                        //   alignment: Alignment.centerRight,
                        //   child: OutlinedButton.icon(
                        //     onPressed: _openTabletDemo,
                        //     icon: const Icon(Icons.tablet_mac_outlined),
                        //     label: const Text('Demo tablet'),
                        //     style: OutlinedButton.styleFrom(
                        //       foregroundColor: AppColor.primaryColor,
                        //       side: BorderSide(
                        //         color: AppColor.primaryColor.withValues(
                        //           alpha: 0.35,
                        //         ),
                        //       ),
                        //       padding: EdgeInsets.symmetric(
                        //         horizontal: isTablet ? 18 : 14,
                        //         vertical: 12,
                        //       ),
                        //       backgroundColor: Colors.white.withValues(
                        //         alpha: 0.92,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(height: isTablet ? 18 : 14),
                        // Container(
                        //   padding: const EdgeInsets.all(18),
                        //   decoration: BoxDecoration(
                        //     gradient: LinearGradient(
                        //       colors: [
                        //         AppColor.primaryColor,
                        //         deepRose,
                        //       ],
                        //     ),
                        //     borderRadius: BorderRadius.circular(24),
                        //     boxShadow: [
                        //       BoxShadow(
                        //         color: AppColor.primaryColor
                        //             .withValues(alpha: 0.16),
                        //         blurRadius: 18,
                        //         offset: const Offset(0, 10),
                        //       ),
                        //     ],
                        //   ),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       // const Text(
                        //       //   'Tổng quan sự kiện',
                        //       //   style: TextStyle(
                        //       //     color: Colors.white,
                        //       //     fontWeight: FontWeight.w800,
                        //       //     fontSize: 20,
                        //       //   ),
                        //       // ),
                        //       // const SizedBox(height: 8),
                        //       // Text(
                        //       //   'Thống kê theo ${viewModel.isSingleCheckin ? 'check-in 1 lần' : 'nhiều lượt check-in'} cho sự kiện ${AppSP.get(AppSPKey.tenTK) ?? ''}.',
                        //       //   style: TextStyle(
                        //       //     color: Colors.white.withValues(alpha: 0.88),
                        //       //     height: 1.4,
                        //       //   ),
                        //       // ),
                        //       // if ((AppSP.get(AppSPKey.tenLineCheckin) ?? '')
                        //       //     .isNotEmpty) ...[
                        //       //   const SizedBox(height: 14),
                        //       //   Container(
                        //       //     padding: const EdgeInsets.symmetric(
                        //       //       horizontal: 12,
                        //       //       vertical: 10,
                        //       //     ),
                        //       //     decoration: BoxDecoration(
                        //       //       color: Colors.white.withValues(alpha: 0.12),
                        //       //       borderRadius: BorderRadius.circular(16),
                        //       //     ),
                        //       //     child: Row(
                        //       //       children: [
                        //       //         const Icon(
                        //       //           Icons.alt_route_rounded,
                        //       //           color: Colors.white,
                        //       //           size: 18,
                        //       //         ),
                        //       //         const SizedBox(width: 8),
                        //       //         Expanded(
                        //       //           child: Text(
                        //       //             'Line hiện tại: ${AppSP.get(AppSPKey.tenLineCheckin) ?? ''}',
                        //       //             style: const TextStyle(
                        //       //               color: Colors.white,
                        //       //               fontWeight: FontWeight.w700,
                        //       //             ),
                        //       //           ),
                        //       //         ),
                        //       //       ],
                        //       //     ),
                        //       //   ),
                        //       // ],
                        //     ],
                        //   ),
                        // ),
                        // const SizedBox(height: 18),
                        if (summary != null)
                          _StatisticMetricsCard(
                            summary: summary,
                            isSingleCheckin: viewModel.isSingleCheckin,
                          ),
                        const SizedBox(height: 16),
                        if (viewModel.groupedStatistics.isNotEmpty) ...[
                          ...viewModel.groupedStatistics.asMap().entries.map(
                                (entry) => _StatisticMetricsCard(
                                  title: entry.value.nhomThongKe,
                                  index: entry.key + 1,
                                  summary: entry.value.thongKe,
                                  isSingleCheckin: viewModel.isSingleCheckin,
                                ),
                              ),
                        ],
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _StatisticMetricsCard extends StatelessWidget {
  const _StatisticMetricsCard({
    this.title,
    this.index,
    required this.summary,
    required this.isSingleCheckin,
  });

  final String? title;
  final int? index;
  final StatisticSummary summary;
  final bool isSingleCheckin;

  @override
  Widget build(BuildContext context) {
    final hasTitle = (title?.trim().isNotEmpty ?? false);
    final metrics = isSingleCheckin
        ? <_MetricTextData>[
            _MetricTextData(
              label: AppLanguage.getText('TongNguoiThamDu'),
              value: summary.tongNguoiThamDu,
              color: const Color(0xFFD8941A),
            ),
            _MetricTextData(
              label: AppLanguage.getText('DaCheckin'),
              value: summary.daCheckin,
              color: const Color(0xFF17823B),
            ),
            _MetricTextData(
              label: AppLanguage.getText('ChuaCheckin'),
              value: summary.chuaCheckin,
              color: const Color(0xFFD81B1B),
            ),
          ]
        : <_MetricTextData>[
            _MetricTextData(
              label: AppLanguage.getText('TongNguoiThamDu'),
              value: summary.tongNguoiThamDu,
              color: const Color(0xFFD8941A),
            ),
            _MetricTextData(
              label: AppLanguage.getText('DaCheckinXong'),
              value: summary.daCheckinXong,
              color: const Color(0xFF17823B),
            ),
            _MetricTextData(
              label: AppLanguage.getText('DangCheckin'),
              value: summary.dangCheckin,
              color: const Color(0xFFE58A2C),
            ),
            _MetricTextData(
              label: AppLanguage.getText('ChuaTungCheckin'),
              value: summary.chuaTungCheckin,
              color: const Color(0xFFD81B1B),
            ),
          ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        final isSmallTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 900;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? (isSmallTablet ? 24 : 28) : 18,
            vertical: isTablet ? (isSmallTablet ? 22 : 24) : 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasTitle) ...[
                Text(
                  index == null ? title!.trim() : '$index. ${title!.trim()}',
                  textAlign: isTablet ? TextAlign.center : TextAlign.start,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: isTablet ? (isSmallTablet ? 20 : 18) : 18,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: isTablet ? 16 : 10),
              ],
              if (isTablet)
                Row(
                  children: metrics
                      .asMap()
                      .entries
                      .map<Widget>(
                        (entry) => Expanded(
                          child: _TabletMetricItem(
                            metric: entry.value,
                            emphasize: !hasTitle,
                            isSmallTablet: isSmallTablet,
                          ),
                        ),
                      )
                      .toList(),
                )
              else
                Column(
                  children: metrics
                      .asMap()
                      .entries
                      .map<Widget>(
                        (entry) => Padding(
                          padding: EdgeInsets.only(
                            bottom: entry.key == metrics.length - 1 ? 0 : 0,
                          ),
                          child: _PhoneMetricItem(
                            metric: entry.value,
                            emphasize: !hasTitle,
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TabletMetricItem extends StatelessWidget {
  const _TabletMetricItem({
    required this.metric,
    required this.emphasize,
    required this.isSmallTablet,
  });

  final _MetricTextData metric;
  final bool emphasize;
  final bool isSmallTablet;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          metric.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: metric.color,
            fontWeight: FontWeight.w600,
            fontSize: emphasize ? 16 : 14,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${metric.value}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: metric.color,
            fontWeight: FontWeight.w700,
            fontSize: emphasize ? 18 : 16,
          ),
        ),
      ],
    );
  }
}

class _PhoneMetricItem extends StatelessWidget {
  const _PhoneMetricItem({
    required this.metric,
    required this.emphasize,
  });

  final _MetricTextData metric;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              metric.label,
              style: TextStyle(
                color: metric.color,
                fontWeight: FontWeight.w700,
                fontSize: emphasize ? 15 : 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${metric.value}',
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
              color: metric.color,
              fontWeight: FontWeight.w800,
              fontSize: emphasize ? 18 : 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTextData {
  const _MetricTextData({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;
}
