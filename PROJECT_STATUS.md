# GoRento — Trạng thái dự án & Hướng dẫn vận hành

> Cập nhật: 2026-06-17

---

## Mục lục

1. [Tổng quan hệ thống](#1-tổng-quan-hệ-thống)
2. [Tech Stack](#2-tech-stack)
3. [Tính năng hiện có](#3-tính-năng-hiện-có)
4. [Các vấn đề đang tồn tại & cách fix](#4-các-vấn-đề-đang-tồn-tại--cách-fix)
5. [Backlog chưa làm](#5-backlog-chưa-làm)
6. [Cách chạy project](#6-cách-chạy-project)
7. [Cấu hình API Keys](#7-cấu-hình-api-keys)

---

## 1. Tổng quan hệ thống

**GoRento** là hệ thống đặt thuê xe trực tuyến, gồm 3 thành phần:

| Thành phần | Công nghệ | Vai trò |
|---|---|---|
| `backend/` | Spring Boot 3.3.5 + Java 21 | REST API server |
| `frontend/` | Vue 3 + Vite + Tailwind CSS | Web app (admin/owner) |
| `flutter_app/` | Flutter + Riverpod | Mobile app (user/owner) |

**Database:** MySQL — migration tự động bằng Flyway (11 file migration).

---

## 2. Tech Stack

### Backend
- **Spring Boot 3.3.5** — Java 21, Gradle
- **Spring Security + JWT** (jjwt 0.12.6) — stateless authentication
- **Spring Data JPA + Hibernate + MySQL**
- **Flyway** — database migration
- **Bucket4j 8.10.1** — rate limiting theo IP
- **Cloudinary** — lưu trữ ảnh xe
- **Twilio 10.6.10** — SMS OTP (đang dùng mock)
- **Firebase Admin SDK 9.4.3** — xác thực số điện thoại
- **SpringDoc OpenAPI 2.3.0** — Swagger UI
- **Logstash Logback** — structured JSON logging

### Frontend (Vue 3)
- Vue 3.5.13 + Vue Router 4 + Pinia 2.3
- Axios 1.7.9 — HTTP client
- Tailwind CSS 3.4, Lucide icons

### Flutter (Mobile)
- Riverpod — state management
- GoRouter — navigation + deep linking
- Dio — HTTP client với dynamic base URL
- Flutter Secure Storage — lưu JWT
- Firebase Auth + Firebase Messaging
- VietMap satellite tiles (fallback: CartoDB Voyager)

---

## 3. Tính năng hiện có

### 3.1 Xác thực & Phân quyền ✅

| API | Mô tả |
|---|---|
| `POST /api/auth/register` | Đăng ký bằng số điện thoại + OTP |
| `POST /api/auth/login` | Đăng nhập, trả về access + refresh token |
| `POST /api/auth/refresh` | Làm mới access token |
| `POST /api/auth/logout` | Đăng xuất, thu hồi refresh token |
| `POST /api/auth/forgot-password` | Gửi OTP qua email để đặt lại mật khẩu |
| `POST /api/auth/reset-password` | Đặt lại mật khẩu bằng OTP |

- Access token: 15 phút | Refresh token: 7 ngày
- Phân quyền: **USER / OWNER / ADMIN**
- Rate limiting: 10 login/phút, 5 register/phút, 3 OTP/phút theo IP

### 3.2 Quản lý xe ✅

| API | Mô tả |
|---|---|
| `GET /api/cars` | Danh sách xe với bộ lọc (brand, giá, fuel, số ghế, vị trí...) |
| `GET /api/cars/{id}` | Chi tiết xe + ảnh |
| `GET /api/cars/{id}/availability` | Lịch xe còn trống |
| `GET /api/owner/cars` | Xe của chủ xe |
| `POST/PUT/DELETE /api/owner/cars` | CRUD xe (OWNER) |
| `GET/POST/PUT /api/admin/cars` | CRUD xe (ADMIN) |

- Upload ảnh xe lên Cloudinary
- Trạng thái xe: AVAILABLE / PENDING / BOOKED / MAINTENANCE / DISABLED

### 3.3 Đặt xe & Booking ✅

| API | Mô tả |
|---|---|
| `POST /api/bookings` | Tạo booking mới |
| `GET /api/bookings/my-bookings` | Lịch sử đặt xe (phân trang) |
| `GET /api/bookings/{id}` | Chi tiết booking |
| `PUT /api/bookings/{id}/cancel` | Hủy booking |
| `PUT /api/bookings/{id}/pickup-location` | Cập nhật tọa độ đón |
| `PUT /api/bookings/{id}/dropoff-location` | Cập nhật tọa độ trả |

- Flow: PENDING → CONFIRMED → IN_PROGRESS → COMPLETED / CANCELLED
- Booking PENDING tự động hết hạn sau **15 phút** nếu chưa thanh toán

### 3.4 Thanh toán VNPay ✅

| API | Mô tả |
|---|---|
| `POST /api/payments/vnpay/create/{bookingId}` | Tạo URL thanh toán VNPay |
| `GET /api/payments/vnpay/return` | Callback sau khi thanh toán |

- Đang dùng **VNPay sandbox**
- Chữ ký HMAC-SHA512
- Tham chiếu giao dịch: `bookingId_timestamp`
- Thanh toán hết hạn sau 15 phút

### 3.5 eKYC — Xác minh danh tính ✅

| API | Mô tả |
|---|---|
| `POST /api/verification/cccd` | OCR CCCD mặt trước + phát hiện giả mạo |
| `POST /api/verification/cccd/back` | OCR CCCD mặt sau |
| `POST /api/verification/license` | OCR Bằng lái mặt trước |
| `POST /api/verification/license/back` | OCR Bằng lái mặt sau |
| `POST /api/verification/face` | Liveness detection + face matching |
| `GET /api/verification/status` | Trạng thái xác minh của user |

- Provider: **ViettelAI**
- Face matching threshold: ≥ 0.75 similarity score
- Chống gian lận: spoof detection, liveness score
- Trạng thái: UNVERIFIED → PENDING → VERIFIED / REJECTED

### 3.6 Theo dõi GPS xe ✅

| API | Mô tả |
|---|---|
| `POST /api/tracking/update` | Cập nhật vị trí xe (GPS, tốc độ, hướng) |
| `GET /api/cars/{id}/tracking` | Vị trí hiện tại |
| `GET /api/cars/{id}/tracking/history` | Lịch sử vị trí |

### 3.7 Geocoding & Bản đồ ✅

| API | Mô tả |
|---|---|
| `GET /api/geo/geocode` | Địa chỉ → tọa độ |
| `GET /api/geo/reverse-geocode` | Tọa độ → địa chỉ |

- Provider: **Goong Maps API**

### 3.8 Owner Dashboard ✅

| API | Mô tả |
|---|---|
| `GET /api/owner/dashboard` | Doanh thu, xe đang thuê, đánh giá |
| `GET /api/owner/bookings` | Danh sách booking của xe mình |
| `PUT /api/owner/bookings/{id}/confirm` | Duyệt booking |
| `PUT /api/owner/bookings/{id}/reject` | Từ chối booking |

### 3.9 Admin Dashboard ✅

| API | Mô tả |
|---|---|
| `GET /api/admin/dashboard` | Thống kê toàn hệ thống |
| `GET /api/admin/users` | Quản lý user |
| `GET /api/admin/bookings` | Tất cả booking |
| `GET /api/admin/payments` | Theo dõi thanh toán |
| `GET /api/admin/invoices` | Quản lý hóa đơn |

### 3.10 Tính năng khác ✅

- **Đánh giá xe**: `POST /api/reviews` — 1-5 sao + bình luận
- **Thông báo**: `GET /api/notifications` — BOOKING_CREATED, PAYMENT_SUCCESS, v.v.
- **Hóa đơn**: `GET /api/invoices/{id}` — chi tiết hóa đơn
- **Đổi mật khẩu**: `PUT /api/user/me`, `POST /api/user/change-password`
- **Swagger UI**: `http://localhost:8080/swagger-ui.html`

---

## 4. Các vấn đề đang tồn tại & cách fix

### Vấn đề 1 — Flyway checksum mismatch (DB cũ)

**Triệu chứng:** App khởi động báo lỗi Flyway checksum không khớp, migration bị block.

**Nguyên nhân:** File seed `V20260508_0005` đã được sửa đổi sau khi migrate.

**Cách fix:**

```bash
# Cách 1: Thêm vào application-dev.properties (đơn giản nhất)
spring.flyway.validate-on-migrate=false

# Cách 2: Chạy repair trực tiếp trong MySQL
mysql -u root -p vehicle_booking -e "
  UPDATE flyway_schema_history
  SET checksum = NULL
  WHERE version = '20260508.0005';"
```

---

### Vấn đề 2 — Phone format không đúng E.164

**Triệu chứng:** Đăng nhập bằng `0987654321` thất bại, không tìm thấy user.

**Nguyên nhân:** Hệ thống lưu số điện thoại theo chuẩn E.164 (`+84987654321`).

**Cách fix (DB cũ):**

```sql
UPDATE users SET phone = '+84987654321' WHERE phone = '0987654321';
UPDATE users SET phone = '+84123456789' WHERE phone = '0123456789';
-- Cập nhật lại password hash nếu cần
UPDATE users
SET password = '$2a$10$moAvhjGMF/bmSSW486th8OA0sRQUse0jUGHX5ReeaktPOkkyZus1a'
WHERE phone IN ('+84987654321', '+84123456789');
```

**Tài khoản mặc định sau seed:**
| Phone | Password | Role |
|---|---|---|
| `+84987654321` | `Password123!` | ADMIN |
| `+84123456789` | `Password123!` | USER |

---

### Vấn đề 3 — VietMap tiles trả về 401

**Triệu chứng:** Bản đồ satellite trong Flutter app hiển thị ô trống hoặc lỗi.

**Nguyên nhân:** API key VietMap `93f3886be392ad743f665ac2200b40b7` có thể bị giới hạn domain/IP.

**Cách kiểm tra:**

```
Mở URL trong trình duyệt:
https://maps.vietmap.vn/maps/tiles/st/14/12285/7622.png?apikey=93f3886be392ad743f665ac2200b40b7

- Trả về ảnh tile → key đang hoạt động
- Trả về 401 → cần whitelist domain hoặc đổi key
```

**Cách fix:** App đã tự fallback sang **CartoDB Voyager** khi VietMap 401 — không cần xử lý thêm. Nếu muốn dùng VietMap, đăng ký key mới tại `https://vietmap.vn` và cập nhật trong `location_picker_dialog.dart`.

---

### Vấn đề 4 — OTP SMS đang dùng mock (Twilio mock mode)

**Triệu chứng:** OTP đăng ký luôn là `123456`, không gửi SMS thật.

**Nguyên nhân:** `twilio.mode=mock` trong config.

**Cách fix (nếu cần SMS thật):** Xem [mục 7.4 — Twilio](#74-twilio--sms-otp) để cấu hình Twilio thật.

---

### Vấn đề 5 — VNPay đang dùng sandbox

**Triệu chứng:** Thanh toán chỉ hoạt động với thẻ test VNPay.

**Thẻ test VNPay sandbox:**
```
Ngân hàng: NCB
Số thẻ: 9704198526191432198
Tên chủ thẻ: NGUYEN VAN A
Ngày phát hành: 07/15
OTP: 123456
```

**Cách chuyển production:** Thay `vnpay.pay-url` và cập nhật `tmn-code` + `hash-secret` từ VNPay production (liên hệ VNPay).

---

### Vấn đề 6 — Firebase service account chưa cấu hình

**Triệu chứng:** Backend khởi động lỗi `FileNotFoundException: firebase-service-account.json`.

**Cách fix:** Xem [mục 7.5 — Firebase](#75-firebase-admin-sdk).

---

### Vấn đề 7 — VNPay return URL cần HTTPS (ngrok)

**Triệu chứng:** VNPay không gọi được callback khi test local.

**Nguyên nhân:** VNPay yêu cầu return URL phải là HTTPS public.

**Cách fix:**

```bash
# Cài ngrok nếu chưa có
npm install -g ngrok

# Expose port 8080
ngrok http 8080

# Cập nhật application-dev.properties với URL ngrok mới
vnpay.return-url=https://abc123.ngrok.io/api/payments/vnpay/return
vnpay.frontend-url=https://abc123.ngrok.io/my-bookings
```

---

## 5. Backlog chưa làm

| # | Tính năng | Độ ưu tiên | Ghi chú |
|---|---|---|---|
| 1 | OTP SMS thật | Cao | Tích hợp eSMS.vn / SpeedSMS hoặc Firebase Phone Auth thay Twilio mock |
| 2 | Admin panel web UI | Cao | Backend API đã có đủ, cần làm giao diện Vue |
| 3 | Push notification FCM | Trung bình | Firebase Messaging đã tích hợp phía Flutter, backend cần gửi FCM token |
| 4 | VNPay production | Trung bình | Cần liên hệ VNPay để lấy TMN Code production |
| 5 | Màn hình đánh giá xe | Thấp | Frontend Flutter đã có cơ bản |
| 6 | AI RAG quy định pháp luật | Thấp | Dùng Gemini + vector DB để xác minh điều kiện thuê theo hạng bằng lái |

---

## 6. Cách chạy project

### 6.1 Yêu cầu hệ thống

| Công cụ | Phiên bản tối thiểu |
|---|---|
| Java | 21 |
| Gradle | Wrapper tự tải (không cần cài) |
| MySQL | 8.0+ |
| Node.js | 18+ |
| Flutter | 3.x (stable) |

---

### 6.2 Chạy Backend (Spring Boot)

**Bước 1 — Tạo database:**

```bash
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS vehicle_booking CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

**Bước 2 — Tạo file config:**

```bash
cd backend/src/main/resources
cp application-dev.properties.example application-dev.properties
# Sau đó sửa các giá trị YOUR_* trong file này (xem mục 7)
```

**Bước 3 — Chạy:**

```bash
cd backend

# Dev mode (hot reload)
./gradlew bootRun

# Hoặc build JAR rồi chạy
./gradlew bootJar -x test
java -jar build/libs/vehicle-booking-system-*.jar
```

**Kiểm tra:**
- API: `http://localhost:8080/api/cars`
- Swagger: `http://localhost:8080/swagger-ui.html`
- Health: `http://localhost:8080/actuator/health`

Flyway sẽ tự động chạy 11 migration và seed dữ liệu mẫu khi khởi động lần đầu.

---

### 6.3 Chạy Frontend (Vue 3)

```bash
cd frontend
npm install
npm run dev         # Dev server tại http://localhost:5173
npm run build       # Build production vào dist/
npm run preview     # Preview bản build
```

**Cấu hình API URL** (nếu backend không chạy ở localhost:8080):

```js
// frontend/src/api/axios.js hoặc vite.config.js
// Sửa baseURL hoặc proxy target
```

---

### 6.4 Chạy Flutter App

```bash
cd flutter_app

# Cài dependencies
flutter pub get

# Kiểm tra lỗi
flutter analyze

# Chạy trên emulator/thiết bị kết nối
flutter run

# Build APK
flutter build apk --release

# Build cho iOS
flutter build ios --release
```

**Đổi API base URL** (khi backend không phải localhost):

```dart
// flutter_app/lib/src/core/network/dio_provider.dart
// Sửa baseUrl thành IP máy chạy backend (VD: http://192.168.1.100:8080)
```

---

### 6.5 Chạy Tests

```bash
cd backend

# Chạy tất cả tests (dùng H2 in-memory, không cần MySQL)
./gradlew test

# Kết quả tại: build/reports/tests/test/index.html
```

---

## 7. Cấu hình API Keys

Tất cả keys được đặt trong file:

```
backend/src/main/resources/application-dev.properties
```

Tạo file này từ template:

```bash
cp backend/src/main/resources/application-dev.properties.example \
   backend/src/main/resources/application-dev.properties
```

---

### 7.1 MySQL — Password database local

```properties
spring.datasource.password=YOUR_MYSQL_PASSWORD
```

Không cần đăng ký gì. Điền đúng password MySQL đang chạy trên máy bạn.

Nếu chưa cài MySQL, cài bằng:
```bash
# Ubuntu/Debian
sudo apt install mysql-server
sudo mysql_secure_installation   # đặt password root tại đây
```

---

### 7.2 JWT Secret Key — Tự tạo, không cần đăng ký

```properties
jwt.secret-key=YOUR_BASE64_SECRET_KEY_MIN_32_BYTES
```

Chạy lệnh này trong terminal để tạo key ngẫu nhiên:

```bash
openssl rand -base64 32
```

Copy kết quả (dạng `abc123...==`) điền vào `jwt.secret-key`.

---

### 7.3 Gmail App Password — Gửi email OTP

```properties
spring.mail.username=your_email@gmail.com
spring.mail.password=xxxx xxxx xxxx xxxx
```

**Bước 1 — Bật xác minh 2 bước (bắt buộc):**
1. Truy cập: `https://myaccount.google.com/security`
2. Cuộn xuống mục **"Cách bạn đăng nhập vào Google"**
3. Click **"Xác minh 2 bước"** → làm theo hướng dẫn để bật

**Bước 2 — Tạo App Password:**
1. Truy cập: `https://myaccount.google.com/apppasswords`
   - (Hoặc vào `myaccount.google.com` → Bảo mật → cuộn xuống tìm **"Mật khẩu ứng dụng"**)
2. Ô **"Tên"** → gõ bất kỳ, ví dụ: `GoRento`
3. Click **"Tạo"**
4. Một ô màu vàng hiện ra chứa **16 ký tự** dạng `abcd efgh ijkl mnop`
5. Copy toàn bộ 16 ký tự đó (kể cả dấu cách hoặc không) → điền vào `spring.mail.password`

> App Password chỉ hiện 1 lần — lưu lại ngay. Mất thì tạo cái mới.

---

### 7.4 Firebase Admin SDK — Xác thực phone (backend)

```properties
firebase.service-account-path=classpath:firebase-service-account.json
```

**Bước 1 — Vào Firebase Console:**
1. Truy cập: `https://console.firebase.google.com`
2. Đăng nhập bằng tài khoản Google
3. Click **"Add project"** nếu chưa có project, hoặc chọn project hiện có

**Bước 2 — Tạo project (nếu chưa có):**
1. Nhập tên project, ví dụ: `gorento-booking`
2. Tắt Google Analytics (không cần thiết) → **"Create project"**
3. Chờ vài giây → **"Continue"**

**Bước 3 — Tải Service Account JSON:**
1. Trong project, click biểu tượng bánh răng ⚙️ cạnh **"Project Overview"** → **"Project settings"**
2. Chọn tab **"Service accounts"** (tab thứ 3)
3. Đảm bảo chọn **"Firebase Admin SDK"** ở panel trái
4. Click nút **"Generate new private key"** (màu xanh)
5. Popup cảnh báo → click **"Generate key"**
6. File JSON tự động tải về máy (tên dạng `gorento-booking-firebase-adminsdk-xxx.json`)

**Bước 4 — Đặt file vào đúng chỗ:**
```bash
# Đổi tên và copy vào resources
cp ~/Downloads/gorento-booking-firebase-adminsdk-*.json \
   backend/src/main/resources/firebase-service-account.json
```

> File đã có trong `.gitignore` — không bao giờ commit file này lên git.

**Bước 5 — Bật Phone Authentication (cho Flutter):**
1. Trong Firebase Console → **"Authentication"** (menu trái)
2. Tab **"Sign-in method"**
3. Click **"Phone"** → bật toggle → **"Save"**

---

### 7.5 Cloudinary — Lưu ảnh xe

```properties
cloudinary.cloud-name=YOUR_CLOUD_NAME
cloudinary.api-key=YOUR_CLOUDINARY_API_KEY
cloudinary.api-secret=YOUR_CLOUDINARY_API_SECRET
```

**Bước 1 — Đăng ký:**
1. Truy cập: `https://cloudinary.com/users/register_free`
2. Điền Email, First name, Last name → **"Create Account"**
3. Xác nhận email (kiểm tra hộp thư)

**Bước 2 — Lấy credentials:**
1. Sau khi đăng nhập, vào: `https://console.cloudinary.com`
2. Trang **Dashboard** hiện ngay 3 thứ cần lấy:
   - **Cloud Name** — dòng đầu tiên, dạng `dxxxxxxxx`
   - **API Key** — dãy số 15 chữ số
   - **API Secret** — click **"Reveal"** để xem, dạng chuỗi dài
3. Copy từng cái điền vào properties

Free tier: **25 GB storage** + **25 GB bandwidth/tháng** — đủ dùng.

---

### 7.6 Goong Maps — Geocoding (địa chỉ ↔ tọa độ)

```properties
goong.api-key=YOUR_GOONG_API_KEY
```

**Bước 1 — Đăng ký:**
1. Truy cập: `https://account.goong.io/register`
2. Điền thông tin → **"Đăng ký"**
3. Xác nhận email

**Bước 2 — Tạo API Key:**
1. Đăng nhập tại: `https://account.goong.io`
2. Menu trái → **"API Keys"**
3. Click **"+ Tạo API Key mới"** (hoặc **"Create new key"**)
4. Đặt tên: `gorento-dev` → **"Tạo"**
5. Key hiện ra dạng `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` (36 ký tự)
6. Copy → điền vào `goong.api-key`

Free tier: **100,000 request/tháng** — đủ dùng cho dev.

---

### 7.7 VNPay Sandbox — Thanh toán online

```properties
vnpay.tmn-code=XXXXXXXX
vnpay.hash-secret=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
vnpay.pay-url=https://sandbox.vnpayment.vn/paymentv2/vpcpay.html
vnpay.return-url=https://YOUR_NGROK_URL/api/payments/vnpay/return
vnpay.frontend-url=https://YOUR_NGROK_URL/my-bookings
```

**Bước 1 — Đăng ký tài khoản sandbox:**
1. Truy cập: `https://sandbox.vnpayment.vn/devreg/`
2. Điền form đăng ký:
   - Website: có thể điền `http://localhost:8080`
   - Tên doanh nghiệp: điền tên bất kỳ, ví dụ `GoRento Dev`
   - Email: email thật để nhận credentials
3. Click **"Đăng ký"**

**Bước 2 — Nhận credentials qua email:**
- VNPay sẽ gửi email chứa **TMN Code** và **Secure Hash Secret** trong vòng vài phút
- TMN Code: 8 ký tự in hoa, ví dụ `DEMO1234`
- Hash Secret: chuỗi dài ~32 ký tự

**Bước 3 — Cấu hình return URL (cần ngrok):**

VNPay yêu cầu return URL phải là HTTPS public, không dùng localhost được.

```bash
# Cài ngrok
snap install ngrok          # Ubuntu
# hoặc: brew install ngrok  # Mac

# Đăng ký miễn phí tại https://ngrok.com để lấy authtoken
ngrok config add-authtoken YOUR_NGROK_TOKEN

# Mỗi lần chạy backend, mở ngrok song song:
ngrok http 8080
# → Màn hình hiện: Forwarding  https://abc123.ngrok-free.app → http://localhost:8080
```

Lấy URL ngrok (dạng `https://abc123.ngrok-free.app`) điền vào:
```properties
vnpay.return-url=https://abc123.ngrok-free.app/api/payments/vnpay/return
vnpay.frontend-url=https://abc123.ngrok-free.app/my-bookings
```

> URL ngrok thay đổi mỗi lần restart (free plan) — cần cập nhật lại properties.

**Thẻ test VNPay sandbox (không trừ tiền thật):**
```
Ngân hàng:    NCB
Số thẻ:       9704198526191432198
Tên chủ thẻ:  NGUYEN VAN A
Ngày PH:      07/15
Mã OTP:       123456
```

---

### 7.8 Twilio Verify — SMS OTP (tùy chọn, mock mặc định)

> **Mặc định đang dùng mock** — OTP luôn là `123456`, không cần Twilio.  
> Chỉ cần thiết lập Twilio nếu muốn gửi SMS thật.

```properties
# Giữ nguyên dòng này để dùng mock (không cần key):
twilio.mode=mock
twilio.mock-otp=123456
```

Nếu muốn SMS thật:

```properties
twilio.mode=real
twilio.account-sid=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
twilio.auth-token=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
twilio.verify-service-sid=VAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

**Bước 1 — Đăng ký Twilio:**
1. Truy cập: `https://www.twilio.com/try-twilio`
2. Điền thông tin → **"Start your free trial"**
3. Xác minh số điện thoại của bạn (nhận SMS thật)
4. Chọn: Use case → **"Verify users with OTP"**

**Bước 2 — Lấy Account SID & Auth Token:**
1. Sau khi đăng nhập, vào: `https://console.twilio.com`
2. Trang **Dashboard** (trang chủ Console) hiện ngay:
   - **Account SID** — dạng `ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`
   - **Auth Token** — click **"Show"** để hiện, dạng chuỗi 32 ký tự
3. Copy cả hai

**Bước 3 — Tạo Verify Service (lấy Service SID):**
1. Menu trái → **"Verify"** → **"Services"**
   - Hoặc truy cập thẳng: `https://console.twilio.com/us1/develop/verify/services`
2. Click **"Create new"** (nút dấu `+`)
3. Điền **"Friendly name"**: `GoRento OTP`
4. Click **"Create"**
5. Trang Service vừa tạo hiện **Service SID** dạng `VAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`
6. Copy → điền vào `twilio.verify-service-sid`

Free trial: $15 credit, đủ gửi ~150 SMS.

---

### 7.9 ViettelAI — eKYC (tùy chọn)

```properties
viettelai.token=YOUR_VIETTELAI_TOKEN
```

ViettelAI là dịch vụ B2B — không có trang tự đăng ký online.

**Cách liên hệ:**
1. Truy cập: `https://viettelai.vn`
2. Click **"Liên hệ"** hoặc **"Dùng thử"**
3. Điền form liên hệ doanh nghiệp, mô tả use case (eKYC cho app thuê xe)
4. Bộ phận kinh doanh sẽ liên hệ lại qua email/điện thoại
5. Sau khi được cấp tài khoản, đăng nhập dashboard ViettelAI → lấy **Bearer Token**

> Nếu chưa có token, tính năng eKYC sẽ trả về lỗi 401 — các tính năng khác vẫn chạy bình thường.

---

### 7.10 Checklist — Thứ tự setup đề xuất

Làm theo thứ tự này để có thể chạy được app sớm nhất:

```
[ ] 1. MySQL      — local, điền password ngay
[ ] 2. JWT secret — chạy: openssl rand -base64 32
[ ] 3. Gmail      — myaccount.google.com/apppasswords
[ ] 4. Firebase   — console.firebase.google.com → tải JSON
[ ] 5. Cloudinary — cloudinary.com → Dashboard lấy 3 keys
[ ] 6. Goong      — account.goong.io → tạo API key
[ ] 7. VNPay      — sandbox.vnpayment.vn/devreg → nhận email
[ ] 8. Twilio     — (bỏ qua, dùng mock)
[ ] 9. ViettelAI  — (bỏ qua nếu không cần eKYC)
```

Sau khi xong 1-6, app đã chạy được hoàn toàn (không có payment và eKYC).  
Thêm 7 để test luồng thanh toán VNPay.

| Service | Bắt buộc | Free | Đăng ký ở đâu |
|---|---|---|---|
| MySQL | ✅ | ✅ | Local |
| JWT | ✅ | ✅ | Terminal (tự tạo) |
| Gmail | ✅ | ✅ | myaccount.google.com/apppasswords |
| Firebase | ✅ | ✅ | console.firebase.google.com |
| Cloudinary | ✅ | ✅ (25GB) | cloudinary.com/users/register_free |
| Goong Maps | ✅ | ✅ (100k/tháng) | account.goong.io/register |
| VNPay sandbox | ✅ (payment) | ✅ | sandbox.vnpayment.vn/devreg |
| Twilio | ❌ mock OK | Trial $15 | twilio.com/try-twilio |
| ViettelAI | ❌ eKYC only | ❌ B2B | viettelai.vn (liên hệ) |

---

## 8. Cấu trúc thư mục nhanh

```
booking_car/
├── backend/
│   ├── build.gradle                          # Dependencies
│   └── src/main/
│       ├── java/vehicle/booking/
│       │   ├── config/                       # Security, Firebase, VNPay, Cloudinary...
│       │   ├── controller/                   # 22 REST controllers
│       │   ├── service/                      # 21 business logic services
│       │   ├── entity/                       # 11 JPA entities
│       │   ├── repository/                   # 12 JPA repositories
│       │   ├── dto/                          # 38 request/response DTOs
│       │   ├── filter/                       # JWT + RateLimit + MDC filters
│       │   └── scheduler/                    # Booking expiration job
│       └── resources/
│           ├── application.properties        # Base config
│           ├── application-dev.properties    # Dev config (tạo từ .example)
│           ├── application-test.properties   # Test config (H2)
│           ├── firebase-service-account.json # Firebase key (không commit)
│           └── db/migration/                 # 11 Flyway SQL files
├── frontend/
│   ├── src/pages/                            # Vue pages
│   ├── src/store/                            # Pinia stores
│   ├── src/api/                              # Axios services
│   └── vite.config.js
├── flutter_app/
│   ├── lib/src/features/                     # Auth, Booking, Cars, Owner, Verification...
│   ├── lib/src/core/                         # Network, Router, Theme, Storage
│   └── pubspec.yaml
├── api-test-collection.json                  # Postman collection
├── NEXT_STEPS.md                             # Checklist dev
└── PROJECT_STATUS.md                         # File này
```
