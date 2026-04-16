package com.example.server.review;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.server.ResponseStatusException;

@RestControllerAdvice(assignableTypes = ReviewController.class)
class ReviewExceptionHandler {

    @ExceptionHandler(MethodArgumentNotValidException.class)
    ResponseEntity<Map<String, Object>> handleValidation(MethodArgumentNotValidException exception) {
        Map<String, Object> body = new HashMap<>();
        body.put("status", HttpStatus.BAD_REQUEST.value());
        FieldError fieldError = exception.getBindingResult().getFieldError();
        String message = fieldError != null ? fieldError.getDefaultMessage() : "请求参数不合法";
        body.put("message", message);
        return ResponseEntity.badRequest().body(body);
    }

    @ExceptionHandler(ReviewException.class)
    ResponseEntity<Map<String, Object>> handleReviewException(ReviewException exception) {
        Map<String, Object> body = new HashMap<>();
        body.put("status", HttpStatus.CONFLICT.value());
        body.put("message", exception.getMessage());
        return ResponseEntity.status(HttpStatus.CONFLICT).body(body);
    }

    @ExceptionHandler(ResponseStatusException.class)
    ResponseEntity<Map<String, Object>> handleResponseStatus(ResponseStatusException exception) {
        Map<String, Object> body = new HashMap<>();
        body.put("status", exception.getStatusCode().value());
        body.put("message", exception.getReason());
        return ResponseEntity.status(exception.getStatusCode()).body(body);
    }
}
