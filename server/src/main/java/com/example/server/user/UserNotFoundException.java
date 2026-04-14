package com.example.server.user;

import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

class UserNotFoundException extends ResponseStatusException {

    UserNotFoundException(Long id) {
        super(HttpStatus.NOT_FOUND, "未找到用户，ID=" + id);
    }
}
