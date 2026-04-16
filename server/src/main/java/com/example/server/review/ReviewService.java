package com.example.server.review;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import com.example.server.order.CustomerOrder;
import com.example.server.order.CustomerOrderRepository;
import com.example.server.order.OrderItem;
import com.example.server.order.OrderStatus;
import com.example.server.product.Product;
import com.example.server.product.ProductRepository;
import com.example.server.review.dto.CreateReviewRequest;
import com.example.server.review.dto.ReviewResponse;
import com.example.server.user.UserAccount;
import com.example.server.user.UserAccountRepository;

@Service
@Transactional(readOnly = true)
public class ReviewService {

    private final ReviewRepository reviewRepository;
    private final CustomerOrderRepository customerOrderRepository;
    private final ProductRepository productRepository;
    private final UserAccountRepository userAccountRepository;

    public ReviewService(
            ReviewRepository reviewRepository,
            CustomerOrderRepository customerOrderRepository,
            ProductRepository productRepository,
            UserAccountRepository userAccountRepository) {
        this.reviewRepository = reviewRepository;
        this.customerOrderRepository = customerOrderRepository;
        this.productRepository = productRepository;
        this.userAccountRepository = userAccountRepository;
    }

    @Transactional
    public ReviewResponse createReview(CreateReviewRequest request) {
        CustomerOrder order = customerOrderRepository.findByOrderItemId(request.orderItemId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "未找到订单商品"));
        OrderItem orderItem = order.getItems().stream()
                .filter(item -> item.getId().equals(request.orderItemId()))
                .findFirst()
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "未找到订单商品"));

        if (!order.getUser().getId().equals(request.userId())) {
            throw new ReviewException("只有购买者才能评价该商品");
        }
        if (order.getStatus() != OrderStatus.SHIPPED && order.getStatus() != OrderStatus.DELIVERED) {
            throw new ReviewException("当前订单状态不支持评价");
        }
        if (reviewRepository.existsByOrderItemId(orderItem.getId())) {
            throw new ReviewException("该订单商品已评价");
        }

        UserAccount user = userAccountRepository.findById(request.userId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "未找到用户"));
        Product product = productRepository.findById(orderItem.getProductId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "未找到商品"));

        Review review = new Review();
        review.setUserId(user.getId());
        review.setProductId(product.getId());
        review.setOrderItemId(orderItem.getId());
        review.setUser(user);
        review.setProduct(product);
        review.setOrderItem(orderItem);
        review.setRating(request.rating());
        review.setContent(normalizeContent(request.content()));

        return toResponse(reviewRepository.saveAndFlush(review));
    }

    public ReviewResponse getUserReviewByOrderItem(Long userId, Long orderItemId) {
        Review review = reviewRepository.findByOrderItemIdAndUserId(orderItemId, userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "未找到评价"));
        return toResponse(review);
    }

    public List<ReviewResponse> listProductReviews(Long productId) {
        return reviewRepository.findByProductIdOrderByCreatedAtDesc(productId).stream()
                .map(this::toResponse)
                .toList();
    }

    public List<ReviewResponse> listAdminReviews() {
        return reviewRepository.findAllByOrderByCreatedAtDesc().stream()
                .map(this::toResponse)
                .toList();
    }

    private String normalizeContent(String content) {
        if (content == null) {
            return null;
        }
        String trimmed = content.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private ReviewResponse toResponse(Review review) {
        return new ReviewResponse(
                review.getId(),
                review.getUserId(),
                review.getUser().getUsername(),
                review.getProductId(),
                review.getProduct().getName(),
                review.getOrderItemId(),
                review.getOrderItem().getOrder().getOrderNumber(),
                review.getRating(),
                review.getContent(),
                review.getCreatedAt(),
                review.getUpdatedAt());
    }
}
