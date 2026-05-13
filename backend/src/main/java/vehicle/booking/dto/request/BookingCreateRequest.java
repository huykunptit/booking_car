package vehicle.booking.dto.request;

import java.time.LocalDate;

public record BookingCreateRequest(
        Long carId,
        LocalDate startDate,
        LocalDate endDate
) {
}