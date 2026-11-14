import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:checkin/app/app_language.dart';
import 'package:checkin/app/app_sp.dart';
import 'package:checkin/app/app_sp_key.dart';
import 'package:checkin/base/app_dialog.dart';
import 'package:checkin/constants/app_color.dart';
import 'package:checkin/model/checkin.model.dart';
import 'package:checkin/model/count_users.dart';
import 'package:checkin/model/quantity.model.dart';
import 'package:checkin/model/user.model.dart';
import 'package:checkin/requests/history_user.requets.dart';
import 'package:checkin/requests/qrcode.request.dart';
import 'package:checkin/viewmodel/index.vm.dart';
import 'package:checkin/views/history/widgets/confirm_checkin.widget.dart';
import 'package:checkin/views/history/widgets/detail.ticket.widget.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class UsersViewModel extends BaseViewModel {
  late BuildContext viewContext;
  Users? detailUser;
  // Users? currentUser;

  UserRequest userRequest = UserRequest();
  late IndexViewModel indexViewModel;
  // final apiService = ApiService();
  List<Users> lstUsers = [];
  List<Users> checkInUser = [];
  List<Users> notCheckIntUser = [];
  List<Users> filteredUsers = [];
  List<Users> filteredCheckInUser = [];
  List<Users> filteredNotCheckIntUser = [];
  List<CheckinModel> userStatus = [];
  TextEditingController search = TextEditingController();
  String searchQuery = '';
  CountDataModel? count;
  CountLstThamDuModel? countUser;
  CountDataModel? countCheckin;
  int currentPageAll = 1;
  int currentPageCheckedIn = 1;
  int currentPageNotCheckedIn = 1;
  bool isLoadingMoreAll = false;
  bool isLoadingMoreCheckedIn = false;
  bool isLoadingMoreNotCheckedIn = false;
  QRCodeRequest qrCodeRequest = QRCodeRequest();
  String selectedStatus = 'all';
  CountLstThamDuModel? sumUser;
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
      await getUserStatus();
      await Future.wait([
        getUsers(),
        getCountUserJoin(''),
        getSumUserJoin(),
        getCountUser(),
        getCountUserCheckIn(),
      ]);
      _hasLoadedInitialData = true;
    } finally {
      _initFuture = null;
    }
  }

  void updateSelectedStatus(String status) {
    selectedStatus = status;
    notifyListeners(); // Thông báo để cập nhật giao diện
  }

  Future<void> getUserStatus() async {
    userStatus = await userRequest.getUserStatus();
  }

  Future<void> getUsersPage1() async {
    setBusy(true);
    try {
      lstUsers = await userRequest.getListUser(
        idSuKien: AppSP.get(AppSPKey.idSuKien),
        maTinhTrang: '',
        page: 1,
        searchQuery: searchQuery,
      );
      selectedStatus = 'all';
    } catch (e) {
      print('Error in getUsersByStatus: $e');
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> getUsersByStatus(String? status) async {
    setBusy(true);
    try {
      currentPageAll = 1;
      selectedStatus = status ?? selectedStatus;
      lstUsers = await userRequest.getListUser(
        idSuKien: AppSP.get(AppSPKey.idSuKien),
        maTinhTrang: status ?? '',
        page: currentPageAll,
        searchQuery: searchQuery,
      );
    } catch (e) {
      print('Error in getUsersByStatus: $e');
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> getUsers() async {
    setBusy(true);

    try {
      if (userStatus.isEmpty) {
        await getUserStatus();
      }

      if (userStatus.isEmpty) {
        print("Danh sách userStatus chưa được khởi tạo hoặc rỗng.");
        lstUsers = [];
        checkInUser = [];
        return;
      }

      final validStatuses = userStatus
          .where((status) =>
              status.idStatus != null && status.idStatus!.isNotEmpty)
          .toList();

      final statusRequests = validStatuses
          .map(
            (status) => userRequest.getListUser(
              idSuKien: AppSP.get(AppSPKey.idSuKien),
              maTinhTrang: status.idStatus!,
              page: currentPageAll,
              searchQuery: searchQuery,
            ),
          )
          .toList();

      final results = await Future.wait([
        ...statusRequests,
        userRequest.getListUserCheckin(
          idSuKien: AppSP.get(AppSPKey.idSuKien),
          searchQuery: searchQuery,
        ),
      ]);

      final allUsers = <Users>[];
      for (var i = 0; i < validStatuses.length; i++) {
        final status = validStatuses[i];
        final users = results[i];

        for (var user in users) {
          user.maTinhTrang = status.idStatus;
          user.tenTinhTrang = status.nameStatus;
        }

        allUsers.addAll(users);
        // print(
        //     "Đã thêm ${users.length} người dùng với trạng thái '${status.nameStatus}'.");
      }

      lstUsers = allUsers;
      checkInUser = results.last;
    } catch (e) {
      print('Error in getUsers: $e');
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> reloadUsers() async {
    resetPagination();
    if (selectedStatus == 'all') {
      await Future.wait([
        getUsers(),
        getCountUserJoin(''),
        getSumUserJoin(),
        getCountUser(),
        getCountUserCheckIn(),
      ]);
      return;
    }

    await Future.wait([
      getUsersByStatus(selectedStatus),
      getCountUserJoin(selectedStatus),
      getSumUserJoin(),
      getCountUser(),
      getCountUserCheckIn(),
    ]);
  }

  void onSearchChanged(String query) {
    updateSearchQuery(query);
    getUsers(); // Gọi lại getUsers với query mới
  }

  bool hasMoreData(String tabKey) {
    if (tabKey == 'allTab') {
      final total = countUser?.countData ?? 0;
      return total > 0 && lstUsers.length < total;
    }
    if (tabKey == 'checkedInTab') {
      final total = countCheckin?.countData ?? 0;
      return total > 0 && checkInUser.length < total;
    }
    return false;
  }

  Future<void> loadMoreUsers(String tab) async {
    if (tab == 'allTab') {
      isLoadingMoreAll = true;
    } else if (tab == 'checkedInTab') {
      isLoadingMoreCheckedIn = true;
    }
    notifyListeners();

    try {
      if (tab == 'allTab') {
        currentPageAll++;
        for (var status in userStatus) {
          if (status.idStatus == null || status.idStatus!.isEmpty) {
            continue;
          }

          var moreUsers = await userRequest.getListUser(
            idSuKien: AppSP.get(AppSPKey.idSuKien),
            maTinhTrang: status.idStatus!,
            page: currentPageAll,
            searchQuery: searchQuery,
          );

          if (moreUsers.isNotEmpty) {
            for (var user in moreUsers) {
              user.maTinhTrang = status.idStatus;
              user.tenTinhTrang = status.nameStatus;
            }
            lstUsers.addAll(moreUsers);
            // print(
            //     "Đã thêm ${moreUsers.length} người dùng với tình trạng '${status.nameStatus}'.");
          }
        }
        isLoadingMoreAll = false;
      } else if (tab == 'checkedInTab') {
        currentPageCheckedIn++;

        var moreCheckedInUsers = await userRequest.getListUserCheckin(
          idSuKien: AppSP.get(AppSPKey.idSuKien),
          page: currentPageCheckedIn,
        );

        if (moreCheckedInUsers.isNotEmpty) {
          checkInUser.addAll(moreCheckedInUsers);
          // print("Đã thêm ${moreCheckedInUsers.length} người dùng đã check-in.");
        }

        isLoadingMoreCheckedIn = false;
      }
    } catch (e) {
      print("Error in loadMoreUsers: $e");
    } finally {
      filterUsers();
      notifyListeners();
    }
  }

  Future<void> getCountUser() async {
    setBusy(true);
    count = await userRequest.getCountUser(
        idSuKien: AppSP.get(AppSPKey.idSuKien), tinhTrang: 2);
    setBusy(false);
    notifyListeners();
  }

  Future<void> getCountUserJoin(String? status) async {
    setBusy(true);
    countUser = await userRequest.getCountLstUser(
        idSuKien: AppSP.get(AppSPKey.idSuKien),
        MatinhTrang: status ?? "",
        key: "");
    setBusy(false);
    notifyListeners();
  }

  Future<void> getSumUserJoin() async {
    setBusy(true);
    sumUser = await userRequest.getCountLstUser(
        idSuKien: AppSP.get(AppSPKey.idSuKien), MatinhTrang: "", key: "");
    setBusy(false);
    notifyListeners();
  }

  Future<void> getCountUserCheckIn() async {
    setBusy(true);
    countCheckin = await userRequest.getCountUser(
        idSuKien: AppSP.get(AppSPKey.idSuKien), tinhTrang: 1);
    setBusy(false);
    notifyListeners();
  }

  Future<void> loadQrCode(String maQR) async {
    // setBusy(true);
    try {
      detailUser = await qrCodeRequest.getUser(
          idSuKien: AppSP.get(AppSPKey.idSuKien), maQR: maQR);
      print('Dữ liệu trong lịch sử: ${detailUser?.lichSuCheckin!.length}');
    } catch (e) {
      print('Lỗi khi tải dữ liệu: $e');
    }
    // setBusy(false);
    // notifyListeners();
  }

  void filterUsers() {
    final query = searchQuery.toLowerCase();

    filteredUsers = lstUsers.where((user) {
      return _matchesQuery(user, query);
    }).toList();

    filteredCheckInUser = checkInUser.where((user) {
      return user.isCheckin && _matchesQuery(user, query);
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
    if (search.text != query) {
      search.text = query;
    }
    notifyListeners();
  }

  void resetPagination() {
    currentPageAll = 1;
    currentPageCheckedIn = 1;
    currentPageNotCheckedIn = 1;
  }

  void markNeedsReload() {
    _hasLoadedInitialData = false;
  }

  nextDetailTicket() async {
    Navigator.push(
      viewContext,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => DetailTicket(
          user: detailUser!,
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
