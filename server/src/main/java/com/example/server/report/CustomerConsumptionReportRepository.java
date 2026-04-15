package com.example.server.report;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.Instant;
import java.time.OffsetDateTime;
import java.util.List;

import org.springframework.stereotype.Repository;

import jakarta.persistence.EntityManager;

@Repository
public class CustomerConsumptionReportRepository {

    private static final String CUSTOMER_CONSUMPTION_SQL = """
            SELECT
                u.id AS user_id,
                u.username,
                COUNT(DISTINCT o.id) AS order_count,
                COALESCE(SUM(oi.quantity), 0) AS total_items,
                COALESCE(pay.total_paid_amount, 0) AS total_paid_amount,
                pay.last_paid_at,
                favorite.favorite_category,
                favorite.category_buy_count
            FROM user_accounts u
            JOIN orders o ON o.user_id = u.id
            JOIN order_items oi ON oi.order_id = o.id
            LEFT JOIN (
                SELECT
                    o.user_id,
                    SUM(pr.amount) AS total_paid_amount,
                    MAX(pr.paid_at) AS last_paid_at
                FROM orders o
                JOIN payment_records pr ON pr.order_id = o.id
                WHERE pr.payment_status = 'SUCCESS'
                GROUP BY o.user_id
            ) pay ON pay.user_id = u.id
            LEFT JOIN (
                SELECT user_id, favorite_category, category_buy_count
                FROM (
                    SELECT
                        o.user_id,
                        p.category AS favorite_category,
                        SUM(oi.quantity) AS category_buy_count,
                        ROW_NUMBER() OVER (
                            PARTITION BY o.user_id
                            ORDER BY SUM(oi.quantity) DESC, p.category ASC
                        ) AS category_rank
                    FROM orders o
                    JOIN order_items oi ON oi.order_id = o.id
                    JOIN products p ON p.id = oi.product_id
                    GROUP BY o.user_id, p.category
                ) ranked_categories
                WHERE category_rank = 1
            ) favorite ON favorite.user_id = u.id
            GROUP BY
                u.id,
                u.username,
                pay.total_paid_amount,
                pay.last_paid_at,
                favorite.favorite_category,
                favorite.category_buy_count
            ORDER BY total_paid_amount DESC, u.id ASC
            """;

    private final EntityManager entityManager;

    public CustomerConsumptionReportRepository(EntityManager entityManager) {
        this.entityManager = entityManager;
    }

    public List<CustomerConsumptionReportRow> fetchCustomerConsumptionReport() {
        @SuppressWarnings("unchecked")
        List<Object[]> rows = entityManager.createNativeQuery(CUSTOMER_CONSUMPTION_SQL).getResultList();

        return rows.stream()
                .map(this::mapRow)
                .toList();
    }

    private CustomerConsumptionReportRow mapRow(Object[] row) {
        return new CustomerConsumptionReportRow(
                toLong(row[0]),
                (String) row[1],
                toLong(row[2]),
                toLong(row[3]),
                (BigDecimal) row[4],
                toInstant(row[5]),
                (String) row[6],
                toLong(row[7]));
    }

    private Long toLong(Object value) {
        return value == null ? null : ((Number) value).longValue();
    }

    private Instant toInstant(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Instant instant) {
            return instant;
        }
        if (value instanceof OffsetDateTime offsetDateTime) {
            return offsetDateTime.toInstant();
        }
        return ((Timestamp) value).toInstant();
    }
}
