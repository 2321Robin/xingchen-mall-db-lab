package com.example.server.review;

import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.Instant;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import com.example.server.review.dto.CreateReviewRequest;
import com.example.server.review.dto.ReviewResponse;

@WebMvcTest(ReviewController.class)
@Import(ReviewExceptionHandler.class)
class ReviewControllerTests {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private ReviewService reviewService;

    @Test
    void createReviewUsesUserIdPathVariable() throws Exception {
        when(reviewService.createReview(eq(7L), argThat((CreateReviewRequest request) ->
                request.orderItemId().equals(11L)
                        && request.rating().equals(5)
                        && request.content().equals("商品很好"))))
                .thenReturn(reviewResponse());

        mockMvc.perform(post("/api/user/reviews/7")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "orderItemId": 11,
                                  "rating": 5,
                                  "content": "商品很好"
                                }
                                """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.userId").value(7))
                .andExpect(jsonPath("$.orderItemId").value(11))
                .andExpect(jsonPath("$.rating").value(5));

        verify(reviewService).createReview(eq(7L), argThat((CreateReviewRequest request) ->
                request.orderItemId().equals(11L)
                        && request.rating().equals(5)
                        && request.content().equals("商品很好")));
    }

    @Test
    void getUserReviewByOrderItemUsesPathVariables() throws Exception {
        when(reviewService.getUserReviewByOrderItem(7L, 11L)).thenReturn(reviewResponse());

        mockMvc.perform(get("/api/user/reviews/7/order-item/11"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.userId").value(7))
                .andExpect(jsonPath("$.orderItemId").value(11));

        verify(reviewService).getUserReviewByOrderItem(7L, 11L);
    }

    @Test
    void createReviewReturnsConflictBodyForDuplicateReview() throws Exception {
        when(reviewService.createReview(eq(7L), argThat((CreateReviewRequest request) -> true)))
                .thenThrow(new ReviewException("该订单商品已评价"));

        mockMvc.perform(post("/api/user/reviews/7")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "orderItemId": 11,
                                  "rating": 5,
                                  "content": "重复评价"
                                }
                                """))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.status").value(409))
                .andExpect(jsonPath("$.message").value("该订单商品已评价"));
    }

    @Test
    void createReviewReturnsValidationErrorBody() throws Exception {
        mockMvc.perform(post("/api/user/reviews/7")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "rating": 5,
                                  "content": "缺少订单商品"
                                }
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.status").value(400))
                .andExpect(jsonPath("$.message").value("订单商品 ID 不能为空"));
    }

    private ReviewResponse reviewResponse() {
        Instant now = Instant.parse("2026-04-16T08:00:00Z");
        return new ReviewResponse(
                1L,
                7L,
                "review-user",
                5L,
                "测试商品",
                11L,
                "ORDER-001",
                5,
                "商品很好",
                now,
                now);
    }
}
