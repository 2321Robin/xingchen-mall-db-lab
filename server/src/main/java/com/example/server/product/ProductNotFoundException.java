package com.example.server.product;

import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

class ProductNotFoundException extends ResponseStatusException {

    ProductNotFoundException(Long id) {
        super(HttpStatus.NOT_FOUND, "未找到商品，ID=" + id);
    }
}
