package com.example.server.user.address;

import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

class UserAddressNotFoundException extends ResponseStatusException {

    UserAddressNotFoundException(Long addressId) {
        super(HttpStatus.NOT_FOUND, "未找到收货地址，ID=" + addressId);
    }
}
