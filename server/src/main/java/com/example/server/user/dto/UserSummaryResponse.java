package com.example.server.user.dto;

import java.time.Instant;

import com.example.server.user.UserRole;

public record UserSummaryResponse(
        Long id,
        String username,
        String email,
        String phone,
        UserRole role,
        boolean active,
        Instant createdAt,
        Instant updatedAt
) {
}
