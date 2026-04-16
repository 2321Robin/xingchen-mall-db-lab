package com.example.server.review.dto;

import java.time.Instant;

public record PublicReviewResponse(
        Long id,
        String username,
        Integer rating,
        String content,
        Instant createdAt
) {
}
