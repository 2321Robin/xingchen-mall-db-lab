package com.example.server.review.dto;

import java.time.Instant;

public record ReviewResponse(
        Long id,
        Long userId,
        String username,
        Long productId,
        String productName,
        Long orderItemId,
        String orderNumber,
        Integer rating,
        String content,
        Instant createdAt,
        Instant updatedAt
) {
}
