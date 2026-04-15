package com.example.server.order;

import java.util.List;

import com.example.server.order.dto.OrderItemResponse;
import com.example.server.order.dto.OrderResponse;

final class OrderMapper {

    private OrderMapper() {
    }

    static OrderResponse toResponse(CustomerOrder order) {
        return toResponse(order, null);
    }

    static OrderResponse toResponse(CustomerOrder order, OrderPaymentSummary paymentSummary) {
        List<OrderItemResponse> items = order.getItems().stream()
                .map(item -> new OrderItemResponse(
                        item.getId(),
                        item.getProductName(),
                        item.getProductSku(),
                        item.getQuantity(),
                        item.getUnitPrice()
                ))
                .toList();

        return new OrderResponse(
                order.getId(),
                order.getOrderNumber(),
                order.getUser().getId(),
                order.getUser().getUsername(),
                order.getTotalAmount(),
                order.getStatus(),
                order.getCreatedAt(),
                order.getUpdatedAt(),
                order.getShippingAddressId(),
                order.getShippingRecipient(),
                order.getShippingPhone(),
                order.getShippingProvince(),
                order.getShippingCity(),
                order.getShippingDistrict(),
                order.getShippingStreet(),
                order.getShippingPostalCode(),
                items,
                paymentSummary != null ? paymentSummary.paymentStatus() : null,
                paymentSummary != null ? paymentSummary.paymentMethod() : null,
                paymentSummary != null ? paymentSummary.paidAt() : null
        );
    }
}
