package vehicle.booking.controller;

import vehicle.booking.dto.request.ChangePasswordRequest;
import vehicle.booking.dto.request.UpdateProfileRequest;
import vehicle.booking.dto.response.ApiResponse;
import vehicle.booking.dto.response.UserResponse;
import vehicle.booking.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/user")
public class UserController {

    @Autowired
    private UserService userService;

    @PostMapping("/change-password")
    public ResponseEntity<ApiResponse<String>> changePassword(
            @RequestBody ChangePasswordRequest request,
            Authentication authentication) {
        String phone = authentication.getName();
        userService.changePassword(phone, request);
        return ResponseEntity.ok(new ApiResponse<>(true, "Đổi mật khẩu thành công", null));
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> getCurrentUser(Authentication authentication) {
        String phone = authentication.getName();
        UserResponse response = userService.getCurrentUser(phone);
        return ResponseEntity.ok(new ApiResponse<>(true, "Lấy thông tin cá nhân thành công", response));
    }

    @PutMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> updateProfile(
            @RequestBody UpdateProfileRequest request,
            Authentication authentication) {
        String phone = authentication.getName();
        UserResponse response = userService.updateProfile(phone, request);
        return ResponseEntity.ok(new ApiResponse<>(true, "Cập nhật thông tin thành công", response));
    }
}