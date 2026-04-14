package com.example.server.order.dto;

import java.math.BigDecimal;

public record OrderItemResponse(
        Long id,
        String productName,
        String productSku,
        Integer quantity,
        BigDecimal unitPrice
) {
}
