package com.example.server.report;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.context.TestPropertySource;

import com.example.server.review.Review;
import com.example.server.review.ReviewRepository;

@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.ANY)
@TestPropertySource(properties = {
        "spring.sql.init.mode=never",
        "spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.H2Dialect"
})
class CustomerConsumptionReportRepositoryTests {

    @Autowired
    private ReviewRepository reviewRepository;

    @Test
    void reviewUsesUniqueOrderItemAndBoundedRating() {
        Review review = new Review();
        review.setUserId(2L);
        review.setProductId(1L);
        review.setOrderItemId(1L);
        review.setRating(5);
        review.setContent("商品质量很好");

        Review saved = reviewRepository.saveAndFlush(review);

        assertThat(saved.getId()).isNotNull();
        assertThat(saved.getCreatedAt()).isNotNull();
        assertThat(saved.getUpdatedAt()).isNotNull();
    }
}
