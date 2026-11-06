# API Overview

Base URL: `https://api.xspin.vn/api/ci`

## Auth

### `GET /DangNhap`
- Request:
```json
{
  "MaSuKien": "string",
  "MatKhau": "***"
}
```
- Response keys used in app:
```json
{
  "Status": 1,
  "idSuKien": "string",
  "LoaiCheckin": "NL | 1L",
  "TenSuKien": "string",
  "NgayDienRa": "string",
  "DiaDiem": "string",
  "SoLuongField": 0,
  "Field2": "string",
  "Field3": "string",
  "Field4": "string",
  "Field5": "string",
  "Field6": "string",
  "Field7": "string",
  "Field8": "string",
  "Field9": "string",
  "Field10": "string",
  "Field11": "string",
  "Field12": "string",
  "Field13": "string",
  "Field14": "string",
  "Field15": "string",
  "isNhieuLine": "0 | 1",
  "AnhNenQR": "string",
  "CameraCheckinTuDong": "CameraTruoc | CameraSau",
  "CameraCheckinThuCong": "CameraTruoc | CameraSau",
  "MaKhachHang": "string"
}
```

### `GET /getLineCheckin`
- Request:
```json
{
  "idSuKien": "string"
}
```
- Response keys used in app:
```json
{
  "LLine": [
    {
      "idLineCheckin": "string",
      "TenLine": "string"
    }
  ]
}
```

## QR / Check-in

### `GET /getThongTinNguoiThamDu`
- Request:
```json
{
  "idSuKien": "string",
  "MaThamDu": "string"
}
```
- Response keys used in app:
```json
{
  "Status": 1,
  "MaThamDu": "string",
  "idNguoiThamDu": "string",
  "isCheckin": true,
  "ThoiDiemCheckin": "string",
  "SoLuotCheckinToiDa": 1,
  "DaCheckin": 0,
  "ChuaCheckin": 1,
  "TenTinhTrang": "string",
  "MaTinhTrang": "string",
  "TinhTrang": "string",
  "NgayCheckin": "string",
  "Field2": "string",
  "Field3": "string",
  "Field4": "string",
  "Field5": "string",
  "Field6": "string",
  "Field7": "string",
  "Field8": "string",
  "Field9": "string",
  "Field10": "string",
  "Field11": "string",
  "Field12": "string",
  "Field13": "string",
  "Field14": "string",
  "Field15": "string",
  "LichSuCheckin": [
    {
      "ThoiDiemCheckin": "string"
    }
  ]
}
```
- Failure response seen in code: `"Error"` or `{"Status": 0, "Messege": "..."}`

### `POST /checkin`
- Request:
```json
{
  "idSuKien": "string",
  "MaThamDu": "string",
  "idLineCheckin": "string | null"
}
```
- Response keys used in app:
```json
{
  "Status": 1,
  "Messege": "string",
  "Message": "string",
  "MaThamDu": "string",
  "idNguoiThamDu": "string",
  "isCheckin": true,
  "ThoiDiemCheckin": "string",
  "DaCheckin": 1,
  "ChuaCheckin": 0,
  "SoLuotCheckinToiDa": 1,
  "Field2": "string",
  "Field3": "string",
  "Field4": "string",
  "Field5": "string",
  "Field6": "string",
  "Field7": "string",
  "Field8": "string",
  "Field9": "string",
  "Field10": "string",
  "Field11": "string",
  "Field12": "string",
  "Field13": "string",
  "Field14": "string",
  "Field15": "string",
  "TenTinhTrang": "string",
  "MaTinhTrang": "string",
  "TinhTrang": "string",
  "NgayCheckin": "string",
  "LichSuCheckin": []
}
```

## History / Counts

### `GET /getDemSoLuotCheckin`
- Request:
```json
{
  "idSuKien": "string",
  "TinhTrang": 0
}
```
- Response:
```json
{
  "CountData": 0
}
```

### `GET /getDemSoNguoiThamDu`
- Request:
```json
{
  "idSuKien": "string",
  "MaTinhTrang": "string",
  "TuKhoa": "string"
}
```
- Response:
```json
{
  "SoNguoiThamDu": 0
}
```

### `GET /getListLichSuCheckin`
- Request:
```json
{
  "idSuKien": "string",
  "TuKhoa": "string",
  "Page": 1
}
```
- Response keys used in app:
```json
{
  "LLichSuCheckin": [
    {
      "MaThamDu": "string",
      "idNguoiThamDu": "string"
    }
  ]
}
```

### `GET /getListNguoiThamDu_1L`
- Request:
```json
{
  "idSuKien": "string",
  "MaTinhTrang": "string",
  "TuKhoa": "string",
  "Page": 1
}
```
- Response keys used in app:
```json
{
  "LNguoiThamDu": [
    {
      "MaThamDu": "string",
      "idNguoiThamDu": "string"
    }
  ]
}
```

### `GET /getTinhTrangCheckin`
- Request:
```json
{}
```
- Response:
```json
[
  {
    "MaTinhTrang": "string",
    "TenTinhTrang": "string"
  }
]
```

### `GET /getDemSoNguoiThamDu_1L`
- Request:
```json
{
  "idSuKien": "string",
  "TuKhoa": "",
  "MaTinhTrang": "string"
}
```
- Response:
```json
{
  "SoNguoiThamDu": 0
}
```

### `GET /getListNguoiThamDu`
- Request:
```json
{
  "idSuKien": "string",
  "MaTinhTrang": "string",
  "TuKhoa": "string",
  "Page": 1
}
```
- Response keys used in app:
```json
{
  "LNguoiThamDu": [
    {
      "MaThamDu": "string",
      "idNguoiThamDu": "string"
    }
  ]
}
```

## Statistics

### `GET /getThongKe_NL`
### `GET /getThongKe_1L`
- Request:
```json
{
  "idSuKien": "string"
}
```
- Response keys used in app:
```json
{
  "LThongke": [
    {
      "NhomThongKe": "string",
      "LThongKe": {
        "TongNguoiThamDu": 0,
        "DaCheckin": 0,
        "ChuaCheckin": 0,
        "DaCheckinXong": 0,
        "DangCheckin": 0,
        "ChuaTungCheckin": 0
      }
    }
  ]
}
```

## Runtime logging

All API calls are now logged from `ApiService` with these prefixes:
- `[API][REQUEST]`
- `[API][RESPONSE]`
- `[API][ERROR]`

Each log prints:
- HTTP method
- full URL
- request query/body
- response status
- response body

Sensitive values such as password, token, and `x-api-key` are masked.
