package com.example.server.order;

import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

class OrderNotFoundException extends ResponseStatusException {

    OrderNotFoundException(Long id) {
        super(HttpStatus.NOT_FOUND, "未找到订单，ID=" + id);
    }
}
