package com.example.server.user.dto;

import jakarta.validation.constraints.NotNull;

public record UpdateUserStatusRequest(
        @NotNull(message = "状态不能为空")
        Boolean active
) {
}
