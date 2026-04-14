package com.example.server.order.dto;

import java.math.BigDecimal;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;

public record UpdateOrderPriceRequest(
        @NotNull(message = "订单金额不能为空")
        @DecimalMin(value = "0.00", inclusive = false, message = "订单金额必须大于 0")
        BigDecimal totalAmount
) {
}
