package com.example.server.order;

import java.util.Comparator;
import java.util.List;

import com.example.server.order.dto.OrderItemResponse;
import com.example.server.order.dto.OrderResponse;
import com.example.server.payment.PaymentRecord;

final class OrderMapper {

    private OrderMapper() {
    }

    static OrderResponse toResponse(CustomerOrder order) {
        List<OrderItemResponse> items = order.getItems().stream()
                .map(item -> new OrderItemResponse(
                        item.getId(),
                        item.getProductName(),
                        item.getProductSku(),
                        item.getQuantity(),
                        item.getUnitPrice()
                ))
                .toList();

        PaymentRecord latestPayment = order.getPaymentRecords().stream()
                .max(Comparator.comparing(
                        PaymentRecord::getPaidAt,
                        Comparator.nullsLast(Comparator.naturalOrder())
                ).thenComparing(
                        PaymentRecord::getCreatedAt,
                        Comparator.nullsLast(Comparator.naturalOrder())
                ).thenComparing(
                        PaymentRecord::getId,
                        Comparator.nullsLast(Comparator.naturalOrder())
                ))
                .orElse(null);

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
                latestPayment != null && latestPayment.getPaymentStatus() != null ? latestPayment.getPaymentStatus().name() : null,
                latestPayment != null && latestPayment.getPaymentMethod() != null ? latestPayment.getPaymentMethod().name() : null,
                latestPayment != null ? latestPayment.getPaidAt() : null
        );
    }
}
