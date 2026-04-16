package com.example.server.review;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface ReviewRepository extends JpaRepository<Review, Long> {

    boolean existsByOrderItemId(Long orderItemId);

    Optional<Review> findByOrderItemId(Long orderItemId);

    Optional<Review> findByOrderItemIdAndUserId(Long orderItemId, Long userId);

    Optional<Review> findFirstByUserIdAndProductIdOrderByCreatedAtDescIdDesc(Long userId, Long productId);

    List<Review> findByProductIdOrderByCreatedAtDesc(Long productId);

    List<Review> findAllByOrderByCreatedAtDesc();
}
