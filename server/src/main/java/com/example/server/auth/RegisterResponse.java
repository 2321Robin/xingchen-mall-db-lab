package com.example.server.auth;

public record RegisterResponse(
        Long userId,
        String username,
        String message
) {
}
