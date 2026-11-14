import 'package:checkin/app/app_language.dart';
import 'package:checkin/base/app_responsive.dart';
import 'package:checkin/constants/app_color.dart';
import 'package:flutter/material.dart';

class OneTimeCheckinSummary extends StatelessWidget {
  final int totalCount;
  final int checkedInCount;
  final int notCheckedInCount;
  final bool isBusy;

  const OneTimeCheckinSummary({
    required this.totalCount,
    required this.checkedInCount,
    required this.notCheckedInCount,
    required this.isBusy,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final safeTotal = totalCount < 0 ? 0 : totalCount;
    final safeChecked = checkedInCount.clamp(0, safeTotal).toInt();
    final percentage =
        safeTotal == 0 ? 0 : (safeChecked / safeTotal * 100).round();
    final progress = safeTotal == 0 ? 0.0 : safeChecked / safeTotal;

    return Container(
      padding: EdgeInsets.fromLTRB(
        responsive.value(phone: 16, tablet: 24, largeTablet: 30),
        responsive.value(phone: 15, tablet: 20, largeTablet: 24),
        responsive.value(phone: 16, tablet: 24, largeTablet: 30),
        responsive.value(phone: 14, tablet: 18, largeTablet: 22),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          responsive.value(phone: 20, tablet: 24, largeTablet: 28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  AppLanguage.getText('DaCheckin'),
                  style: TextStyle(
                    color: const Color(0xFF777777),
                    fontSize: responsive.value(phone: 15, tablet: 20),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  color: AppColor.primaryColor,
                  fontSize: responsive.value(phone: 28, tablet: 38),
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$safeChecked',
                  style: TextStyle(
                    color: AppColor.successQRCode,
                    fontWeight: FontWeight.w800,
                    fontSize: responsive.value(phone: 29, tablet: 40),
                  ),
                ),
                TextSpan(
                  text: ' / $safeTotal',
                  style: TextStyle(
                    color: AppColor.darkColor,
                    fontWeight: FontWeight.w800,
                    fontSize: responsive.value(phone: 26, tablet: 36),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: responsive.value(phone: 8, tablet: 11),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFFF2E2E3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isBusy ? const Color(0xFF8FC9A2) : const Color(0xFF46B66A),
                ),
              ),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Container(
                width: responsive.value(phone: 8, tablet: 10),
                height: responsive.value(phone: 8, tablet: 10),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE52B3A),
                ),
              ),
              const SizedBox(width: 7),
              Text(
                '${AppLanguage.getText('ChuaCheckin')} $notCheckedInCount',
                style: TextStyle(
                  color: const Color(0xFF707070),
                  fontSize: responsive.value(phone: 14, tablet: 18),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OneTimeCheckinFilters extends StatelessWidget {
  final int selectedIndex;
  final int totalCount;
  final int checkedInCount;
  final int notCheckedInCount;
  final ValueChanged<int> onTap;

  const OneTimeCheckinFilters({
    required this.selectedIndex,
    required this.totalCount,
    required this.checkedInCount,
    required this.notCheckedInCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final filters = [
      (AppLanguage.getText('TatCa'), totalCount),
      (AppLanguage.getText('DaCheckin'), checkedInCount),
      (AppLanguage.getText('ChuaCheckin'), notCheckedInCount),
    ];

    return Container(
      padding: EdgeInsets.all(responsive.value(phone: 4, tablet: 6)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          responsive.value(phone: 16, tablet: 20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: List.generate(filters.length, (index) {
          final selected = index == selectedIndex;
          final item = filters[index];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.value(phone: 1, tablet: 3),
              ),
              child: Material(
                color: selected ? AppColor.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(
                  responsive.value(phone: 12, tablet: 16),
                ),
                child: InkWell(
                  onTap: () => onTap(index),
                  borderRadius: BorderRadius.circular(
                    responsive.value(phone: 12, tablet: 16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: responsive.value(phone: 10, tablet: 14),
                      horizontal: responsive.value(phone: 3, tablet: 8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            item.$1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFF3E3E3E),
                              fontSize: responsive.value(phone: 13, tablet: 18),
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.value(phone: 6, tablet: 8),
                            vertical: responsive.value(phone: 2, tablet: 3),
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.white.withValues(alpha: 0.22)
                                : const Color(0xFFF1EDEA),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${item.$2}',
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFF858585),
                              fontSize: responsive.value(phone: 11, tablet: 15),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
