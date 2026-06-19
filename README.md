# GoRento — Hệ Thống Đặt & Thuê Xe Tự Lái

Ứng dụng mobile thuê xe tự lái GoRento, bao gồm **Spring Boot Backend API** và **Flutter Mobile App** (Android/iOS).

---

## Tính Năng

| Nhóm | Tính năng |
|------|-----------|
| **Auth** | Đăng nhập / Đăng ký bằng số điện thoại + OTP |
| **eKYC** | Xác minh CCCD, bằng lái, nhận diện khuôn mặt |
| **Tìm xe** | Tìm kiếm, lọc theo hãng / giá / vị trí |
| **Đặt xe** | Chọn ngày, chọn điểm đón/trả trên bản đồ |
| **Thanh toán** | Tích hợp VNPay sandbox |
| **Owner** | Quản lý xe, xem & duyệt booking, dashboard doanh thu |
| **Admin** | Quản lý user, xe, hóa đơn |
| **Bản đồ** | Goong Maps (geocoding + tile), định vị GPS thời gian thực |

---

## Tech Stack

**Backend**
- Java 21 · Spring Boot 3 · Spring Security + JWT
- MySQL + Flyway migration
- Cloudinary (ảnh xe) · VNPay (thanh toán) · ViettelAI eKYC
- Swagger UI: `/swagger-ui.html`

**Mobile**
- Flutter 3 · Riverpod · Dio · GoRouter
- flutter_map + Goong Maps
- Firebase Phone Auth (OTP) · flutter_secure_storage

---

## Cấu Trúc Thư Mục

```
vehicle-booking-system/
├── backend/          # Spring Boot API
│   └── src/main/resources/
│       ├── application-dev.properties          # (gitignored) cấu hình dev thực
│       └── application-dev.properties.example  # template cấu hình
└── flutter_app/      # Flutter mobile app
    ├── .env.json          # (gitignored) API keys mobile
    └── .env.json.example  # template env mobile
```

---

## Setup

### 1. Yêu Cầu

- Java 21+
- MySQL 8+
- Flutter 3.11+
- Android SDK (để chạy trên thiết bị Android)

### 2. Backend

**Bước 1 — Tạo database**

```sql
CREATE DATABASE vehicle_booking;
```

**Bước 2 — Cấu hình**

```bash
cd backend/src/main/resources
cp application-dev.properties.example application-dev.properties
# Điền các giá trị thực vào application-dev.properties
```

Các key cần thiết:

| Key | Mô tả | Lấy ở đâu |
|-----|-------|-----------|
| `spring.datasource.password` | Mật khẩu MySQL | Local |
| `spring.mail.password` | Gmail App Password | [myaccount.google.com](https://myaccount.google.com) → Bảo mật → App Passwords |
| `cloudinary.*` | Lưu trữ ảnh xe | [cloudinary.com](https://cloudinary.com) → Dashboard |
| `goong.api-key` | Geocoding / Autocomplete | [account.goong.io](https://account.goong.io) |
| `vnpay.tmn-code` + `vnpay.hash-secret` | Thanh toán sandbox | [sandbox.vnpayment.vn/devreg](https://sandbox.vnpayment.vn/devreg/) |
| `viettelai.token` | eKYC CCCD / bằng lái | [viettelai.vn](https://viettelai.vn) |
| `firebase.service-account-path` | Firebase Phone Auth | Firebase Console → Service Account |

**Bước 3 — Chạy**

```bash
cd backend
./gradlew bootRun
```

Backend lắng nghe tại `http://localhost:8080`.  
Swagger UI: `http://localhost:8080/swagger-ui.html`

---

### 3. Flutter App

**Bước 1 — Cấu hình env**

```bash
cd flutter_app
cp .env.json.example .env.json
# Điền key vào .env.json
```

Nội dung `.env.json`:

```json
{
  "BASE_URL": "http://YOUR_LOCAL_IP:8080",
  "GOONG_MAP_KEY": "your_goong_map_key",
  "GOONG_API_KEY": "your_goong_api_key"
}
```

> **Lưu ý thiết bị thật:** `BASE_URL` phải là IP máy tính trên cùng WiFi, không dùng `localhost`.  
> Lấy IP: `ipconfig getifaddr en0` (macOS) · Hoặc dùng [ngrok](https://ngrok.com) nếu router chặn traffic giữa thiết bị.

**Bước 2 — Cài dependencies**

```bash
flutter pub get
```

**Bước 3 — Chạy**

```bash
# Thiết bị thật
flutter run -d <device-id> --dart-define-from-file=.env.json

# Emulator Android (BASE_URL tự dùng 10.0.2.2)
flutter run --dart-define-from-file=.env.json
```

---

## Tài Khoản Demo

| Role | Số điện thoại | Mật khẩu |
|------|--------------|----------|
| ADMIN | `+84987654321` | `Password123!` |
| USER | `+84123456789` | `Password123!` |
| OWNER | `+84901234567` | `Password123!` |

> OTP đăng ký mặc định (mock mode): `123456`

---

## API Endpoints

| Method | Endpoint | Auth | Mô tả |
|--------|----------|------|-------|
| POST | `/api/auth/login` | — | Đăng nhập |
| POST | `/api/auth/register` | — | Đăng ký |
| POST | `/api/auth/refresh` | — | Refresh token |
| GET | `/api/cars` | — | Danh sách xe |
| GET | `/api/cars/{id}` | — | Chi tiết xe |
| GET | `/api/user/me` | USER | Thông tin cá nhân |
| GET/POST | `/api/bookings` | USER | Đặt xe / lịch sử |
| GET | `/api/invoices` | USER | Hóa đơn |
| POST | `/api/payments/vnpay/create` | USER | Tạo link thanh toán |
| GET/POST | `/api/verification/**` | USER | eKYC |
| GET/POST/PUT/DELETE | `/api/owner/**` | OWNER | Quản lý xe & booking |
| GET | `/api/admin/**` | ADMIN | Quản trị hệ thống |
| GET | `/api/geo/search` | — | Tìm kiếm địa điểm |
| GET | `/api/geo/place` | — | Chi tiết địa điểm (lat/lng) |
| GET | `/api/geo/reverse` | — | Reverse geocoding |

---

## Luồng Chính

```
Đăng ký ──► OTP (mock: 123456) ──► Đăng nhập
    │
    ▼
eKYC (CCCD + Bằng lái + Selfie)
    │
    ▼
Tìm xe ──► Chọn ngày & địa điểm ──► Đặt xe ──► Thanh toán VNPay
    │
    ▼
Owner nhận thông báo ──► Duyệt / Từ chối ──► Theo dõi hành trình
```

---

## Ghi Chú

- **Multipart file upload:** giới hạn 10MB/file, 20MB/request (cấu hình trong `application.properties`)
- **OTP mode:** mặc định `mock` (OTP = `123456`). Chuyển sang `firebase` hoặc `twilio` bằng cách đặt `twilio.mode=firebase|twilio` trong `application-dev.properties`
- **VNPay:** đang dùng sandbox, cần `tmn-code` + `hash-secret` thật từ VNPAY để test thanh toán
- **eKYC:** phụ thuộc ViettelAI API — xem [docs/eKYC_AI_Plan.md](docs/eKYC_AI_Plan.md) để biết phương án thay thế
