package com.example.server.user.address.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record UpdateUserAddressRequest(
        @NotBlank(message = "请输入收货人姓名")
        @Size(max = 64, message = "收货人姓名长度不能超过 64 字符")
        String recipientName,

        @NotBlank(message = "请输入收货人手机号")
        @Pattern(regexp = "^1[3-9]\\d{9}$", message = "请输入 11 位中国大陆手机号")
        String phone,

        @NotBlank(message = "请选择省份")
        @Size(max = 64, message = "省份名称长度不能超过 64 字符")
        String province,

        @NotBlank(message = "请选择城市")
        @Size(max = 64, message = "城市名称长度不能超过 64 字符")
        String city,

        @NotBlank(message = "请输入区县")
        @Size(max = 64, message = "区县名称长度不能超过 64 字符")
        String district,

        @NotBlank(message = "请输入详细地址")
        @Size(max = 128, message = "详细地址长度不能超过 128 字符")
        String street,

        @Size(max = 16, message = "邮政编码长度不能超过 16 字符")
        String postalCode,

        boolean isDefault
) {
}
