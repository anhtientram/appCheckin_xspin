import 'dart:async';

import 'package:checkin/app/app_language.dart';
import 'package:checkin/base/app_responsive.dart';
import 'package:checkin/base/base_page.dart';
import 'package:checkin/constants/app_color.dart';
import 'package:checkin/constants/app_fontsize.dart';
import 'package:checkin/model/user.model.dart';
import 'package:checkin/viewmodel/history_user_checkin.vm.dart';
import 'package:checkin/viewmodel/index.vm.dart';
import 'package:checkin/views/history1/widgets/list.widget.dart';
import 'package:checkin/views/history1/widgets/one_time_summary.widget.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:stacked/stacked.dart';

class HistoryPage1 extends StatefulWidget {
  final HistoryCheckinViewModel usersViewModel;
  final IndexViewModel indexViewModel;
  const HistoryPage1(
      {super.key, required this.usersViewModel, required this.indexViewModel});

  @override
  State<HistoryPage1> createState() => _HistoryPage1State();
}

class _HistoryPage1State extends State<HistoryPage1>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  late TabController _tabController;
  Timer? _searchDebounce;
  bool _isScrollToTopButtonVisible = false;

  List<bool> _scrollStates = [false, false, false];

  @override
  void initState() {
    super.initState();
    _searchController =
        TextEditingController(text: widget.usersViewModel.searchQuery);
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();

    // Lắng nghe sự thay đổi của _searchController và gọi API khi người dùng nhập
    _searchController.addListener(() {
      _onSearchChanged();
    });

    _scrollController.addListener(_scrollListener);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        _isScrollToTopButtonVisible = _scrollStates[_tabController.index];
      });
    });
  }

  void _scrollListener() {
    bool isScrolled = _scrollController.offset >= 200;
    _scrollStates[_tabController.index] = isScrolled;

    if (isScrolled && !_isScrollToTopButtonVisible) {
      setState(() {
        _isScrollToTopButtonVisible = true;
      });
    } else if (!isScrolled && _isScrollToTopButtonVisible) {
      setState(() {
        _isScrollToTopButtonVisible = false;
      });
    }
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      widget.usersViewModel.updateSearchQuery(_searchController.text);

      if (_searchController.text.isEmpty) {
        widget.usersViewModel.resetPagination();
      }

      widget.usersViewModel.getUsers();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await widget.indexViewModel.refreshSession();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
        disposeViewModel: false,
        viewModelBuilder: () => widget.usersViewModel,
        onViewModelReady: (viewModel) async {
          viewModel.viewContext = context;
          await viewModel.init();
        },
        builder: (context, viewModel, child) {
          viewModel.viewContext = context;
          final responsive = context.responsive;
          final totalCount = viewModel.count?.countData ?? 0;
          final checkedInCount = viewModel.countCheckin?.countData ?? 0;
          final notCheckedInCount =
              (totalCount - checkedInCount).clamp(0, totalCount).toInt();

          return BasePage(
            showFloating: true,
            showLogo: true,
            floating: _isScrollToTopButtonVisible
                ? FloatingActionButton(
                    onPressed: () {
                      _scrollController.animateTo(
                        0,
                        duration: Duration(milliseconds: 700),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Icon(
                      Icons.arrow_upward,
                      color: AppColor.darkColor,
                      size: 28,
                    ),
                    backgroundColor:
                        AppColor.unSelectColor.withValues(alpha: 0.5),
                  )
                : null,
            title: AppLanguage.getText('NguoiThamDu'),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF8F3F1), Colors.white],
                ),
              ),
              child: RefreshIndicator(
                onRefresh: _refreshData,
                color: AppColor.primaryColor,
                child: ListView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    responsive.value(phone: 8, tablet: 18, largeTablet: 26),
                    responsive.value(phone: 8, tablet: 14, largeTablet: 20),
                    responsive.value(phone: 8, tablet: 18, largeTablet: 26),
                    responsive.value(phone: 18, tablet: 24, largeTablet: 30),
                  ),
                  children: [
                    OneTimeCheckinSummary(
                      totalCount: totalCount,
                      checkedInCount: checkedInCount,
                      notCheckedInCount: notCheckedInCount,
                      isBusy: viewModel.isBusy,
                    ),
                    const SizedBox(height: 12),
                    OneTimeCheckinFilters(
                      selectedIndex: _tabController.index,
                      totalCount: totalCount,
                      checkedInCount: checkedInCount,
                      notCheckedInCount: notCheckedInCount,
                      onTap: (index) {
                        _tabController.animateTo(index);
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: AppLanguage.getText(
                          'TimKiemTheoTenHoacMaQR',
                          fallback: 'Tìm theo tên hoặc mã QR...',
                        ),
                        hintStyle: TextStyle(
                          color: const Color(0xFF92959B),
                          fontSize: responsive.value(phone: 15, tablet: 19),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: const Color(0xFF7D838B),
                          size: responsive.value(phone: 25, tablet: 31),
                        ),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: _searchController.clear,
                              ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: responsive.value(phone: 14, tablet: 19),
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17),
                          borderSide: const BorderSide(
                            color: Color(0xFFE4E1DE),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17),
                          borderSide: const BorderSide(
                            color: Color(0xFFE4E1DE),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17),
                          borderSide: BorderSide(
                            color: AppColor.primaryColor,
                            width: 1.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    viewModel.isBusy
                        ? Padding(
                            padding: EdgeInsets.only(
                              top: responsive.value(
                                phone: 70,
                                tablet: 130,
                                largeTablet: 170,
                              ),
                            ),
                            child: Center(
                              child: LoadingAnimationWidget.threeRotatingDots(
                                color: AppColor.primaryColor,
                                size: responsive.value(phone: 42, tablet: 52),
                              ),
                            ),
                          )
                        : AnimatedSwitcher(
                            duration: const Duration(milliseconds: 260),
                            child: KeyedSubtree(
                              key: ValueKey(_tabController.index),
                              child: _tabController.index == 0
                                  ? buildUserList(
                                      viewModel.lstUsers,
                                      'allTab',
                                    )
                                  : _tabController.index == 1
                                      ? buildUserList(
                                          viewModel.checkInUser,
                                          'checkedInTab',
                                        )
                                      : buildUserList(
                                          viewModel.notCheckIntUser,
                                          'notCheckedInTab',
                                        ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget buildUserList(List<Users> users, String tabKey) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListUserCheckin(
          usersViewModel: widget.usersViewModel,
          users: users,
        ),
        if (widget.usersViewModel.hasMoreData(tabKey))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
                child: widget.usersViewModel.isLoadingMoreAll &&
                            tabKey == 'allTab' ||
                        widget.usersViewModel.isLoadingMoreCheckedIn &&
                            tabKey == 'checkedInTab' ||
                        widget.usersViewModel.isLoadingMoreNotCheckedIn &&
                            tabKey == 'notCheckedInTab'
                    ? CircularProgressIndicator(
                        color: AppColor.primaryColor,
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: TextButton(
                          onPressed: () async {
                            await widget.usersViewModel.loadMoreUsers(tabKey);
                          },
                          child: Text(
                            AppLanguage.getText('XemThem'),
                            style: TextStyle(
                                color: AppColor.extraColor,
                                fontSize: AppFontSize.sizeSuperSmall),
                          ),
                        ),
                      )),
          ),
      ],
    );
  }
}
