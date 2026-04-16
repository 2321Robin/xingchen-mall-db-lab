package com.example.server.review.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CreateReviewRequest(
        @NotNull(message = "用户 ID 不能为空")
        Long userId,
        @NotNull(message = "订单商品 ID 不能为空")
        Long orderItemId,
        @NotNull(message = "评分不能为空")
        @Min(value = 1, message = "评分必须在 1-5 分之间")
        @Max(value = 5, message = "评分必须在 1-5 分之间")
        Integer rating,
        @Size(max = 500, message = "评价内容不能超过 500 字")
        String content
) {
}
