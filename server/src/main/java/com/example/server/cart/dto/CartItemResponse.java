package com.example.server.cart.dto;

import java.math.BigDecimal;
import java.time.Instant;

import com.example.server.product.ProductStatus;

public record CartItemResponse(
        Long id,
        Long productId,
        String productName,
        String productSku,
        String category,
        BigDecimal price,
        Integer quantity,
        Integer stock,
        ProductStatus status,
        BigDecimal subtotal,
        Instant createdAt,
        Instant updatedAt
) {
}
