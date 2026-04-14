package com.example.server.product;

import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

class ProductValidationException extends ResponseStatusException {

    ProductValidationException(String reason) {
        super(HttpStatus.BAD_REQUEST, reason);
    }
}
