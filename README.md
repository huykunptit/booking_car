# Hệ thống đặt xe

> Nền tảng đặt và thuê xe full-stack gồm **Spring Boot backend** và **Vue 3 frontend**, hỗ trợ đầy đủ luồng tìm xe, đặt xe, hóa đơn, thanh toán và quản trị.

## 1. Giới thiệu dự án

**Vehicle Booking System** là dự án mô phỏng hệ thống đặt xe trực tuyến trong thực tế. Mục tiêu của dự án là xây dựng một nền tảng có quy trình nghiệp vụ rõ ràng, tách biệt frontend/backend, có xác thực bảo mật, phân quyền người dùng và dễ mở rộng thêm các tính năng trong tương lai.

Hệ thống cho phép người dùng tìm kiếm xe theo nhiều tiêu chí, kiểm tra tình trạng xe, tạo booking, theo dõi hóa đơn và thanh toán. Bên cạnh đó, quản trị viên có thể quản lý xe, ảnh xe, booking, invoice và xác nhận thanh toán để đồng bộ trạng thái toàn hệ thống.

## 2. Mục tiêu chính

- Số hóa quy trình thuê xe từ tìm kiếm đến thanh toán
- Xây dựng hệ thống REST API có phân quyền rõ ràng
- Tổ chức mã nguồn theo hướng dễ bảo trì và mở rộng
- Tách biệt giao diện người dùng và xử lý nghiệp vụ
- Cung cấp nền tảng phù hợp cho đồ án, demo sản phẩm hoặc phát triển tiếp thành dự án thực tế

## 3. Đối tượng sử dụng

### Người dùng

- Đăng ký, đăng nhập và quản lý hồ sơ cá nhân
- Tìm kiếm và xem chi tiết xe
- Tạo, theo dõi và hủy booking
- Xem danh sách invoice và payment của cá nhân

### Quản trị viên

- Quản lý danh sách xe và thông tin xe
- Quản lý hình ảnh xe
- Theo dõi, hủy hoặc xử lý booking
- Xem invoice, payment
- Xác nhận thanh toán để cập nhật trạng thái booking và xe

## 4. Kiến trúc hệ thống

Dự án được chia làm 2 phần độc lập:

### Backend

Backend chịu trách nhiệm:

- Cung cấp REST API
- Xử lý nghiệp vụ
- Xác thực JWT và phân quyền
- Quản lý dữ liệu xe, booking, invoice, payment
- Tích hợp dịch vụ ngoài như email, Cloudinary, Twilio

### Frontend

Frontend chịu trách nhiệm:

- Hiển thị giao diện người dùng
- Gọi API tới backend
- Quản lý state đăng nhập và dữ liệu hiển thị
- Cung cấp trải nghiệm sử dụng cho người dùng và admin

## 5. Công nghệ sử dụng

### Backend - Công nghệ

- Java 17
- Spring Boot 3
- Spring Security
- JWT Authentication
- Spring Data JPA
- MySQL
- Flyway Migration
- Spring Mail
- Swagger / OpenAPI
- Bucket4j Rate Limiting
- Cloudinary
- Twilio
- Gradle

### Frontend - Công nghệ

- Vue 3
- Vite
- Vue Router
- Pinia
- Axios
- Tailwind CSS
- ESLint

## 6. Chức năng nổi bật

### Xác thực và người dùng

- Đăng ký tài khoản
- Đăng nhập, refresh token, đăng xuất
- Xem và cập nhật hồ sơ cá nhân
- Đổi mật khẩu
- Phân quyền `USER` và `ADMIN`

### Quản lý xe

- Danh sách xe công khai
- Tìm kiếm theo hãng, tên, địa điểm
- Lọc theo hộp số, nhiên liệu, số ghế, giá
- Xem chi tiết xe
- Kiểm tra tình trạng khả dụng theo thời gian
- Quản lý nhiều ảnh cho một xe

### Booking, invoice, payment

- Tạo booking thuê xe
- Kiểm tra trùng lịch trước khi đặt
- Tự động sinh invoice khi booking được tạo
- Theo dõi trạng thái booking / invoice / payment
- Hủy booking theo điều kiện nghiệp vụ
- Tự động expire booking chờ thanh toán
- Admin xác nhận thanh toán để cập nhật trạng thái liên quan

### Bảo mật và vận hành

- JWT stateless authentication
- Role-based access control
- Rate limit cho `/api/auth/login` và `/api/auth/register`
- Global exception handling
- Swagger UI cho tài liệu API
- Actuator và structured logging cho monitoring

## 7. Luồng nghiệp vụ chính

1. Người dùng đăng ký hoặc đăng nhập.
2. Người dùng tìm xe phù hợp và kiểm tra thời gian khả dụng.
3. Người dùng tạo booking.
4. Hệ thống sinh invoice và giữ xe ở trạng thái chờ xử lý.
5. Admin xác nhận thanh toán.
6. Hệ thống cập nhật payment, invoice, booking và trạng thái xe.

## 8. API chính

Một số nhóm endpoint tiêu biểu:

| Nhóm | Endpoint tiêu biểu | Vai trò |
| ---- | ------------------ | ------- |
| Authentication | `/api/auth/register`, `/api/auth/login`, `/api/auth/refresh` | Public |
| User | `/api/user/me`, `/api/user/change-password` | USER |
| Car | `/api/cars`, `/api/cars/{id}`, `/api/cars/{id}/availability` | Public |
| Admin Car | `/api/admin/cars`, `/api/admin/cars/{id}` | ADMIN |
| Booking | `/api/bookings`, `/api/bookings/my-bookings` | USER |
| Invoice | `/api/invoices/my-invoices`, `/api/invoices/{id}` | USER |
| Payment | `/api/payments/my-payments`, `/api/payments/{id}` | USER |
| Admin Payment | `/api/admin/payments/confirm/{invoiceId}` | ADMIN |

> Xem tài liệu API chi tiết hơn trong `backend/README.md` hoặc Swagger UI khi chạy backend.

## 9. Cơ sở dữ liệu

Dựa trên luồng nghiệp vụ hiện tại, hệ thống xoay quanh các thực thể chính:

- `User`: thông tin tài khoản và phân quyền
- `Car`: thông tin xe, giá thuê, trạng thái
- `CarImage`: danh sách ảnh của xe
- `Booking`: thông tin đặt xe, thời gian thuê, trạng thái
- `Invoice`: hóa đơn phát sinh từ booking
- `Payment`: thông tin thanh toán cho invoice
- `RefreshToken` hoặc thực thể tương đương cho cơ chế đăng nhập duy trì phiên

Quan hệ dữ liệu cơ bản:

- Một `User` có thể có nhiều `Booking`
- Một `Car` có thể có nhiều `CarImage`
- Một `Booking` gắn với một `User` và một `Car`
- Một `Booking` sinh ra một `Invoice`
- Một `Invoice` liên kết với một `Payment`

Migration database được quản lý bằng **Flyway**, giúp kiểm soát phiên bản schema rõ ràng hơn.

## 10. Cấu trúc thư mục

```text
vehicle-booking-system/
├── backend/   # REST API xây dựng bằng Spring Boot
└── frontend/  # Ứng dụng giao diện người dùng bằng Vue 3 + Vite
```

## 11. Giao diện minh họa

Bạn có thể bổ sung ảnh chụp màn hình vào thư mục như sau:

```text
docs/
└── screenshots/
```

Các ảnh nên thêm:

- Trang chủ
- Trang danh sách xe
- Trang chi tiết xe
- Trang đăng nhập / đăng ký
- Trang booking của tôi
- Trang quản trị

Ví dụ markdown khi thêm ảnh:

```md
![Trang chủ](docs/screenshots/home.png)
![Danh sách xe](docs/screenshots/browse.png)
```

## 12. Hướng dẫn chạy dự án

### Chạy backend

```bash
cd backend
./gradlew bootRun
```

### Chạy frontend

```bash
cd frontend
npm install
npm run dev
```

## 13. Cấu hình cần chuẩn bị

Để chạy đầy đủ hệ thống, backend cần bổ sung cấu hình cho:

- Kết nối cơ sở dữ liệu MySQL
- JWT secret và thời gian hết hạn token
- Cấu hình email
- Cloudinary
- Twilio
- Các biến môi trường liên quan khác

## 14. Định hướng mở rộng

Dự án có thể tiếp tục phát triển thêm các hướng sau:

- Thanh toán online qua cổng thanh toán thực tế
- Dashboard thống kê cho admin
- Thông báo thời gian thực
- Đánh giá xe sau khi hoàn tất booking
- Quản lý chủ xe hoặc mô hình marketplace

## 15. Đưa dự án lên repository mới

Git hiện tại đã có thể được xóa để kết nối với repository mới. Sau đó chạy:

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin <repo-moi>
git push -u origin main
```

## 16. Tài liệu liên quan

- `backend/README.md`: mô tả chi tiết API backend và nghiệp vụ
- `frontend/src/`: mã nguồn giao diện người dùng
- `backend/src/main/resources/`: cấu hình và tài nguyên backend
