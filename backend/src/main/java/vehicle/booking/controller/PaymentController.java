package vehicle.booking.controller;

import vehicle.booking.config.VNPayConfig;
import vehicle.booking.dto.response.ApiResponse;
import vehicle.booking.entity.Booking;
import vehicle.booking.entity.enums.BookingStatus;
import vehicle.booking.repository.BookingRepository;
import vehicle.booking.service.VNPayService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.Map;

@RestController
@RequestMapping("/api/payments/vnpay")
@RequiredArgsConstructor
public class PaymentController {

    private final VNPayService vnPayService;
    private final BookingRepository bookingRepository;
    private final VNPayConfig vnPayConfig;

    @PostMapping("/create/{bookingId}")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<String>> createPaymentUrl(@PathVariable Long bookingId, HttpServletRequest request) {
        String paymentUrl = vnPayService.createPaymentUrl(bookingId, request);
        return ResponseEntity.ok(new ApiResponse<>(true, "Tạo URL thanh toán thành công", paymentUrl));
    }

    @GetMapping("/return")
    public void paymentReturn(@RequestParam Map<String, String> params, HttpServletResponse response) throws IOException {
        String frontendRedirectUrl = vnPayConfig.getVnpFrontendUrl();
        
        if (vnPayService.verifyPayment(params)) {
            String vnp_ResponseCode = params.get("vnp_ResponseCode");
            String vnp_TxnRef = params.get("vnp_TxnRef");
            
            // Extract bookingId from vnp_TxnRef (format: bookingId_timestamp)
            Long bookingId = Long.parseLong(vnp_TxnRef.split("_")[0]);
            
            if ("00".equals(vnp_ResponseCode)) {
                // Payment success
                Booking booking = bookingRepository.findById(bookingId).orElse(null);
                if (booking != null && booking.getStatus() == BookingStatus.PENDING) {
                    booking.setStatus(BookingStatus.CONFIRMED);
                    // In a real system, you would also update Payment status here
                    bookingRepository.save(booking);
                }
                response.sendRedirect(frontendRedirectUrl + "?payment=success");
                return;
            } else {
                // Payment failed
                response.sendRedirect(frontendRedirectUrl + "?payment=failed");
                return;
            }
        }
        
        // Invalid signature
        response.sendRedirect(frontendRedirectUrl + "?payment=error");
    }
}
