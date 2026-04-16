package com.example.server.review;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.TestPropertySource;

import com.example.server.order.CustomerOrder;
import com.example.server.order.CustomerOrderRepository;
import com.example.server.order.OrderItem;
import com.example.server.order.OrderStatus;
import com.example.server.product.Product;
import com.example.server.product.ProductRepository;
import com.example.server.product.ProductStatus;
import com.example.server.review.dto.CreateReviewRequest;
import com.example.server.review.dto.ReviewResponse;
import com.example.server.user.UserAccount;
import com.example.server.user.UserAccountRepository;
import com.example.server.user.UserRole;

@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.ANY)
@Import(ReviewService.class)
@TestPropertySource(properties = {
        "spring.sql.init.mode=never",
        "spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.H2Dialect"
})
class ReviewServiceTests {

    @Autowired
    private ReviewService reviewService;

    @Autowired
    private ReviewRepository reviewRepository;

    @Autowired
    private TestEntityManager entityManager;

    @Test
    void createReviewAllowsShippedOrderItem() {
        ReviewFixture fixture = createFixture(OrderStatus.SHIPPED, "REVIEW-SHIP-001", "review-ship-user");

        ReviewResponse response = reviewService.createReview(fixture.user().getId(), new CreateReviewRequest(
                fixture.orderItem().getId(),
                5,
                "物流很快，商品也很好"));

        assertThat(response.userId()).isEqualTo(fixture.user().getId());
        assertThat(response.orderItemId()).isEqualTo(fixture.orderItem().getId());
        assertThat(response.productId()).isEqualTo(fixture.product().getId());
        assertThat(response.rating()).isEqualTo(5);
        assertThat(response.content()).isEqualTo("物流很快，商品也很好");
        assertThat(reviewRepository.findByOrderItemId(fixture.orderItem().getId())).isPresent();
    }

    @Test
    void createReviewRejectsDuplicateOrderItemReview() {
        ReviewFixture fixture = createFixture(OrderStatus.DELIVERED, "REVIEW-DUP-001", "review-dup-user");
        reviewService.createReview(fixture.user().getId(), new CreateReviewRequest(
                fixture.orderItem().getId(),
                4,
                "第一次评价"));

        assertThatThrownBy(() -> reviewService.createReview(fixture.user().getId(), new CreateReviewRequest(
                fixture.orderItem().getId(),
                5,
                "重复评价")))
                .isInstanceOf(ReviewException.class)
                .hasMessage("该订单商品已评价");
    }

    @Test
    void createReviewRejectsWrongUser() {
        ReviewFixture fixture = createFixture(OrderStatus.SHIPPED, "REVIEW-USER-001", "review-right-user");
        UserAccount otherUser = createUser("review-other-user", "review-other-user@example.com", "13900000072");
        entityManager.flush();

        assertThatThrownBy(() -> reviewService.createReview(otherUser.getId(), new CreateReviewRequest(
                fixture.orderItem().getId(),
                3,
                "不是购买者")))
                .isInstanceOf(ReviewException.class)
                .hasMessage("只有购买者才能评价该商品");
    }

    @Test
    void createReviewRejectsNonReviewableOrderStatus() {
        ReviewFixture fixture = createFixture(OrderStatus.PAID, "REVIEW-STATUS-001", "review-status-user");

        assertThatThrownBy(() -> reviewService.createReview(fixture.user().getId(), new CreateReviewRequest(
                fixture.orderItem().getId(),
                2,
                "还没发货")))
                .isInstanceOf(ReviewException.class)
                .hasMessage("当前订单状态不支持评价");
    }

    @Test
    void createReviewTranslatesDuplicateConstraintDuringSave() {
        ReviewRepository duplicateReviewRepository = mock(ReviewRepository.class);
        CustomerOrderRepository orderRepository = mock(CustomerOrderRepository.class);
        ProductRepository productRepository = mock(ProductRepository.class);
        UserAccountRepository accountRepository = mock(UserAccountRepository.class);

        ReviewService service = new ReviewService(
                duplicateReviewRepository,
                orderRepository,
                productRepository,
                accountRepository);

        Long userId = 1L;
        Long productId = 2L;
        Long orderItemId = 3L;

        UserAccount user = mock(UserAccount.class);
        Product product = mock(Product.class);
        OrderItem orderItem = mock(OrderItem.class);
        CustomerOrder order = mock(CustomerOrder.class);

        when(user.getId()).thenReturn(userId);
        when(product.getId()).thenReturn(productId);
        when(product.getName()).thenReturn("并发测试商品");
        when(orderItem.getId()).thenReturn(orderItemId);
        when(orderItem.getProductId()).thenReturn(productId);
        when(order.getUser()).thenReturn(user);
        when(order.getStatus()).thenReturn(OrderStatus.DELIVERED);
        when(order.getItems()).thenReturn(java.util.List.of(orderItem));

        when(orderRepository.findByOrderItemId(orderItemId)).thenReturn(java.util.Optional.of(order));
        when(duplicateReviewRepository.existsByOrderItemId(orderItemId)).thenReturn(false);
        when(accountRepository.findById(userId)).thenReturn(java.util.Optional.of(user));
        when(productRepository.findById(productId)).thenReturn(java.util.Optional.of(product));
        when(duplicateReviewRepository.saveAndFlush(any(Review.class))).thenThrow(
                new DataIntegrityViolationException("duplicate key value violates unique constraint 'uk_review_order_item'"));

        assertThatThrownBy(() -> service.createReview(
                userId,
                new CreateReviewRequest(orderItemId, 5, "并发重复评价")))
                .isInstanceOf(ReviewException.class)
                .hasMessage("该订单商品已评价");
    }

    @Test
    void listProductReviewsReturnsExpectedRows() {
        ReviewFixture targetFirst = createFixture(OrderStatus.DELIVERED, "REVIEW-PRODUCT-001", "review-product-user-1");
        ReviewFixture targetSecond = createFixture(OrderStatus.SHIPPED, "REVIEW-PRODUCT-002", "review-product-user-2",
                targetFirst.product());
        ReviewFixture otherProduct = createFixture(OrderStatus.DELIVERED, "REVIEW-PRODUCT-003", "review-product-user-3");

        reviewService.createReview(targetFirst.user().getId(), new CreateReviewRequest(
                targetFirst.orderItem().getId(),
                4,
                "第一条评价"));
        reviewService.createReview(targetSecond.user().getId(), new CreateReviewRequest(
                targetSecond.orderItem().getId(),
                5,
                "第二条评价"));
        reviewService.createReview(otherProduct.user().getId(), new CreateReviewRequest(
                otherProduct.orderItem().getId(),
                1,
                "其他商品评价"));

        entityManager.flush();
        entityManager.clear();

        List<ReviewResponse> reviews = reviewService.listProductReviews(targetFirst.product().getId());

        assertThat(reviews).hasSize(2);
        assertThat(reviews)
                .extracting(ReviewResponse::productId)
                .containsOnly(targetFirst.product().getId());
        assertThat(reviews)
                .extracting(ReviewResponse::content)
                .containsExactly("第二条评价", "第一条评价");
    }

    private ReviewFixture createFixture(OrderStatus status, String orderNumber, String username) {
        Product product = createProduct("SKU-" + orderNumber, "商品-" + orderNumber);
        return createFixture(status, orderNumber, username, product);
    }

    private ReviewFixture createFixture(OrderStatus status, String orderNumber, String username, Product product) {
        UserAccount user = createUser(username, username + "@example.com", nextPhone(username));
        CustomerOrder order = createOrder(user, orderNumber, status);
        OrderItem orderItem = createOrderItem(order, product);
        entityManager.flush();
        return new ReviewFixture(user, product, orderItem);
    }

    private UserAccount createUser(String username, String email, String phone) {
        UserAccount user = new UserAccount();
        user.setUsername(username);
        user.setPasswordHash("hashed-password");
        user.setEmail(email);
        user.setPhone(phone);
        user.setRole(UserRole.CUSTOMER);
        user.setActive(true);
        return entityManager.persist(user);
    }

    private Product createProduct(String sku, String name) {
        Product product = new Product();
        product.setName(name);
        product.setSku(sku);
        product.setCategory("测试分类");
        product.setPrice(new BigDecimal("99.00"));
        product.setStock(100);
        product.setStatus(ProductStatus.ACTIVE);
        return entityManager.persist(product);
    }

    private CustomerOrder createOrder(UserAccount user, String orderNumber, OrderStatus status) {
        CustomerOrder order = new CustomerOrder();
        order.setUser(user);
        order.setOrderNumber(orderNumber);
        order.setStatus(status);
        order.setTotalAmount(new BigDecimal("99.00"));
        order.setShippingAddressId(1L);
        order.setShippingRecipient("测试用户");
        order.setShippingPhone("13900009999");
        order.setShippingProvince("上海市");
        order.setShippingCity("上海市");
        order.setShippingDistrict("浦东新区");
        order.setShippingStreet("测试路 1 号");
        order.setShippingPostalCode("200000");
        return entityManager.persist(order);
    }

    private OrderItem createOrderItem(CustomerOrder order, Product product) {
        OrderItem item = new OrderItem();
        item.setOrder(order);
        item.setProductId(product.getId());
        item.setProductName(product.getName());
        item.setProductSku(product.getSku());
        item.setQuantity(1);
        item.setUnitPrice(product.getPrice());
        order.getItems().add(item);
        return entityManager.persist(item);
    }

    private String nextPhone(String seed) {
        String digits = String.valueOf(Math.abs(seed.hashCode()));
        StringBuilder builder = new StringBuilder("139");
        for (int i = 0; builder.length() < 11; i++) {
            builder.append(digits.charAt(i % digits.length()));
        }
        return builder.substring(0, 11);
    }

    private record ReviewFixture(UserAccount user, Product product, OrderItem orderItem) {
    }
}
