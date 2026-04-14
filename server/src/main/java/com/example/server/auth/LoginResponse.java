package com.example.server.auth;

import com.example.server.user.UserRole;

public record LoginResponse(
        Long userId,
        String username,
        UserRole role,
        String email,
        String message
) {
}
