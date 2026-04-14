package com.example.server.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ForgotPasswordRequest(
        @NotBlank(message = "请输入账号或邮箱")
        String identifier,

        @NotBlank(message = "请输入邮箱地址")
        @Email(message = "请输入正确的邮箱地址")
        String email,

        @NotBlank(message = "请输入新密码")
        @Size(min = 6, max = 64, message = "密码长度需在 6-64 位之间")
        String newPassword
) {
}
