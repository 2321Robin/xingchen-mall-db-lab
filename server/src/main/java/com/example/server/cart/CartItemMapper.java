package com.example.server.cart;

import java.math.BigDecimal;

import com.example.server.cart.dto.CartItemResponse;
import com.example.server.product.Product;

final class CartItemMapper {

    private CartItemMapper() {
    }

    static CartItemResponse toResponse(CartItem cartItem) {
        Product product = cartItem.getProduct();
        BigDecimal price = product.getPrice();
        Integer quantity = cartItem.getQuantity();
        BigDecimal subtotal = price.multiply(BigDecimal.valueOf(quantity.longValue()));

        return new CartItemResponse(
                cartItem.getId(),
                product.getId(),
                product.getName(),
                product.getSku(),
                product.getCategory(),
                price,
                quantity,
                product.getStock(),
                product.getStatus(),
                subtotal,
                cartItem.getCreatedAt(),
                cartItem.getUpdatedAt()
        );
    }
}
