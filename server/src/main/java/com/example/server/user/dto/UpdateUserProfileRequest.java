package com.example.server.user.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record UpdateUserProfileRequest(
        @NotBlank(message = "请输入昵称")
        @Size(min = 2, max = 64, message = "昵称长度需在 2-64 位之间")
        String username,

        @NotBlank(message = "请输入邮箱地址")
        @Email(message = "请输入正确的邮箱地址")
        String email,

        @Pattern(regexp = "^$|^1[3-9]\\d{9}$", message = "请输入 11 位中国大陆手机号或留空")
        String phone
) {
}
