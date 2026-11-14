import 'package:checkin/app/app_language.dart';
import 'package:checkin/app/app_sp.dart';
import 'package:checkin/app/app_sp_key.dart';
import 'package:checkin/base/app_responsive.dart';
import 'package:checkin/constants/app_color.dart';
import 'package:checkin/model/user.model.dart';
import 'package:checkin/viewmodel/history_users.vm.dart';
import 'package:flutter/material.dart';

class ItemTicketQR extends StatefulWidget {
  final VoidCallback onTap;
  final Users user;
  final UsersViewModel usersViewModel;
  final bool historyOnly;

  const ItemTicketQR({
    super.key,
    required this.onTap,
    required this.user,
    required this.usersViewModel,
    this.historyOnly = false,
  });

  @override
  State<ItemTicketQR> createState() => _ItemTicketQRState();
}

class _ItemTicketQRState extends State<ItemTicketQR> {
  bool get _isManualCheckin =>
      AppSP.get(AppSPKey.isCheckinThuCong)?.toString() == '1';

  bool get _checkedIn => widget.user.hasCheckedIn;

  Color get _accentColor =>
      _checkedIn ? AppColor.successQRCode : AppColor.primaryColor;

  ({String time, String date}) get _dateTimeParts {
    final raw =
        (widget.user.ngayCheckin ?? widget.user.thoiDiemCheckin ?? '').trim();
    if (raw.isEmpty) return (time: '', date: '');

    final parsed = DateTime.tryParse(raw.replaceFirst(' ', 'T'));
    if (parsed != null) {
      return (
        time:
            '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}',
        date:
            '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}',
      );
    }

    final parts = raw.split(' ');
    final rawTime = parts.length > 1 ? parts.last : '';
    return (
      time: rawTime.length > 5 ? rawTime.substring(0, 5) : rawTime,
      date: parts.isNotEmpty ? parts.first : raw,
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final showManualActions =
        !widget.historyOnly && _isManualCheckin && widget.user.canManualCheckIn;
    final title = (widget.user.field2 ?? '').trim();
    final dateTime = _dateTimeParts;

    return InkWell(
      onTap: widget.historyOnly || showManualActions ? null : widget.onTap,
      borderRadius:
          BorderRadius.circular(responsive.value(phone: 18, tablet: 22)),
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: responsive.value(phone: 5, tablet: 7),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            responsive.value(phone: 18, tablet: 22),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: responsive.value(phone: 8, tablet: 12),
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            responsive.value(phone: 18, tablet: 22),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: responsive.value(phone: 4, tablet: 5),
                  color: _accentColor,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      responsive.value(phone: 16, tablet: 22),
                      responsive.value(phone: 14, tablet: 18),
                      responsive.value(phone: 14, tablet: 20),
                      responsive.value(phone: 14, tablet: 18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: widget.historyOnly ? 6 : 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.user.maQR,
                                    style: TextStyle(
                                      color: _accentColor,
                                      fontSize: responsive.value(
                                          phone: 13, tablet: 17),
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(
                                    height:
                                        responsive.value(phone: 5, tablet: 7),
                                  ),
                                  Text(
                                    title.isEmpty ? widget.user.maQR : title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColor.darkColor,
                                      fontSize: responsive.value(
                                          phone: 18, tablet: 24),
                                      fontWeight: FontWeight.w700,
                                      height: 1.12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: responsive.value(phone: 10, tablet: 18),
                            ),
                            Expanded(
                              flex: widget.historyOnly ? 4 : 6,
                              child: widget.historyOnly
                                  ? _HistoryDateTime(
                                      responsive: responsive,
                                      time: dateTime.time,
                                      date: dateTime.date,
                                    )
                                  : _CheckinStats(
                                      responsive: responsive,
                                      user: widget.user,
                                    ),
                            ),
                          ],
                        ),
                        if (showManualActions) ...[
                          SizedBox(
                            height: responsive.value(phone: 10, tablet: 14),
                          ),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  widget.usersViewModel.viewContext = context;
                                  widget.usersViewModel
                                      .nextConfirmCheckin(widget.user);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColor.primaryColor,
                                  side: BorderSide(
                                    color: AppColor.primaryColor
                                        .withValues(alpha: 0.45),
                                    width: 1.2,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        responsive.value(phone: 16, tablet: 24),
                                    vertical:
                                        responsive.value(phone: 9, tablet: 13),
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      responsive.value(phone: 11, tablet: 14),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  AppLanguage.getText('Checkin'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize:
                                        responsive.value(phone: 14, tablet: 17),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: widget.onTap,
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints.tightFor(
                                  width:
                                      responsive.value(phone: 36, tablet: 46),
                                  height:
                                      responsive.value(phone: 36, tablet: 46),
                                ),
                                tooltip: AppLanguage.getText('XemChiTiet'),
                                icon: Icon(
                                  Icons.visibility_outlined,
                                  size: responsive.value(phone: 20, tablet: 28),
                                  color: AppColor.darkColor
                                      .withValues(alpha: 0.38),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
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

class _HistoryDateTime extends StatelessWidget {
  final AppResponsive responsive;
  final String time;
  final String date;

  const _HistoryDateTime({
    required this.responsive,
    required this.time,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (time.isNotEmpty)
          Text(
            time,
            style: TextStyle(
              color: AppColor.darkColor,
              fontSize: responsive.value(phone: 20, tablet: 26),
              fontWeight: FontWeight.w700,
            ),
          ),
        if (date.isNotEmpty)
          Text(
            date,
            style: TextStyle(
              color: const Color(0xFF929292),
              fontSize: responsive.value(phone: 13, tablet: 17),
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}

class _CheckinStats extends StatelessWidget {
  final AppResponsive responsive;
  final Users user;

  const _CheckinStats({
    required this.responsive,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final textSize = responsive.value(phone: 13.0, tablet: 17.0);
    final lineGap = responsive.value(phone: 5.0, tablet: 8.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${AppLanguage.getText('LuotCheckinToiDa')}: ${user.soLuotCheckIntoida ?? 0}',
          textAlign: TextAlign.end,
          style: TextStyle(
            fontSize: textSize,
            color: const Color(0xFF777777),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: lineGap),
        Text(
          '${AppLanguage.getText('DaCheckin')}: ${user.dacheckIn ?? 0}',
          textAlign: TextAlign.end,
          style: TextStyle(
            fontSize: textSize,
            color: AppColor.successQRCode,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: lineGap),
        Text(
          '${AppLanguage.getText('ChuaCheckin')}: ${user.chuaCheckin ?? 0}',
          textAlign: TextAlign.end,
          style: TextStyle(
            fontSize: textSize,
            color: AppColor.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
