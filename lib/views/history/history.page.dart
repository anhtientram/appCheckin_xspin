import 'dart:async';

import 'package:checkin/app/app_language.dart';
import 'package:checkin/base/app_responsive.dart';
import 'package:checkin/base/base_page.dart';
import 'package:checkin/constants/app_color.dart';
import 'package:checkin/constants/app_fontsize.dart';
import 'package:checkin/model/user.model.dart';
import 'package:checkin/viewmodel/history_users.vm.dart';
import 'package:checkin/viewmodel/index.vm.dart';
import 'package:checkin/views/history/widgets/list.widget.dart';
import 'package:checkin/views/history/widgets/multi_checkin_summary.widget.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:stacked/stacked.dart';

class HistoryPage extends StatefulWidget {
  final UsersViewModel usersViewModel;
  final IndexViewModel indexViewModel;

  const HistoryPage({
    super.key,
    required this.usersViewModel,
    required this.indexViewModel,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  late TabController _tabController;
  Timer? _searchDebounce;
  bool _isScrollToTopButtonVisible = false;
  final List<bool> _scrollStates = [false, false];

  @override
  void initState() {
    super.initState();
    _searchController =
        TextEditingController(text: widget.usersViewModel.searchQuery);
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController();

    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_scrollListener);
    _tabController.addListener(() {
      if (!mounted) return;
      setState(() {
        _isScrollToTopButtonVisible = _scrollStates[_tabController.index];
      });
    });
  }

  void _scrollListener() {
    final isScrolled = _scrollController.offset >= 200;
    _scrollStates[_tabController.index] = isScrolled;

    if (isScrolled != _isScrollToTopButtonVisible) {
      setState(() {
        _isScrollToTopButtonVisible = isScrolled;
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

      if (_tabController.index == 1) {
        widget.usersViewModel.getUsers();
      } else if (widget.usersViewModel.selectedStatus == 'all') {
        widget.usersViewModel.getUsers();
      } else {
        widget.usersViewModel
            .getUsersByStatus(widget.usersViewModel.selectedStatus);
      }
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
        final isHistoryTab = _tabController.index == 1;
        final historyTotal = viewModel.countCheckin?.countData ?? 0;
        final historyChecked = viewModel.count?.countData ?? 0;
        final attendeeCount = viewModel.countUser?.countData ?? 0;

        return BasePage(
          showLogo: true,
          showFloating: true,
          floating: _isScrollToTopButtonVisible
              ? FloatingActionButton(
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  backgroundColor:
                      AppColor.unSelectColor.withValues(alpha: 0.5),
                  child: Icon(
                    Icons.arrow_upward,
                    color: AppColor.darkColor,
                    size: responsive.value(phone: 24, tablet: 30),
                  ),
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
                  MultiCheckinSummary(
                    totalCheckinCount: historyTotal,
                    checkedInCount: historyChecked,
                    isBusy: viewModel.isBusy,
                  ),
                  SizedBox(height: responsive.value(phone: 12, tablet: 16)),
                  MultiCheckinTabs(
                    selectedIndex: _tabController.index,
                    attendeeCount: attendeeCount,
                    historyCount: historyTotal,
                    onTap: (index) {
                      if (_tabController.index != index) {
                        _tabController.animateTo(index);
                      }
                      setState(() {});
                    },
                  ),
                  SizedBox(height: responsive.value(phone: 12, tablet: 16)),
                  if (isHistoryTab)
                    _buildSearchField(responsive)
                  else
                    Row(
                      children: [
                        Expanded(child: _buildSearchField(responsive)),
                        SizedBox(
                          width: responsive.value(phone: 10, tablet: 16),
                        ),
                        Expanded(
                          child: _buildStatusDropdown(viewModel, responsive),
                        ),
                      ],
                    ),
                  SizedBox(height: responsive.value(phone: 12, tablet: 16)),
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
                              size: responsive.value(phone: 42, tablet: 54),
                            ),
                          ),
                        )
                      : AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          child: KeyedSubtree(
                            key: ValueKey(_tabController.index),
                            child: isHistoryTab
                                ? buildUserList(
                                    viewModel.checkInUser,
                                    'checkedInTab',
                                    historyOnly: true,
                                  )
                                : buildUserList(
                                    viewModel.lstUsers,
                                    'allTab',
                                  ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchField(AppResponsive responsive) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: AppLanguage.getText(
          'TimKiemTheoTenHoacMaQR',
          fallback: AppLanguage.getText('TimKiem'),
        ),
        hintStyle: TextStyle(
          color: const Color(0xFF92959B),
          fontSize: responsive.value(phone: 15, tablet: 19),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: const Color(0xFF7D838B),
          size: responsive.value(phone: 24, tablet: 30),
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
          vertical: responsive.value(phone: 12, tablet: 18),
          horizontal: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            responsive.value(phone: 16, tablet: 20),
          ),
          borderSide: const BorderSide(color: Color(0xFFE4E1DE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            responsive.value(phone: 16, tablet: 20),
          ),
          borderSide: const BorderSide(color: Color(0xFFE4E1DE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            responsive.value(phone: 16, tablet: 20),
          ),
          borderSide: BorderSide(color: AppColor.primaryColor, width: 1.2),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(
    UsersViewModel viewModel,
    AppResponsive responsive,
  ) {
    return DropdownButtonFormField2<String>(
      isExpanded: true,
      value: viewModel.selectedStatus,
      decoration: InputDecoration(
        hintText: AppLanguage.getText('TatCa'),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          vertical: responsive.value(phone: 12, tablet: 18),
          horizontal: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            responsive.value(phone: 16, tablet: 20),
          ),
          borderSide: const BorderSide(color: Color(0xFFE4E1DE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            responsive.value(phone: 16, tablet: 20),
          ),
          borderSide: const BorderSide(color: Color(0xFFE4E1DE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            responsive.value(phone: 16, tablet: 20),
          ),
          borderSide: BorderSide(color: AppColor.primaryColor, width: 1.2),
        ),
      ),
      items: [
        DropdownMenuItem<String>(
          value: 'all',
          child: Text(
            AppLanguage.getText('TatCa'),
            style: TextStyle(
              color: AppColor.darkColor,
              fontSize: responsive.value(phone: 14, tablet: 18),
            ),
          ),
        ),
        ...viewModel.userStatus.map(
          (status) => DropdownMenuItem<String>(
            value: status.idStatus,
            child: Text(
              AppLanguage.getText(
                status.idStatus ?? '',
                fallback: status.nameStatus,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColor.darkColor,
                fontSize: responsive.value(phone: 14, tablet: 18),
              ),
            ),
          ),
        ),
      ],
      onChanged: (value) {
        if (value == null) return;
        viewModel.updateSelectedStatus(value);
        if (value == 'all') {
          viewModel.getUsers();
          viewModel.getCountUserJoin('');
        } else {
          viewModel.getUsersByStatus(value);
          viewModel.getCountUserJoin(value);
        }
      },
    );
  }

  Widget buildUserList(
    List<Users> users,
    String tabKey, {
    bool historyOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QRCodeHistoryList(
          usersViewModel: widget.usersViewModel,
          users: users,
          historyOnly: historyOnly,
        ),
        if (widget.usersViewModel.hasMoreData(tabKey))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: (widget.usersViewModel.isLoadingMoreAll &&
                          tabKey == 'allTab') ||
                      (widget.usersViewModel.isLoadingMoreCheckedIn &&
                          tabKey == 'checkedInTab')
                  ? CircularProgressIndicator(
                      color: AppColor.primaryColor,
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                            fontSize: AppFontSize.sizeSuperSmall,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}
