package vehicle.booking.dto.response;

import java.math.BigDecimal;

import vehicle.booking.entity.enums.CarStatus;

public record CarSummaryResponse(
        Long id,
        String name,
        String brand,
        String licensePlate,
        BigDecimal pricePerDay,
        CarStatus status,
        String imageUrl,
        Integer seats,
        String location,
        Double averageRating,
        Long reviewCount
) {
}
