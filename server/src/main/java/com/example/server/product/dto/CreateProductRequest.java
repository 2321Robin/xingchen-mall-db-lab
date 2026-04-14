package com.example.server.product.dto;

import java.math.BigDecimal;

import com.example.server.product.ProductStatus;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;

public record CreateProductRequest(
        @NotBlank(message = "商品名称不能为空")
        @Size(max = 120, message = "商品名称长度不能超过 120 字")
        String name,

        @NotBlank(message = "商品 SKU 不能为空")
        @Size(max = 64, message = "商品 SKU 长度不能超过 64 字")
        String sku,

        @NotBlank(message = "商品分类不能为空")
        @Size(max = 60, message = "商品分类长度不能超过 60 字")
        String category,

        @NotNull(message = "商品售价不能为空")
        @DecimalMin(value = "0.00", inclusive = false, message = "商品售价必须大于 0")
        BigDecimal price,

        @NotNull(message = "库存不能为空")
        @PositiveOrZero(message = "库存不能为负数")
        Integer stock,

        @NotNull(message = "商品状态不能为空")
        ProductStatus status
) {
}
