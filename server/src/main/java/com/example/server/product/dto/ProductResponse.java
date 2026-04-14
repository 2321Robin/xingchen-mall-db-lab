package com.example.server.product.dto;

import java.math.BigDecimal;
import java.time.Instant;

import com.example.server.product.ProductStatus;

public record ProductResponse(
        Long id,
        String name,
        String sku,
        String category,
        BigDecimal price,
        Integer stock,
        ProductStatus status,
        Instant createdAt,
        Instant updatedAt
) {
}
