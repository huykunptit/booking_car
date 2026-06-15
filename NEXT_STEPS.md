# Next Steps — GoRento

> Cập nhật: 2026-06-13

---

## ✅ Đã hoàn thành

### 1. ~~Fix syntax error — `location_picker_dialog.dart`~~ ✅

**Đã fix:** Removed extra closing parenthesis `)` in `Stack` → `Expanded` structure. `flutter analyze` now shows **No issues found!**

---

### 2. ~~Fix `info` warnings trong Flutter analyze~~ ✅

**Đã fix tất cả:**
- `verification_screen.dart` — Added curly braces to if/else blocks
- `owner_bookings_screen.dart` — Changed `__` to `_`
- `owner_car_list_screen.dart` — Changed `__` to `_`
- `car_list_screen.dart` — Changed `(_, __, ___)` to `(_, _, _)`

---

## 🟢 Việc tiếp theo theo checklist RAG_AI.md

### 3. Seed Flyway cho DB hiện tại (Flyway checksum repair)

Mỗi khi **reset database** mới hoàn toàn, seed file `V20260508_0005` hiện dùng phone `+84987654321` (E.164) — chạy bình thường.  
Nếu dùng DB cũ đã migrate trước đó, chạy lệnh repair:

```bash
mysql -u root -proot vehicle_booking -e "
UPDATE flyway_schema_history
SET checksum = (SELECT checksum FROM flyway_schema_history WHERE version = '20260508.0005')
WHERE version = '20260508.0005';"
```

Hoặc thêm vào `application-dev.properties`:
```properties
spring.flyway.validate-on-migrate=false
```

---

### 4. ~~Cấu hình `image_picker` cho Android & iOS~~ ✅

**Đã thêm permissions:**
- **Android**: `READ_MEDIA_IMAGES` vào `AndroidManifest.xml`
- **iOS**: `NSPhotoLibraryUsageDescription` + `NSCameraUsageDescription` vào `Info.plist`

---

### 5. Test luồng eKYC end-to-end

Sau khi backend đang chạy (`./gradlew bootRun`):

```bash
# Lấy token USER
TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"0123456789","password":"Password123!"}' | \
  python3 -c "import sys,json; print(json.load(sys.stdin)['data']['token'])")

# Kiểm tra trạng thái xác minh
curl -s http://localhost:8080/api/verification/status \
  -H "Authorization: Bearer $TOKEN" | python3 -m json.tool

# Upload CCCD (thay path ảnh thực)
curl -s -X POST http://localhost:8080/api/verification/cccd \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@/path/to/cccd.jpg" | python3 -m json.tool
```

---

### 6. VietMap tiles — kiểm tra trên thiết bị thực

Token `93f3886be392ad743f665ac2200b40b7` có thể bị giới hạn domain/IP.  
Nếu bản đồ VietMap trả về `401`, app sẽ tự fallback sang **CartoDB Voyager** (đã cấu hình trong `location_picker_dialog.dart`).

Để test satellite VietMap:
```
https://maps.vietmap.vn/maps/tiles/st/14/12285/7622.png?apikey=93f3886be392ad743f665ac2200b40b7
```
Mở URL trên trong trình duyệt — nếu trả về ảnh tile = hoạt động, nếu `401` = cần whitelist domain.

---

### 7. Cập nhật seed SQL cho phone E.164 (đã làm — ghi lại để nhớ)

File `V20260508_0005__seed_initial_data.sql` đã dùng `+84987654321` và `+84123456789`.  
Nếu DB cũ có phone `0987654321`, chạy:
```sql
UPDATE users SET phone = '+84987654321' WHERE phone = '0987654321';
UPDATE users SET phone = '+84123456789' WHERE phone = '0123456789';
UPDATE users SET password = '$2a$10$moAvhjGMF/bmSSW486th8OA0sRQUse0jUGHX5ReeaktPOkkyZus1a'
  WHERE phone IN ('+84987654321', '+84123456789');
```

---

## 📋 Tổng trạng thái hệ thống

### Backend ✅ BUILD SUCCESSFUL

| Module | Endpoint | Trạng thái |
|--------|----------|------------|
| Auth | `POST /api/auth/login` | ✅ |
| Cars | `GET /api/cars` | ✅ |
| Bookings | `POST /api/bookings` + location fields | ✅ |
| Owner | `GET/POST/PUT/DELETE /api/owner/cars` | ✅ |
| Owner | `GET /api/owner/bookings` + confirm/reject | ✅ |
| Owner | `GET /api/owner/dashboard` | ✅ |
| eKYC | `GET /api/verification/status` | ✅ |
| eKYC | `POST /api/verification/cccd` | ✅ |
| eKYC | `POST /api/verification/license` | ✅ |

### Flutter — 1 error còn lại

| File | Trạng thái |
|------|------------|
| `dio_provider.dart` | ✅ dart:io removed, web-safe |
| `app_router.dart` | ✅ StatefulShellRoute (Bottom Nav) |
| `main_layout.dart` | ✅ Bottom Navigation Bar 5 tab |
| `verification_screen.dart` | ✅ Upload CCCD/GPLX + kết quả OCR |
| `owner_dashboard_screen.dart` | ✅ |
| `owner_car_list/form/bookings` | ✅ |
| `geocoding_service.dart` | ✅ VietMap API |
| `location_picker_dialog.dart` | ❌ 1 syntax error (xem mục 1) |

---

## 🔮 Backlog (chưa lên kế hoạch)

- [ ] **OTP thật**: Tích hợp eSMS.vn / SpeedSMS / Firebase Phone Auth thay Twilio mock
- [ ] **Admin panel web**: Dashboard quản lý xe, booking, user cho ADMIN
- [ ] **Push notification**: Firebase FCM cho thông báo booking real-time  
- [ ] **VNPay production**: Chuyển từ sandbox sang production key
- [ ] **Review & Rating**: Màn hình viết đánh giá sau chuyến (FE đã có cơ bản)
- [ ] **AI RAG quy định pháp luật**: Dùng Gemini + vector DB để xác minh điều kiện thuê theo hạng bằng lái
