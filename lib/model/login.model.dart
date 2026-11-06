class Login {
  String? diaDiem;
  String idSuKien; // Không cho phép null
  String? tenSukien;
  String? ngayDienRa;
  int? soLuongField;
  String? field2;
  String? field3;
  String? field4;
  String? field5;
  String? field6;
  String? field7;
  String? field8;
  String? field9;
  String? field10;
  String? field11;
  String? field12;
  String? field13;
  String? field14;
  String? field15;
  String? username;
  String? password;
  String? loaiCheckin;
  String? isNhieuLine;
  String? imageQr;
  String? cameraCheckin;
  String? cameraCheckinThuCong;

  String? maKhachHang;
  String? isCheckinTuDong;
  String? isCheckinThuCong;
  Login(
      {this.diaDiem,
      required this.idSuKien, // Bắt buộc phải có giá trị
      this.tenSukien,
      this.ngayDienRa,
      this.soLuongField,
      this.field2,
      this.field3,
      this.field4,
      this.field5,
      this.field6,
      this.field7,
      this.field8,
      this.field9,
      this.field10,
      this.field11,
      this.loaiCheckin,
      this.field12,
      this.field13,
      this.field14,
      this.field15,
      this.username,
      this.password,
      this.isNhieuLine,
      this.imageQr,
      this.cameraCheckin,
      this.cameraCheckinThuCong,
      this.maKhachHang,
      this.isCheckinTuDong,
      this.isCheckinThuCong});

  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(
        diaDiem: json['DiaDiem'],
        loaiCheckin: json['LoaiCheckin'],
        idSuKien: json['idSuKien'] ?? '',
        tenSukien: json['TenSuKien'],
        ngayDienRa: json['NgayDienRa'],
        soLuongField: json['SoLuongField'],
        field2: json['Field2'],
        field3: json['Field3'],
        field4: json['Field4'],
        field5: json['Field5'],
        field6: json['Field6'],
        field7: json['Field7'],
        field8: json['Field8'],
        field9: json['Field9'],
        field10: json['Field10'],
        field11: json['Field11'],
        field12: json['Field12'],
        field13: json['Field13'],
        field14: json['Field14'],
        field15: json['Field15'],
        username: json['username'],
        password: json['password'],
        isNhieuLine: json['isNhieuLine'],
        imageQr: json['AnhNenQR'],
        cameraCheckin: json['CameraCheckinTuDong'],
        cameraCheckinThuCong: json['CameraCheckinThuCong'],
        isCheckinTuDong: json['isCheckinTuDong']?.toString(),
        isCheckinThuCong: json['isCheckinThuCong']?.toString(),
        maKhachHang: json['MaKhachHang']);
  }

  // Method to convert Login instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'DiaDiem': diaDiem,
      'idSuKien': idSuKien,
      'LoaiCheckin': loaiCheckin,
      'TenSukien': tenSukien,
      'NgayDienRa': ngayDienRa,
      'SoLuongField': soLuongField,
      'Field2': field2,
      'Field3': field3,
      'Field4': field4,
      'Field5': field5,
      'Field6': field6,
      'Field7': field7,
      'Field8': field8,
      'Field9': field9,
      'Field10': field10,
      'Field11': field11,
      'Field12': field12,
      'Field13': field13,
      'Field14': field14,
      'Field15': field15,
      'username': username,
      'password': password,
      'isNhieuLine': isNhieuLine,
      'AnhNenQR': imageQr,
      'CameraCheckinTuDong': cameraCheckin,
      'CameraCheckinThuCong': cameraCheckinThuCong,
      'MaKhachHang': maKhachHang,
      'isCheckinTuDong': isCheckinTuDong,
      'isCheckinThuCong': isCheckinThuCong,
    };
  }
}
