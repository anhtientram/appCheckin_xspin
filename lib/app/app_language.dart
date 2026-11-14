import 'package:checkin/app/app_sp.dart';
import 'package:checkin/app/app_sp_key.dart';
import 'package:checkin/constants/api.dart';
import 'package:checkin/services/api_services.dart';

class AppLanguage {
  static final Map<String, String> _apiLanguages = {};
  static final Map<String, String> _normalizedApiLanguages = {};

  static const Map<String, String> _defaultLanguages = {
    // Navigation & Headers
    'TrangChu': 'Trang chủ',
    'NguoiThamDu': 'Người tham dự',
    'DanhMuc': 'Danh mục',
    'Khac': 'Khác',
    'ThongKe': 'Thống kê',
    'ThongTinSuKien': 'Thông tin sự kiện',
    'ThongTinUngDung': 'Thông tin ứng dụng',
    'ChiaSeUngDung': 'Chia sẻ ứng dụng',
    'PhienBanUngDung': 'Phiên bản ứng dụng',
    'NhaPhatTrien': 'Nhà phát triển ứng dụng',
    'TrangThai': 'Trạng thái',

    // Status & Counts
    'TongLuot': 'Tổng lượt',
    'Luot': 'lượt',
    'DaCheckin': 'Đã check-in',
    'ChuaCheckin': 'Chưa check-in',
    'DaCheckinXong': 'Đã check-in xong',
    'DangCheckin': 'Đang check-in',
    'ChuaTungCheckin': 'Chưa từng check-in',
    'TongNguoiThamDu': 'Tổng người tham dự',
    'TatCa': 'Tất cả',
    'CheckinTuDong': 'Check-in tự động',
    'Checkin': 'Check-in',
    'XacNhanCheckin': 'Xác nhận check-in',
    'XacNhan': 'Xác nhận',
    'Dong': 'Đóng',
    'XemChiTiet': 'Xem chi tiết',

    // Checkin details & Tickets
    'LichSuCheckin': 'Lịch sử check-in',
    'LuotCheckinToiDa': 'Lượt check-in tối đa',
    'SoLuotDaCheckin': 'Số lượt đã check-in',
    'MaKhachHang': 'Mã khách hàng',
    'MaSuKien': 'Mã sự kiện',
    'TenSuKien': 'Tên sự kiện',
    'LineCheckin': 'Line check-in',
    'ThoiGianCheckin': 'Thời gian check-in',
    'DiaDiem': 'Địa điểm',
    'MaQR': 'Mã QR',
    'MaThamDu': 'Mã tham dự',
    'CheckinQRCode': 'Checkin QR Code',

    // Line selection & Navigation center
    'TrungTamDieuHuong': 'Trung tâm điều hướng',
    'LineHienTai': 'Line hiện tại',
    'DoiLine': 'Đổi line',
    'DanhSachLine': 'Danh sách line',
    'LuuThayDoiLine': 'Lưu thay đổi line',
    'XacNhanLineCheckin': 'Xác nhận line check-in',
    'BanVuiLongChonLineCheckinPhuHop':
        'Bạn vui lòng chọn line check-in phù hợp',
    'ChuaCoLine': 'Chưa có line check-in để chọn',
    'TaiLai': 'Tải lại',
    'SuKien': 'Sự kiện',
    'TacVuChinh': 'Tác vụ chính',

    // Upgrade & Pro plan
    'NangCapGoiChuyenNghiep': 'Nâng cấp gói chuyên nghiệp',
    'ThongBaoNangCapGoi':
        'Nâng cấp lên gói chuyên nghiệp để sử dụng tính năng check-in tự động',
    'DaHieu': 'Đã hiểu',

    // Auth & Profile
    'Taikhoan': 'Tài khoản',
    'TaiKhoan': 'Tài khoản',
    'DangNhap': 'Đăng nhập',
    'DangNhapThatBai': 'Đăng nhập thất bại',
    'ThuLai': 'Thử lại',
    'DangXuat': 'Đăng xuất',
    'BanCoMuonDangXuat': 'Bạn có chắc chắn muốn đăng xuất không?',
    'Co': 'Có',

    // Actions & Buttons
    'Huy': 'Hủy',
    'TimKiem': 'Tìm kiếm',
    'TimKiemTheoTenHoacMaQR': 'Tìm theo tên hoặc mã QR...',
    'ThongTin': 'Thông tin',
    'ThongBao': 'Thông báo',
    'TiepTucCheckIn': 'TIẾP TỤC CHECK IN',
    'QuayLaiDanhSach': 'QUAY LẠI DANH SÁCH',
    'TiepTucCheckinThanhCong': 'Tiếp tục check-in',
    'QuayLaiDanhSachThanhCong': 'Quay lại danh sách',
    'HoTen': 'Họ tên',
    'SoDienThoai': 'Số điện thoại',
    'KhuVuc': 'Khu vực',
    'TuDongDongSau': 'Tự động đóng sau',
    'XemThem': 'Xem thêm',
    'ChuaCoDuLieuCheckin': 'Chưa có dữ liệu check-in',

    // Errors & Scanner messages
    'HayDuaMaQRVaoGiuaKhung': 'Hãy đưa mã QR vào giữa khung',
    'VuiLongNhapMaQRDemo': 'Vui lòng nhập mã QR demo',
    'QRCodeKhongHopLe': 'QR Code không hợp lệ!',
    'CheckinThatBaiLienHeAdmin':
        'Check-in thất bại. Bạn vui lòng liên hệ admin để xử lý!!',
    'MaDaQuet': 'Mã đã quét',
    'QRCodeKhongTonTai': 'QRCode Không tồn tại',
    'DaHetLuotCheckin': 'đã hết lượt check-in!',
    'DaDuocCheckinRoi': 'đã được check-in rồi!',
    'LoiKetNoiInternet':
        'Lỗi kết nối internet. Vui lòng kiểm tra Wi-Fi hoặc dữ liệu di động.',
    'SuCoInternet': 'Sự cố internet. Vui lòng thử lại.',
    'CheckInThanhCong': 'Check-in thành công!',
    'CoLoiXayRa': 'Có lỗi xảy ra',
    'KhongTheTaiDuLieuNguoiDung': 'Không thể tải dữ liệu người dùng.',
    'VuiLongThuLaiVoiMaQRKhac': 'Vui lòng thử lại với mã QR khác.',
  };

  static final Map<String, String> _normalizedDefaultLanguages = {
    for (var entry in _defaultLanguages.entries)
      entry.key.toLowerCase(): entry.value
  };

  /// Set languages directly from API list
  static void setLanguages(List<dynamic> list) {
    _apiLanguages.clear();
    _normalizedApiLanguages.clear();
    for (var item in list) {
      if (item is Map && item['MaNgonNgu'] != null && item['NgonNgu'] != null) {
        final key = item['MaNgonNgu'].toString();
        final value = item['NgonNgu'].toString();
        _apiLanguages[key] = value;
        _normalizedApiLanguages[key.toLowerCase()] = value;
      }
    }
  }

  /// Fetch languages from API by idSuKien
  static Future<void> fetchLanguages(String idSuKien) async {
    if (idSuKien.isEmpty) return;
    try {
      final response = await ApiService().get(
        '${Api.hostApi}${Api.getListNgonNgu}',
        queryParameters: {'idSuKien': idSuKien},
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['LNgonNgu'] is List) {
          setLanguages(data['LNgonNgu'] as List<dynamic>);
          print('Fetch list ngon ngu thanh cong: ${_apiLanguages.length} keys');
        }
      }
    } catch (e) {
      print('Fetch list ngon ngu error: $e');
    }
  }

  /// Reload languages using current event id from local storage.
  static Future<void> refreshLanguages() async {
    final idSuKien = AppSP.get(AppSPKey.idSuKien)?.toString() ?? '';
    await fetchLanguages(idSuKien);
  }

  /// Get translated text by key with fallback to default languages map (case-insensitive)
  static String getText(String key, {String? fallback}) {
    // 1. Exact match in API response
    if (_apiLanguages.containsKey(key) && _apiLanguages[key]!.isNotEmpty) {
      return _apiLanguages[key]!;
    }
    // 2. Case-insensitive match in API response
    final lowerKey = key.toLowerCase();
    if (_normalizedApiLanguages.containsKey(lowerKey) &&
        _normalizedApiLanguages[lowerKey]!.isNotEmpty) {
      return _normalizedApiLanguages[lowerKey]!;
    }
    // 3. Exact match in default languages
    if (_defaultLanguages.containsKey(key)) {
      return _defaultLanguages[key]!;
    }
    // 4. Case-insensitive match in default languages
    if (_normalizedDefaultLanguages.containsKey(lowerKey)) {
      return _normalizedDefaultLanguages[lowerKey]!;
    }
    // 5. Fallback if provided
    if (fallback != null && fallback.isNotEmpty) {
      return fallback;
    }
    return key;
  }
}
