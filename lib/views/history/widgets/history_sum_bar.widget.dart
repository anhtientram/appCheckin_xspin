import 'package:checkin/app/app_language.dart';
import 'package:checkin/base/app_responsive.dart';
import 'package:checkin/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HistorySumBar extends StatelessWidget {
  final bool isBusy;
  final String totalValue;
  final String checkedInValue;
  final String notCheckedInValue;
  final String? totalLabel;
  final int? selectedIndex;
  final ValueChanged<int>? onTap;

  static const Color _allColor = Colors.orange;
  static final Color _checkedColor = AppColor.successQRCode;
  static final Color _notCheckedColor = AppColor.primaryColor;
  static const Color _allBg = Color(0xFFFFF3E0);
  static const Color _checkedBg = Color(0xFFE8F5E9);
  static const Color _notCheckedBg = Color(0xFFFFEBEE);

  const HistorySumBar({
    super.key,
    required this.isBusy,
    required this.totalValue,
    required this.checkedInValue,
    required this.notCheckedInValue,
    this.totalLabel,
    this.selectedIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final isTablet = responsive.isTablet;
    final isCompact = responsive.isCompactPhone;
    final isSelectable = onTap != null;

    final topPadding = isTablet ? 20.0 : (isCompact ? 12.0 : 16.0);
    final bottomPadding = isTablet ? 10.0 : 6.0;
    final horizontalPadding = isTablet ? 16.0 : 8.0;
    final labelSize = isTablet ? 18.0 : (isCompact ? 13.0 : 15.0);
    final valueSize = isTablet ? 18.0 : (isCompact ? 14.0 : 16.0);
    final gap = isTablet ? 12.0 : (isCompact ? 6.0 : 8.0);
    final badgeHPad = isTablet ? 18.0 : (isCompact ? 10.0 : 14.0);
    final badgeVPad = isTablet ? 7.0 : 5.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        topPadding,
        horizontalPadding,
        bottomPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _SumItem(
            label: totalLabel ?? AppLanguage.getText('TatCa'),
            value: totalValue,
            color: _allColor,
            backgroundColor: _allBg,
            isBusy: isBusy,
            selected: !isSelectable || selectedIndex == 0,
            isSelectable: isSelectable,
            onTap: onTap == null ? null : () => onTap!(0),
            labelSize: labelSize,
            valueSize: valueSize,
            gap: gap,
            badgeHPad: badgeHPad,
            badgeVPad: badgeVPad,
          ),
          _SumItem(
            label: AppLanguage.getText('DaCheckin'),
            value: checkedInValue,
            color: _checkedColor,
            backgroundColor: _checkedBg,
            isBusy: isBusy,
            selected: !isSelectable || selectedIndex == 1,
            isSelectable: isSelectable,
            onTap: onTap == null ? null : () => onTap!(1),
            labelSize: labelSize,
            valueSize: valueSize,
            gap: gap,
            badgeHPad: badgeHPad,
            badgeVPad: badgeVPad,
          ),
          _SumItem(
            label: AppLanguage.getText('ChuaCheckin'),
            value: notCheckedInValue,
            color: _notCheckedColor,
            backgroundColor: _notCheckedBg,
            isBusy: isBusy,
            selected: !isSelectable || selectedIndex == 2,
            isSelectable: isSelectable,
            onTap: onTap == null ? null : () => onTap!(2),
            labelSize: labelSize,
            valueSize: valueSize,
            gap: gap,
            badgeHPad: badgeHPad,
            badgeVPad: badgeVPad,
          ),
        ],
      ),
    );
  }
}

class _SumItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color backgroundColor;
  final bool isBusy;
  final bool selected;
  final bool isSelectable;
  final VoidCallback? onTap;
  final double labelSize;
  final double valueSize;
  final double gap;
  final double badgeHPad;
  final double badgeVPad;

  const _SumItem({
    required this.label,
    required this.value,
    required this.color,
    required this.backgroundColor,
    required this.isBusy,
    required this.selected,
    required this.isSelectable,
    required this.labelSize,
    required this.valueSize,
    required this.gap,
    required this.badgeHPad,
    required this.badgeVPad,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontSize: labelSize,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ),
        SizedBox(height: gap),
        isBusy
            ? LoadingAnimationWidget.progressiveDots(
                color: color,
                size: valueSize,
              )
            : Container(
                constraints: const BoxConstraints(minWidth: 40),
                padding: EdgeInsets.symmetric(
                  horizontal: badgeHPad,
                  vertical: badgeVPad,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: valueSize,
                    ),
                  ),
                ),
              ),
        if (isSelectable) ...[
          const SizedBox(height: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 3,
            width: double.infinity,
            decoration: BoxDecoration(
              color: selected ? color : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ],
    );

    return Expanded(
      child: onTap == null
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: content,
            )
          : InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: content,
              ),
            ),
    );
  }
}
