package com.example.server.user.address.dto;

import java.time.Instant;

public record UserAddressResponse(
        Long id,
        String recipientName,
        String phone,
        String province,
        String city,
        String district,
        String street,
        String postalCode,
        boolean isDefault,
        Instant createdAt,
        Instant updatedAt
) {
}
