package com.example.server.report;

import java.math.BigDecimal;
import java.time.Instant;

public record CustomerConsumptionReportRow(
        Long userId,
        String username,
        Long orderCount,
        Long totalItems,
        BigDecimal totalPaidAmount,
        Instant lastPaidAt,
        String favoriteCategory,
        Long categoryBuyCount) {
}
