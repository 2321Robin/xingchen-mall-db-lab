package com.example.server.order;

import java.time.Instant;

import com.example.server.payment.PaymentRecord;

public record OrderPaymentSummary(String paymentStatus, String paymentMethod, Instant paidAt) {

    public static OrderPaymentSummary from(PaymentRecord paymentRecord) {
        return new OrderPaymentSummary(
                paymentRecord.getPaymentStatus() != null ? paymentRecord.getPaymentStatus().name() : null,
                paymentRecord.getPaymentMethod() != null ? paymentRecord.getPaymentMethod().name() : null,
                paymentRecord.getPaidAt()
        );
    }
}
