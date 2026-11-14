import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:checkin/app/app_language.dart';
import 'package:checkin/app/app_sp.dart';
import 'package:checkin/app/app_sp_key.dart';
import 'package:checkin/base/app_dialog.dart';
import 'package:checkin/constants/app_color.dart';
import 'package:checkin/model/count_users.dart';
import 'package:checkin/model/user.model.dart';
import 'package:checkin/requests/history_user.requets.dart';
import 'package:checkin/requests/qrcode.request.dart';
import 'package:checkin/viewmodel/index.vm.dart';
import 'package:checkin/views/history/widgets/confirm_checkin.widget.dart';
import 'package:checkin/views/history1/widgets/detail.widget.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class HistoryCheckinViewModel extends BaseViewModel {
  late BuildContext viewContext;
  late Users detailUser;
  UserRequest userRequest = UserRequest();
  late IndexViewModel indexViewModel;
  // final apiService = ApiService();
  List<Users> lstUsers = [];
  List<Users> checkInUser = [];
  List<Users> notCheckIntUser = [];
  List<Users> filteredUsers = [];
  List<Users> filteredCheckInUser = [];
  List<Users> filteredNotCheckIntUser = [];
  TextEditingController search = TextEditingController();
  String searchQuery = '';
  CountLstThamDuModel? count;
  CountLstThamDuModel? countCheckin;
  int currentPageAll = 1;
  int currentPageCheckedIn = 1;
  int currentPageNotCheckedIn = 1;
  bool isLoadingMoreAll = false;
  bool isLoadingMoreCheckedIn = false;
  bool isLoadingMoreNotCheckedIn = false;
  QRCodeRequest qrCodeRequest = QRCodeRequest();
  Future<void>? _initFuture;
  bool _hasLoadedInitialData = false;

  Future<void> init() {
    if (_hasLoadedInitialData) {
      return Future.value();
    }
    if (_initFuture != null) {
      return _initFuture!;
    }

    _initFuture = _initInternal();
    return _initFuture!;
  }

  Future<void> _initInternal() async {
    try {
      await Future.wait([
        getUsers(),
        getCountUser(),
        getCountUserCheckIn(),
      ]);
      _hasLoadedInitialData = true;
    } finally {
      _initFuture = null;
    }
  }

  Future<void> reloadUsers() async {
    print('Tình trạng 1L');
    resetPagination();
    await Future.wait([
      getUsers(),
      getCountUser(),
      getCountUserCheckIn(),
    ]);
  }

  Future<void> getUsers() async {
    setBusy(true);
    try {
      final results = await Future.wait([
        userRequest.getListUser_1L(
            idSuKien: AppSP.get(AppSPKey.idSuKien),
            tinhTrang: "",
            page: currentPageAll,
            searchQuery: searchQuery),
        userRequest.getListUser_1L(
            idSuKien: AppSP.get(AppSPKey.idSuKien),
            tinhTrang: "DaCheckin",
            page: currentPageCheckedIn,
            searchQuery: searchQuery),
        userRequest.getListUser_1L(
            idSuKien: AppSP.get(AppSPKey.idSuKien),
            tinhTrang: 'ChuaCheckin',
            page: currentPageNotCheckedIn,
            searchQuery: searchQuery),
      ]);

      lstUsers = results[0];
      checkInUser = results[1];
      notCheckIntUser = results[2];
    } catch (e) {
      print('Lỗi getUsers 1L: $e');
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> loadMoreUsers(String tab) async {
    if (tab == 'allTab') {
      isLoadingMoreAll = true;
    } else if (tab == 'checkedInTab') {
      isLoadingMoreCheckedIn = true;
    } else if (tab == 'notCheckedInTab') {
      isLoadingMoreNotCheckedIn = true;
    }
    notifyListeners();

    try {
      if (tab == 'allTab') {
        currentPageAll++;
        var moreUsers = await userRequest.getListUser_1L(
            idSuKien: AppSP.get(AppSPKey.idSuKien),
            tinhTrang: '',
            page: currentPageAll,
            searchQuery: searchQuery);
        if (moreUsers.isNotEmpty) {
          lstUsers.addAll(moreUsers);
        }
        isLoadingMoreAll = false;
      } else if (tab == 'checkedInTab') {
        currentPageCheckedIn++;
        var moreCheckedInUsers = await userRequest.getListUser_1L(
            idSuKien: AppSP.get(AppSPKey.idSuKien),
            tinhTrang: 'DaCheckin',
            page: currentPageCheckedIn,
            searchQuery: searchQuery);
        if (moreCheckedInUsers.isNotEmpty) {
          checkInUser.addAll(moreCheckedInUsers);
        }
        isLoadingMoreCheckedIn = false;
      } else if (tab == 'notCheckedInTab') {
        currentPageNotCheckedIn++;
        var moreNotCheckedInUsers = await userRequest.getListUser_1L(
            idSuKien: AppSP.get(AppSPKey.idSuKien),
            tinhTrang: 'ChuaCheckin',
            page: currentPageNotCheckedIn,
            searchQuery: searchQuery);
        if (moreNotCheckedInUsers.isNotEmpty) {
          notCheckIntUser.addAll(moreNotCheckedInUsers);
        }
        isLoadingMoreNotCheckedIn = false;
      }
    } catch (e) {
      print("Lỗi loadMoreUsers 1L: $e");
      isLoadingMoreAll = false;
      isLoadingMoreCheckedIn = false;
      isLoadingMoreNotCheckedIn = false;
    } finally {
      filterUsers();
      notifyListeners();
    }
  }

  Future<void> getCountUser() async {
    setBusy(true);
    count = await userRequest.getCountUser_1L(
        idSuKien: AppSP.get(AppSPKey.idSuKien), tinhTrang: '');
    setBusy(false);
    notifyListeners();
  }

  Future<void> getCountUserCheckIn() async {
    setBusy(true);
    countCheckin = await userRequest.getCountUser_1L(
        idSuKien: AppSP.get(AppSPKey.idSuKien), tinhTrang: 'DaCheckin');
    setBusy(false);
    notifyListeners();
  }

  void filterUsers() {
    final query = searchQuery.toLowerCase();
    filteredUsers = lstUsers.where((user) {
      return _matchesQuery(user, query);
    }).toList();
    filteredCheckInUser = checkInUser.where((user) {
      return user.isCheckin && _matchesQuery(user, query);
    }).toList();
    filteredNotCheckIntUser = notCheckIntUser.where((user) {
      return !user.isCheckin && _matchesQuery(user, query);
    }).toList();
    notifyListeners(); // Cập nhật lại giao diện sau khi lọc xong
  }

// Hàm phụ để kiểm tra xem user có khớp với query không
  bool _matchesQuery(Users user, String query) {
    return (user.field2?.toLowerCase().contains(query) ?? false) ||
        (user.field3?.toLowerCase().contains(query) ?? false) ||
        (user.field4?.toLowerCase().contains(query) ?? false) ||
        (user.field5?.toLowerCase().contains(query) ?? false) ||
        (user.field6?.toLowerCase().contains(query) ?? false) ||
        (user.field7?.toLowerCase().contains(query) ?? false) ||
        user.maQR.toLowerCase().contains(query);
  }

  void updateSearchQuery(String query) {
    searchQuery = query;
    search.text = query;
    notifyListeners();
  }

  void resetPagination() {
    currentPageAll = 1;
    currentPageCheckedIn = 1;
    currentPageNotCheckedIn = 1;
  }

  bool hasMoreData(String tabKey) {
    if (tabKey == 'allTab') {
      final total = count?.countData ?? 0;
      return total > 0 && lstUsers.length < total;
    }
    if (tabKey == 'checkedInTab') {
      final total = countCheckin?.countData ?? 0;
      return total > 0 && checkInUser.length < total;
    }
    if (tabKey == 'notCheckedInTab') {
      final total = (count?.countData ?? 0) - (countCheckin?.countData ?? 0);
      return total > 0 && notCheckIntUser.length < total;
    }
    return false;
  }

  void markNeedsReload() {
    _hasLoadedInitialData = false;
  }

  nextDetailTicket() async {
    Navigator.push(
      viewContext,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => DetailTicket1(
          user: detailUser,
          usersViewModel: this,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          // Di chuyển child theo animation
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  Future<void> nextConfirmCheckin(Users user) async {
    await Navigator.push(
      viewContext,
      MaterialPageRoute(
        builder: (context) => ConfirmCheckinPage(
          user: user,
          onConfirm: manualCheckIn,
          onBackToList: reloadUsers,
        ),
      ),
    );
  }

  Future<bool> manualCheckIn(Users user) async {
    try {
      final result = await qrCodeRequest.checkIn(
        idSuKien: AppSP.get(AppSPKey.idSuKien),
        maQR: user.maQR,
        idLineCheckin: AppSP.get(AppSPKey.idLineCheckin),
      );

      if (result.status == 1) {
        return true;
      }

      _showCheckInFailedDialog(
        result.message ?? AppLanguage.getText('CheckinThatBaiLienHeAdmin'),
      );
      return false;
    } catch (e) {
      _showCheckInFailedDialog(AppLanguage.getText('LoiKetNoiInternet'));
      return false;
    }
  }

  void _showCheckInFailedDialog(String message) {
    AwesomeDialog(
      context: viewContext,
      dialogBackgroundColor: AppDialog.backgroundColor,
      width: AppDialog.width(viewContext),
      dialogBorderRadius: AppDialog.borderRadius(viewContext),
      padding: AppDialog.padding(viewContext),
      bodyHeaderDistance: AppDialog.bodyHeaderDistance(viewContext),
      dialogType: DialogType.error,
      animType: AnimType.topSlide,
      title: AppLanguage.getText('ThongBao'),
      desc: message,
      btnOkColor: AppColor.selectColor,
      btnOkOnPress: () {},
      btnOkText: AppLanguage.getText('DaHieu'),
    ).show();
  }
}
