package com.example.server.order.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

import com.example.server.order.OrderStatus;

public record OrderResponse(
        Long id,
        String orderNumber,
        Long userId,
        String username,
        BigDecimal totalAmount,
        OrderStatus status,
        Instant createdAt,
        Instant updatedAt,
        Long shippingAddressId,
        String shippingRecipient,
        String shippingPhone,
        String shippingProvince,
        String shippingCity,
        String shippingDistrict,
        String shippingStreet,
        String shippingPostalCode,
        List<OrderItemResponse> items
) {
}
