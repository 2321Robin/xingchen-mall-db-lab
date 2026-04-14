package com.example.server.cart.dto;

import java.math.BigDecimal;
import java.util.List;

public record CartSummaryResponse(
        List<CartItemResponse> items,
        int totalItems,
        int totalQuantity,
        BigDecimal totalAmount
) {
}
