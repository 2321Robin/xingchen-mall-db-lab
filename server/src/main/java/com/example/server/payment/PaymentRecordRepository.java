package com.example.server.payment;

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

    @Query("""
            select pr
            from PaymentRecord pr
            where pr.order.id in :orderIds
            order by case when pr.paidAt is null then 1 else 0 end,
                     pr.paidAt desc,
                     pr.createdAt desc,
                     pr.id desc
            """)
    List<PaymentRecord> findPaymentRecordsForOrderIdsOrdered(@Param("orderIds") Collection<Long> orderIds);

    default Map<Long, OrderPaymentSummary> findLatestPaymentSummariesByOrderIds(Collection<Long> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) {
            return Map.of();
        }

        Map<Long, OrderPaymentSummary> summaries = new LinkedHashMap<>();
        for (PaymentRecord record : findPaymentRecordsForOrderIdsOrdered(orderIds)) {
            Long orderId = record.getOrder().getId();
            summaries.putIfAbsent(orderId, OrderPaymentSummary.from(record));
        }
        return summaries;
    }
}
