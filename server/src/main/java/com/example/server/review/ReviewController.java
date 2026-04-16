package com.example.server.review;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.example.server.review.dto.CreateReviewRequest;
import com.example.server.review.dto.PublicReviewResponse;
import com.example.server.review.dto.ReviewResponse;

import jakarta.validation.Valid;

@RestController
@RequestMapping
public class ReviewController {

    private final ReviewService reviewService;

    public ReviewController(ReviewService reviewService) {
        this.reviewService = reviewService;
    }

    @PostMapping("/api/user/reviews/{userId}")
    @ResponseStatus(HttpStatus.CREATED)
    public ReviewResponse createReview(@PathVariable Long userId, @Valid @RequestBody CreateReviewRequest request) {
        return reviewService.createReview(userId, request);
    }

    @GetMapping("/api/user/reviews/{userId}/order-item/{orderItemId}")
    public ReviewResponse getUserReviewByOrderItem(@PathVariable Long userId, @PathVariable Long orderItemId) {
        return reviewService.getUserReviewByOrderItem(userId, orderItemId);
    }

    @GetMapping("/api/products/{productId}/reviews")
    public List<PublicReviewResponse> listProductReviews(@PathVariable Long productId) {
        return reviewService.listProductReviews(productId);
    }

    @GetMapping("/api/admin/reviews")
    public List<ReviewResponse> listAdminReviews() {
        return reviewService.listAdminReviews();
    }
}
