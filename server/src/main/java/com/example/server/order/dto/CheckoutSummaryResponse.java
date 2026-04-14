package com.example.server.order.dto;

import java.util.List;

import com.example.server.cart.dto.CartSummaryResponse;
import com.example.server.user.address.dto.UserAddressResponse;

public record CheckoutSummaryResponse(
        CartSummaryResponse cart,
        List<UserAddressResponse> addresses,
        Long selectedAddressId
) {
}
