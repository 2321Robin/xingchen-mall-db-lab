package com.example.server.order.dto;

import com.example.server.order.OrderStatus;

import jakarta.validation.constraints.NotNull;

public record UpdateOrderStatusRequest(
        @NotNull(message = "订单状态不能为空")
        OrderStatus status
) {
}
