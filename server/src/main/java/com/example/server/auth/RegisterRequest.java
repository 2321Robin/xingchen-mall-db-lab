package com.example.server.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record RegisterRequest(
        @NotBlank(message = "请输入账号昵称")
        @Size(min = 2, max = 64, message = "账号昵称长度需在 2-64 位之间")
        String username,

        @NotBlank(message = "请输入邮箱地址")
        @Email(message = "请输入正确的邮箱地址")
        String email,

        @NotBlank(message = "请输入手机号")
        @Pattern(regexp = "^1[3-9]\\d{9}$", message = "请输入 11 位中国大陆手机号")
        String phone,

        @NotBlank(message = "请输入密码")
        @Size(min = 6, max = 64, message = "密码长度需在 6-64 位之间")
        String password
) {
}
