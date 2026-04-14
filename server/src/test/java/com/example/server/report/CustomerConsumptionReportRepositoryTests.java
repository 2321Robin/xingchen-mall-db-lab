package com.example.server.report;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.math.BigDecimal;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.test.context.TestPropertySource;

import com.example.server.order.CustomerOrder;
import com.example.server.order.OrderItem;
import com.example.server.order.OrderStatus;
import com.example.server.product.Product;
import com.example.server.product.ProductStatus;
import com.example.server.review.Review;
import com.example.server.review.ReviewRepository;
import com.example.server.user.UserAccount;
import com.example.server.user.UserRole;

@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.ANY)
@TestPropertySource(properties = {
        "spring.sql.init.mode=never",
        "spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.H2Dialect"
})
class CustomerConsumptionReportRepositoryTests {

    @Autowired
    private ReviewRepository reviewRepository;

    @Autowired
    private TestEntityManager entityManager;

    @Test
    void reviewPersistsWhenReferencesMatchOrderItem() {
        ReviewFixture fixture = createFixture();
        Review review = createReview(fixture);

        Review saved = reviewRepository.saveAndFlush(review);

        assertThat(saved.getId()).isNotNull();
        assertThat(saved.getUserId()).isEqualTo(fixture.user().getId());
        assertThat(saved.getProductId()).isEqualTo(fixture.product().getId());
        assertThat(saved.getOrderItemId()).isEqualTo(fixture.orderItem().getId());
        assertThat(saved.getCreatedAt()).isNotNull();
        assertThat(saved.getUpdatedAt()).isNotNull();
    }

    @Test
    void reviewRejectsDuplicateOrderItem() {
        ReviewFixture fixture = createFixture();
        reviewRepository.saveAndFlush(createReview(fixture));

        assertThatThrownBy(() -> reviewRepository.saveAndFlush(createReview(fixture)))
                .isInstanceOf(DataIntegrityViolationException.class);
    }

    @Test
    void reviewRejectsOutOfRangeRating() {
        ReviewFixture fixture = createFixture();
        Review review = createReview(fixture);
        review.setRating(6);

        assertThatThrownBy(() -> reviewRepository.saveAndFlush(review))
                .isInstanceOf(DataIntegrityViolationException.class);
    }

    @Test
    void reviewRejectsMismatchedUserAndProductForOrderItem() {
        ReviewFixture fixture = createFixture();
        UserAccount anotherUser = createUser("review-user-2", "review-user-2@example.com", "13900000012");
        Product anotherProduct = createProduct("REVIEW-SKU-2");

        Review review = createReview(fixture);
        review.setUserId(anotherUser.getId());
        review.setUser(anotherUser);
        review.setProductId(anotherProduct.getId());
        review.setProduct(anotherProduct);

        assertThatThrownBy(() -> reviewRepository.saveAndFlush(review))
                .hasRootCauseInstanceOf(IllegalStateException.class)
                .hasMessageContaining("order item");
    }

    private Review createReview(ReviewFixture fixture) {
        Review review = new Review();
        review.setUserId(fixture.user().getId());
        review.setUser(fixture.user());
        review.setProductId(fixture.product().getId());
        review.setProduct(fixture.product());
        review.setOrderItemId(fixture.orderItem().getId());
        review.setOrderItem(fixture.orderItem());
        review.setRating(5);
        review.setContent("商品质量很好");

        return review;
    }

    private ReviewFixture createFixture() {
        UserAccount user = createUser("review-user-1", "review-user-1@example.com", "13900000011");
        Product product = createProduct("REVIEW-SKU-1");

        CustomerOrder order = new CustomerOrder();
        order.setOrderNumber("ORD-REVIEW-1");
        order.setUser(user);
        order.setStatus(OrderStatus.PAID);
        order.setTotalAmount(product.getPrice());
        entityManager.persist(order);

        OrderItem orderItem = new OrderItem();
        orderItem.setOrder(order);
        orderItem.setProductId(product.getId());
        orderItem.setProductName(product.getName());
        orderItem.setProductSku(product.getSku());
        orderItem.setQuantity(1);
        orderItem.setUnitPrice(product.getPrice());
        entityManager.persistAndFlush(orderItem);

        return new ReviewFixture(user, product, orderItem);
    }

    private UserAccount createUser(String username, String email, String phone) {
        UserAccount user = new UserAccount();
        user.setUsername(username);
        user.setPasswordHash("{noop}secret");
        user.setEmail(email);
        user.setPhone(phone);
        user.setRole(UserRole.CUSTOMER);
        user.setActive(true);
        entityManager.persist(user);
        return user;
    }

    private Product createProduct(String sku) {
        Product product = new Product();
        product.setName("测试商品-" + sku);
        product.setSku(sku);
        product.setCategory("测试分类");
        product.setPrice(new BigDecimal("99.00"));
        product.setStock(10);
        product.setStatus(ProductStatus.ACTIVE);
        entityManager.persist(product);
        return product;
    }

    private record ReviewFixture(UserAccount user, Product product, OrderItem orderItem) {
    }
}
