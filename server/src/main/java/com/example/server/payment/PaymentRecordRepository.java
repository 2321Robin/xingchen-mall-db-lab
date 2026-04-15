package com.example.server.payment;

import java.time.Instant;
import java.time.OffsetDateTime;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.example.server.order.OrderPaymentSummary;

public interface PaymentRecordRepository extends JpaRepository<PaymentRecord, Long> {

    Optional<PaymentRecord> findTopByOrderIdOrderByCreatedAtDesc(Long orderId);

    @Query(value = """
            select latest.order_id as orderId,
                   latest.payment_status as paymentStatus,
                   latest.payment_method as paymentMethod,
                   latest.paid_at as paidAt
            from (
                select pr.order_id,
                       pr.payment_status,
                       pr.payment_method,
                       pr.paid_at,
                       row_number() over (
                           partition by pr.order_id
                           order by case when pr.paid_at is null then 1 else 0 end,
                                    pr.paid_at desc,
                                    pr.created_at desc,
                                    pr.id desc
                       ) as rn
                from payment_records pr
                where pr.order_id in (:orderIds)
            ) latest
            where latest.rn = 1
            """, nativeQuery = true)
    List<LatestPaymentSummaryRow> findLatestPaymentSummaryRowsByOrderIds(@Param("orderIds") Collection<Long> orderIds);

    default Map<Long, OrderPaymentSummary> findLatestPaymentSummariesByOrderIds(Collection<Long> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) {
            return Map.of();
        }

        Map<Long, OrderPaymentSummary> summaries = new LinkedHashMap<>();
        for (LatestPaymentSummaryRow row : findLatestPaymentSummaryRowsByOrderIds(orderIds)) {
            summaries.put(
                    row.getOrderId(),
                    new OrderPaymentSummary(
                            row.getPaymentStatus(),
                            row.getPaymentMethod(),
                            row.getPaidAt() != null ? row.getPaidAt().toInstant() : null
                    )
            );
        }
        return summaries;
    }

    interface LatestPaymentSummaryRow {
        Long getOrderId();

        String getPaymentStatus();

        String getPaymentMethod();

        OffsetDateTime getPaidAt();
    }
}
