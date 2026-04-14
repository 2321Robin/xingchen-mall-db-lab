package com.example.server.cart.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record AddCartItemRequest(
        @NotNull(message = "商品 ID 不能为空")
        Long productId,

        @NotNull(message = "数量不能为空")
        @Min(value = 1, message = "数量必须大于 0")
        Integer quantity
) {
}
