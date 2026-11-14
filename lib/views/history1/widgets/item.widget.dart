import 'package:checkin/app/app_language.dart';
import 'package:checkin/app/app_sp.dart';
import 'package:checkin/app/app_sp_key.dart';
import 'package:checkin/base/app_responsive.dart';
import 'package:checkin/constants/app_color.dart';
import 'package:checkin/model/user.model.dart';
import 'package:checkin/viewmodel/history_user_checkin.vm.dart';
import 'package:flutter/material.dart';

class ItemTicket extends StatefulWidget {
  final String? qrCodeUrl;

  final VoidCallback onTap;
  final Users user;
  final HistoryCheckinViewModel usersViewModel;
  ItemTicket(
      {super.key,
      this.qrCodeUrl,
      required this.onTap,
      required this.user,
      required this.usersViewModel});

  @override
  State<ItemTicket> createState() => _ItemTicketQRState();
}

class _ItemTicketQRState extends State<ItemTicket> {
  bool get _isManualCheckin =>
      AppSP.get(AppSPKey.isCheckinThuCong)?.toString() == '1';

  bool get _checkedIn => widget.user.hasCheckedIn;

  Color get _accentColor =>
      _checkedIn ? AppColor.successQRCode : AppColor.primaryColor;

  ({String time, String date}) get _dateTimeParts {
    final raw = widget.user.ngayCheckin?.trim() ?? '';
    if (raw.isEmpty) return (time: '', date: '');

    final parsed = DateTime.tryParse(raw.replaceFirst(' ', 'T'));
    if (parsed != null) {
      final time =
          '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
      final date =
          '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
      return (time: time, date: date);
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
    final isTablet = responsive.isTablet;
    final showManualActions = _isManualCheckin && widget.user.canManualCheckIn;
    final dateTimeParts = _dateTimeParts;
    final title = (widget.user.field2 ?? '').trim();

    return InkWell(
      onTap: showManualActions ? null : widget.onTap,
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
                      responsive.value(phone: 14, tablet: 22),
                      responsive.value(phone: 13, tablet: 17),
                      responsive.value(phone: 12, tablet: 18),
                      responsive.value(phone: 13, tablet: 17),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.user.maQR,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _accentColor,
                                  fontSize:
                                      responsive.value(phone: 13, tablet: 17),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                  height:
                                      responsive.value(phone: 4, tablet: 6)),
                              Text(
                                title.isEmpty ? widget.user.maQR : title,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize:
                                      responsive.value(phone: 17, tablet: 23),
                                  color: AppColor.darkColor,
                                  height: 1.12,
                                ),
                              ),
                              if (!_checkedIn) ...[
                                SizedBox(
                                    height:
                                        responsive.value(phone: 7, tablet: 8)),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.visibility_outlined,
                                      size: responsive.value(
                                          phone: 16, tablet: 29),
                                      color: AppColor.darkColor
                                          .withValues(alpha: 0.35),
                                    ),
                                    if (!showManualActions && !isTablet) ...[
                                      const SizedBox(width: 5),
                                      Text(
                                        AppLanguage.getText('XemChiTiet'),
                                        style: TextStyle(
                                          color: AppColor.darkColor
                                              .withValues(alpha: 0.4),
                                          fontSize: responsive.value(
                                              phone: 11, tablet: 13),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(width: responsive.value(phone: 8, tablet: 14)),
                        if (showManualActions)
                          _ManualCheckinActions(
                            responsive: responsive,
                            onCheckin: () {
                              widget.usersViewModel.viewContext = context;
                              widget.usersViewModel
                                  .nextConfirmCheckin(widget.user);
                            },
                          )
                        else
                          _CheckinStatus(
                            responsive: responsive,
                            checkedIn: _checkedIn,
                            time: dateTimeParts.time,
                            date: dateTimeParts.date,
                          ),
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

class _CheckinStatus extends StatelessWidget {
  final AppResponsive responsive;
  final bool checkedIn;
  final String time;
  final String date;

  const _CheckinStatus({
    required this.responsive,
    required this.checkedIn,
    required this.time,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final color = checkedIn ? AppColor.successQRCode : AppColor.primaryColor;
    final showDate = time.isNotEmpty || date.isNotEmpty;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: responsive.value(phone: 90, tablet: 135),
        maxWidth: responsive.value(phone: 150, tablet: 220),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (checkedIn && responsive.isPhone) ...[
            if (time.isNotEmpty)
              Text(
                time,
                style: TextStyle(
                  color: AppColor.darkColor,
                  fontSize: responsive.value(phone: 18, tablet: 22),
                  fontWeight: FontWeight.w700,
                ),
              ),
            if (date.isNotEmpty)
              Text(
                date,
                style: TextStyle(
                  color: const Color(0xFF929292),
                  fontSize: responsive.value(phone: 13, tablet: 15),
                  fontWeight: FontWeight.w500,
                ),
              ),
          ] else if (checkedIn)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check,
                    color: color,
                    size: responsive.value(phone: 16, tablet: 20)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    AppLanguage.getText('DaCheckin'),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: responsive.value(phone: 13, tablet: 17),
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.value(phone: 9, tablet: 12),
                vertical: responsive.value(phone: 5, tablet: 7),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE8EB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                AppLanguage.getText('ChuaCheckin'),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: responsive.value(phone: 12, tablet: 16),
                ),
              ),
            ),
          if (showDate && !(checkedIn && responsive.isPhone)) ...[
            SizedBox(height: responsive.value(phone: 3, tablet: 5)),
            Text(
              [time, date].where((part) => part.isNotEmpty).join(' · '),
              textAlign: TextAlign.end,
              style: TextStyle(
                color: const Color(0xFF929292),
                fontSize: responsive.value(phone: 11, tablet: 15),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ManualCheckinActions extends StatelessWidget {
  final AppResponsive responsive;
  final VoidCallback onCheckin;

  const _ManualCheckinActions({
    required this.responsive,
    required this.onCheckin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: onCheckin,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColor.primaryColor,
            side: BorderSide(
              color: AppColor.primaryColor.withValues(alpha: 0.45),
              width: 1.2,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: responsive.value(phone: 15, tablet: 22),
              vertical: responsive.value(phone: 10, tablet: 14),
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
              fontSize: responsive.value(phone: 14, tablet: 17),
            ),
          ),
        ),
      ],
    );
  }
}
