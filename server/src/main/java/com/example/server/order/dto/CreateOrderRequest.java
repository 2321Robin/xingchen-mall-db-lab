package com.example.server.order.dto;

import jakarta.validation.constraints.NotNull;

public record CreateOrderRequest(@NotNull Long addressId) {
}
