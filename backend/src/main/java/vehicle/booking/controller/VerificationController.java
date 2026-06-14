package vehicle.booking.controller;

import vehicle.booking.dto.response.ApiResponse;
import vehicle.booking.entity.User;
import vehicle.booking.entity.UserVerification;
import vehicle.booking.entity.enums.VerificationStatus;
import vehicle.booking.exception.AppException;
import vehicle.booking.exception.ErrorCode;
import vehicle.booking.repository.UserRepository;
import vehicle.booking.repository.UserVerificationRepository;
import vehicle.booking.service.ViettelAiService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/verification")
@RequiredArgsConstructor
public class VerificationController {

    private final UserRepository userRepository;
    private final UserVerificationRepository verificationRepository;
    private final ViettelAiService viettelAiService;

    @GetMapping("/status")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getStatus(
            @AuthenticationPrincipal UserDetails userDetails) {
        User user = getUser(userDetails);
        UserVerification v = verificationRepository.findByUserUserId(user.getUserId())
                .orElse(null);
        if (v == null) {
            return ResponseEntity.ok(new ApiResponse<>(true, "Chưa xác minh",
                    Map.of("status", "UNVERIFIED", "cccdVerified", false, "licenseVerified", false)));
        }
        return ResponseEntity.ok(new ApiResponse<>(true, "Lấy trạng thái thành công", Map.of(
                "status", v.getStatus(),
                "cccdVerified", Boolean.TRUE.equals(v.getCccdVerified()),
                "cccdSpoofed", Boolean.TRUE.equals(v.getCccdSpoofed()),
                "licenseVerified", Boolean.TRUE.equals(v.getLicenseVerified()),
                "licenseSpoofed", Boolean.TRUE.equals(v.getLicenseSpoofed()),
                "fullName", v.getFullName() != null ? v.getFullName() : "",
                "cccdNumber", v.getCccdNumber() != null ? v.getCccdNumber() : "",
                "birthDay", v.getBirthDay() != null ? v.getBirthDay() : "",
                "licenseClass", v.getLicenseClass() != null ? v.getLicenseClass() : ""
        )));
    }

    @PostMapping("/cccd")
    public ResponseEntity<ApiResponse<Map<String, Object>>> verifyCccd(
            @RequestParam("image") MultipartFile image,
            @AuthenticationPrincipal UserDetails userDetails) {
        User user = getUser(userDetails);

        // 1. Spoof check
        Map<String, Object> spoofResult = viettelAiService.spoofCheck(image);
        boolean isSpoofed = false;
        if (spoofResult.get("data") instanceof Map<?,?> sd) {
            Object spoofVal = sd.get("is_fake");
            if (spoofVal == null) spoofVal = sd.get("is_spoof");
            isSpoofed = Boolean.TRUE.equals(spoofVal);
        }

        // 2. OCR
        Map<String, Object> ocrResult = viettelAiService.ocrIdCard(image);
        boolean ocrOk = Integer.valueOf(200).equals(ocrResult.get("code"));

        UserVerification v = verificationRepository.findByUserUserId(user.getUserId())
                .orElseGet(() -> { UserVerification nv = new UserVerification(); nv.setUser(user); return nv; });

        v.setCccdSpoofed(isSpoofed);

        if (ocrOk && ocrResult.get("data") instanceof Map<?,?> d) {
            v.setCccdNumber(str(d, "id"));
            v.setFullName(str(d, "name"));
            v.setBirthDay(str(d, "birth_day"));
            v.setAddress(str(d, "home"));
            v.setIssueDate(str(d, "issue_date"));
            v.setExpiry(str(d, "expiry"));
            v.setCccdVerified(true);
        } else {
            v.setCccdVerified(false);
        }

        updateOverallStatus(v);
        verificationRepository.save(v);

        return ResponseEntity.ok(new ApiResponse<>(true,
                ocrOk ? "Xác minh CCCD thành công" : "Không nhận dạng được ảnh CCCD",
                Map.of("ocrSuccess", ocrOk, "isSpoofed", isSpoofed,
                       "name", v.getFullName() != null ? v.getFullName() : "",
                       "id", v.getCccdNumber() != null ? v.getCccdNumber() : "")));
    }

    @PostMapping("/license")
    public ResponseEntity<ApiResponse<Map<String, Object>>> verifyLicense(
            @RequestParam("image") MultipartFile image,
            @AuthenticationPrincipal UserDetails userDetails) {
        User user = getUser(userDetails);

        Map<String, Object> spoofResult = viettelAiService.spoofCheck(image);
        boolean isSpoofed = false;
        if (spoofResult.get("data") instanceof Map<?,?> sd) {
            Object spoofVal = sd.get("is_fake");
            if (spoofVal == null) spoofVal = sd.get("is_spoof");
            isSpoofed = Boolean.TRUE.equals(spoofVal);
        }

        Map<String, Object> ocrResult = viettelAiService.ocrIdCard(image);
        boolean ocrOk = Integer.valueOf(200).equals(ocrResult.get("code"));

        UserVerification v = verificationRepository.findByUserUserId(user.getUserId())
                .orElseGet(() -> { UserVerification nv = new UserVerification(); nv.setUser(user); return nv; });

        v.setLicenseSpoofed(isSpoofed);

        if (ocrOk && ocrResult.get("data") instanceof Map<?,?> d) {
            v.setLicenseNumber(str(d, "id"));
            v.setLicenseName(str(d, "name"));
            v.setLicenseExpiry(str(d, "expiry"));
            v.setLicenseClass(str(d, "type"));
            v.setLicenseVerified(true);
        } else {
            v.setLicenseVerified(false);
        }

        updateOverallStatus(v);
        verificationRepository.save(v);

        return ResponseEntity.ok(new ApiResponse<>(true,
                ocrOk ? "Xác minh bằng lái thành công" : "Không nhận dạng được ảnh bằng lái",
                Map.of("ocrSuccess", ocrOk, "isSpoofed", isSpoofed,
                       "licenseNumber", v.getLicenseNumber() != null ? v.getLicenseNumber() : "",
                       "licenseClass", v.getLicenseClass() != null ? v.getLicenseClass() : "")));
    }

    private User getUser(UserDetails ud) {
        return userRepository.findByPhone(ud.getUsername())
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));
    }

    private String str(Map<?,?> map, String key) {
        Object val = map.get(key);
        return val != null ? val.toString() : null;
    }

    private void updateOverallStatus(UserVerification v) {
        boolean cccdOk = Boolean.TRUE.equals(v.getCccdVerified()) && !Boolean.TRUE.equals(v.getCccdSpoofed());
        boolean licOk  = Boolean.TRUE.equals(v.getLicenseVerified()) && !Boolean.TRUE.equals(v.getLicenseSpoofed());
        if (cccdOk && licOk) v.setStatus(VerificationStatus.VERIFIED);
        else if (Boolean.TRUE.equals(v.getCccdSpoofed()) || Boolean.TRUE.equals(v.getLicenseSpoofed()))
            v.setStatus(VerificationStatus.REJECTED);
        else if (Boolean.TRUE.equals(v.getCccdVerified()) || Boolean.TRUE.equals(v.getLicenseVerified()))
            v.setStatus(VerificationStatus.PENDING);
        else v.setStatus(VerificationStatus.UNVERIFIED);
    }
}
