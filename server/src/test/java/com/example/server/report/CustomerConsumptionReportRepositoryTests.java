package com.example.server.report;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.TestPropertySource;

import com.example.server.order.CustomerOrder;
import com.example.server.order.OrderItem;
import com.example.server.order.OrderStatus;
import com.example.server.payment.PaymentMethod;
import com.example.server.payment.PaymentRecord;
import com.example.server.payment.PaymentStatus;
import com.example.server.product.Product;
import com.example.server.product.ProductStatus;
import com.example.server.review.Review;
import com.example.server.review.ReviewRepository;
import com.example.server.user.UserAccount;
import com.example.server.user.UserRole;

@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.ANY)
@Import(CustomerConsumptionReportRepository.class)
@TestPropertySource(properties = {
        "spring.sql.init.mode=never",
        "spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.H2Dialect"
})
class CustomerConsumptionReportRepositoryTests {

    @Autowired
    private CustomerConsumptionReportRepository reportRepository;

    @Autowired
    private ReviewRepository reviewRepository;

    @Autowired
    private TestEntityManager entityManager;

    @Test
    void complexReportReturnsFavoriteCategoryAndPaymentSummary() {
        UserAccount user = createUser("report-user-1", "report-user-1@example.com", "13900000021");
        Product digitalOne = createProduct("REPORT-DIGITAL-1", "数码影音", new BigDecimal("299.00"));
        Product digitalTwo = createProduct("REPORT-DIGITAL-2", "数码影音", new BigDecimal("199.00"));
        Product wearable = createProduct("REPORT-WEARABLE-1", "智能穿戴", new BigDecimal("399.00"));

        CustomerOrder firstOrder = createOrder(user, "ORD-REPORT-1", OrderStatus.PAID, new BigDecimal("698.00"));
        createOrderItem(firstOrder, digitalOne, 1, new BigDecimal("299.00"));
        createOrderItem(firstOrder, wearable, 1, new BigDecimal("399.00"));
        createPayment(firstOrder, "PAY-REPORT-1", new BigDecimal("698.00"), Instant.parse("2026-04-15T10:15:30Z"));

        CustomerOrder secondOrder = createOrder(user, "ORD-REPORT-2", OrderStatus.SHIPPED, new BigDecimal("398.00"));
        createOrderItem(secondOrder, digitalTwo, 2, new BigDecimal("199.00"));
        createPayment(secondOrder, "PAY-REPORT-2", new BigDecimal("398.00"), Instant.parse("2026-04-16T08:00:00Z"));

        entityManager.flush();
        entityManager.clear();

        List<CustomerConsumptionReportRow> rows = reportRepository.fetchCustomerConsumptionReport();

        assertThat(rows).singleElement().satisfies(row -> {
            assertThat(row.userId()).isEqualTo(user.getId());
            assertThat(row.username()).isEqualTo("report-user-1");
            assertThat(row.orderCount()).isEqualTo(2L);
            assertThat(row.totalItems()).isEqualTo(4L);
            assertThat(row.totalPaidAmount()).isEqualByComparingTo("1096.00");
            assertThat(row.lastPaidAt()).isEqualTo(Instant.parse("2026-04-16T08:00:00Z"));
            assertThat(row.favoriteCategory()).isEqualTo("数码影音");
            assertThat(row.categoryBuyCount()).isEqualTo(3L);
        });
    }

    @Test
    void complexReportKeepsUserWhenOrderItemsHaveNoMatchingProduct() {
        UserAccount user = createUser("report-user-null-product", "report-user-null-product@example.com", "13900000031");

        CustomerOrder order = createOrder(user, "ORD-REPORT-NULL-PRODUCT", OrderStatus.PAID, new BigDecimal("88.00"));
        createOrderItem(order, null, "缺失商品", "MISSING-SKU", 2, new BigDecimal("44.00"));
        createPayment(order, "PAY-REPORT-NULL-PRODUCT", new BigDecimal("88.00"), Instant.parse("2026-04-17T09:00:00Z"));

        entityManager.flush();
        entityManager.clear();

        List<CustomerConsumptionReportRow> rows = reportRepository.fetchCustomerConsumptionReport();

        assertThat(rows)
                .filteredOn(row -> row.userId().equals(user.getId()))
                .singleElement()
                .satisfies(row -> {
                    assertThat(row.username()).isEqualTo("report-user-null-product");
                    assertThat(row.orderCount()).isEqualTo(1L);
                    assertThat(row.totalItems()).isEqualTo(2L);
                    assertThat(row.totalPaidAmount()).isEqualByComparingTo("88.00");
                    assertThat(row.lastPaidAt()).isEqualTo(Instant.parse("2026-04-17T09:00:00Z"));
                    assertThat(row.favoriteCategory()).isNull();
                    assertThat(row.categoryBuyCount()).isNull();
                });
    }

    @Test
    void complexReportIncludesUsersWithoutOrdersWithZeroAggregates() {
        UserAccount activeUser = createUser("report-user-active", "report-user-active@example.com", "13900000034");
        UserAccount idleUser = createUser("report-user-idle", "report-user-idle@example.com", "13900000035");
        Product product = createProduct("REPORT-IDLE-USER", "测试分类", new BigDecimal("48.00"));

        CustomerOrder order = createOrder(activeUser, "ORD-REPORT-IDLE-USER", OrderStatus.PAID, new BigDecimal("96.00"));
        createOrderItem(order, product, 2, new BigDecimal("48.00"));
        createPayment(order, "PAY-REPORT-IDLE-USER", new BigDecimal("96.00"), Instant.parse("2026-04-18T10:00:00Z"));

        entityManager.flush();
        entityManager.clear();

        List<CustomerConsumptionReportRow> rows = reportRepository.fetchCustomerConsumptionReport();

        assertThat(rows)
                .extracting(CustomerConsumptionReportRow::userId)
                .contains(activeUser.getId(), idleUser.getId());
        assertThat(rows)
                .filteredOn(row -> row.userId().equals(idleUser.getId()))
                .singleElement()
                .satisfies(row -> {
                    assertThat(row.username()).isEqualTo("report-user-idle");
                    assertThat(row.orderCount()).isEqualTo(0L);
                    assertThat(row.totalItems()).isEqualTo(0L);
                    assertThat(row.totalPaidAmount()).isEqualByComparingTo("0");
                    assertThat(row.lastPaidAt()).isNull();
                    assertThat(row.favoriteCategory()).isNull();
                    assertThat(row.categoryBuyCount()).isNull();
                });
    }

    @Test
    void complexReportBreaksEqualPaymentTiesByOrderCountBeforeUserId() {
        UserAccount multiOrderUser = createUser("report-user-tie-many", "report-user-tie-many@example.com", "13900000036");
        UserAccount singleOrderUser = createUser("report-user-tie-one", "report-user-tie-one@example.com", "13900000037");
        Product product = createProduct("REPORT-TIE-BREAK", "测试分类", new BigDecimal("50.00"));

        CustomerOrder firstOrder = createOrder(multiOrderUser, "ORD-REPORT-TIE-1", OrderStatus.PAID, new BigDecimal("40.00"));
        createOrderItem(firstOrder, product, 1, new BigDecimal("40.00"));
        createPayment(firstOrder, "PAY-REPORT-TIE-1", new BigDecimal("40.00"), Instant.parse("2026-04-18T08:00:00Z"));

        CustomerOrder secondOrder = createOrder(multiOrderUser, "ORD-REPORT-TIE-2", OrderStatus.PAID, new BigDecimal("60.00"));
        createOrderItem(secondOrder, product, 1, new BigDecimal("60.00"));
        createPayment(secondOrder, "PAY-REPORT-TIE-2", new BigDecimal("60.00"), Instant.parse("2026-04-18T09:00:00Z"));

        CustomerOrder singleOrder = createOrder(singleOrderUser, "ORD-REPORT-TIE-3", OrderStatus.PAID, new BigDecimal("100.00"));
        createOrderItem(singleOrder, product, 2, new BigDecimal("50.00"));
        createPayment(singleOrder, "PAY-REPORT-TIE-3", new BigDecimal("100.00"), Instant.parse("2026-04-18T10:00:00Z"));

        entityManager.flush();
        entityManager.clear();

        List<CustomerConsumptionReportRow> rows = reportRepository.fetchCustomerConsumptionReport();

        assertThat(rows.subList(0, 2))
                .extracting(CustomerConsumptionReportRow::userId)
                .containsExactly(multiOrderUser.getId(), singleOrderUser.getId());
        assertThat(rows.get(0).totalPaidAmount()).isEqualByComparingTo(rows.get(1).totalPaidAmount());
        assertThat(rows.get(0).orderCount()).isGreaterThan(rows.get(1).orderCount());
    }

    @Test
    void complexReportAndViewDoNotMultiplyOrderItemsAcrossMultiplePayments() {
        UserAccount user = createUser("report-user-multi-payment", "report-user-multi-payment@example.com", "13900000032");
        Product product = createProduct("REPORT-MULTI-PAY", "测试分类", new BigDecimal("50.00"));

        CustomerOrder order = createOrder(user, "ORD-REPORT-MULTI-PAY", OrderStatus.PAID, new BigDecimal("100.00"));
        OrderItem orderItem = createOrderItem(order, product, 2, new BigDecimal("50.00"));
        createPayment(order, "PAY-REPORT-MULTI-PAY-1", new BigDecimal("20.00"), Instant.parse("2026-04-17T08:00:00Z"));
        createPayment(order, "PAY-REPORT-MULTI-PAY-2", new BigDecimal("80.00"), Instant.parse("2026-04-17T10:30:00Z"));

        entityManager.flush();
        recreateOrderDetailView();
        entityManager.clear();

        List<CustomerConsumptionReportRow> rows = reportRepository.fetchCustomerConsumptionReport();
        Object[] viewRow = (Object[]) entityManager.getEntityManager()
                .createNativeQuery("""
                        SELECT quantity, payment_status, paid_at
                        FROM order_detail_view
                        WHERE order_item_id = :orderItemId
                        """)
                .setParameter("orderItemId", orderItem.getId())
                .getSingleResult();

        assertThat(rows)
                .filteredOn(row -> row.userId().equals(user.getId()))
                .singleElement()
                .satisfies(row -> {
                    assertThat(row.orderCount()).isEqualTo(1L);
                    assertThat(row.totalItems()).isEqualTo(2L);
                    assertThat(row.totalPaidAmount()).isEqualByComparingTo("100.00");
                    assertThat(row.lastPaidAt()).isEqualTo(Instant.parse("2026-04-17T10:30:00Z"));
                    assertThat(row.favoriteCategory()).isEqualTo("测试分类");
                    assertThat(row.categoryBuyCount()).isEqualTo(2L);
                });
        assertThat(((Number) viewRow[0]).longValue()).isEqualTo(2L);
        assertThat(viewRow[1]).isEqualTo("SUCCESS");
        assertThat(toInstant(viewRow[2])).isEqualTo(Instant.parse("2026-04-17T10:30:00Z"));
    }

    @Test
    void complexReportAndViewPreferSuccessfulPaymentWhenLaterPendingPaymentHasNullPaidAt() {
        UserAccount user = createUser("report-user-null-paid-at", "report-user-null-paid-at@example.com", "13900000033");
        Product product = createProduct("REPORT-NULL-PAID-AT", "测试分类", new BigDecimal("120.00"));

        CustomerOrder order = createOrder(user, "ORD-REPORT-NULL-PAID-AT", OrderStatus.PAID, new BigDecimal("120.00"));
        OrderItem orderItem = createOrderItem(order, product, 1, new BigDecimal("120.00"));
        createPayment(order, "PAY-REPORT-NULL-PAID-AT-SUCCESS", new BigDecimal("120.00"), PaymentStatus.SUCCESS,
                Instant.parse("2026-04-18T09:15:00Z"));
        createPayment(order, "PAY-REPORT-NULL-PAID-AT-PENDING", new BigDecimal("120.00"), PaymentStatus.PENDING, null);

        entityManager.flush();
        recreateOrderDetailView();
        entityManager.clear();

        List<CustomerConsumptionReportRow> rows = reportRepository.fetchCustomerConsumptionReport();
        Object[] viewRow = (Object[]) entityManager.getEntityManager()
                .createNativeQuery("""
                        SELECT payment_status, paid_at
                        FROM order_detail_view
                        WHERE order_item_id = :orderItemId
                        """)
                .setParameter("orderItemId", orderItem.getId())
                .getSingleResult();

        assertThat(rows)
                .filteredOn(row -> row.userId().equals(user.getId()))
                .singleElement()
                .satisfies(row -> {
                    assertThat(row.orderCount()).isEqualTo(1L);
                    assertThat(row.totalItems()).isEqualTo(1L);
                    assertThat(row.totalPaidAmount()).isEqualByComparingTo("120.00");
                    assertThat(row.lastPaidAt()).isEqualTo(Instant.parse("2026-04-18T09:15:00Z"));
                    assertThat(row.favoriteCategory()).isEqualTo("测试分类");
                    assertThat(row.categoryBuyCount()).isEqualTo(1L);
                });
        assertThat(viewRow[0]).isEqualTo("SUCCESS");
        assertThat(toInstant(viewRow[1])).isEqualTo(Instant.parse("2026-04-18T09:15:00Z"));
    }

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
        Product anotherProduct = createProduct("REVIEW-SKU-2", "测试分类", new BigDecimal("99.00"));

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
        Product product = createProduct("REVIEW-SKU-1", "测试分类", new BigDecimal("99.00"));

        CustomerOrder order = createOrder(user, "ORD-REVIEW-1", OrderStatus.PAID, product.getPrice());
        OrderItem orderItem = createOrderItem(order, product, 1, product.getPrice());

        entityManager.flush();

        return new ReviewFixture(user, product, orderItem);
    }

    private CustomerOrder createOrder(UserAccount user, String orderNumber, OrderStatus status, BigDecimal totalAmount) {
        CustomerOrder order = new CustomerOrder();
        order.setOrderNumber(orderNumber);
        order.setUser(user);
        order.setStatus(status);
        order.setTotalAmount(totalAmount);
        entityManager.persist(order);
        return order;
    }

    private OrderItem createOrderItem(CustomerOrder order, Product product, int quantity, BigDecimal unitPrice) {
        return createOrderItem(order, product, product.getName(), product.getSku(), quantity, unitPrice);
    }

    private OrderItem createOrderItem(CustomerOrder order, Product product, String productName, String productSku, int quantity,
            BigDecimal unitPrice) {
        OrderItem orderItem = new OrderItem();
        orderItem.setOrder(order);
        orderItem.setProductId(product == null ? null : product.getId());
        orderItem.setProductName(productName);
        orderItem.setProductSku(productSku);
        orderItem.setQuantity(quantity);
        orderItem.setUnitPrice(unitPrice);
        entityManager.persist(orderItem);
        return orderItem;
    }

    private PaymentRecord createPayment(CustomerOrder order, String paymentNo, BigDecimal amount, Instant paidAt) {
        return createPayment(order, paymentNo, amount, PaymentStatus.SUCCESS, paidAt);
    }

    private PaymentRecord createPayment(CustomerOrder order, String paymentNo, BigDecimal amount, PaymentStatus paymentStatus,
            Instant paidAt) {
        PaymentRecord paymentRecord = new PaymentRecord();
        paymentRecord.setOrder(order);
        paymentRecord.setPaymentNo(paymentNo);
        paymentRecord.setPaymentMethod(PaymentMethod.ALIPAY);
        paymentRecord.setAmount(amount);
        paymentRecord.setPaymentStatus(paymentStatus);
        paymentRecord.setPaidAt(paidAt);
        entityManager.persist(paymentRecord);
        return paymentRecord;
    }

    private void recreateOrderDetailView() {
        entityManager.getEntityManager().createNativeQuery("DROP VIEW IF EXISTS order_detail_view").executeUpdate();
        entityManager.getEntityManager().createNativeQuery("""
                CREATE VIEW order_detail_view AS
                SELECT
                    o.id AS order_id,
                    o.order_number,
                    ua.id AS user_id,
                    ua.username,
                    o.status AS order_status,
                    o.created_at AS order_created_at,
                    oi.id AS order_item_id,
                    oi.product_id,
                    oi.product_name,
                    oi.product_sku,
                    oi.quantity,
                    oi.unit_price,
                    oi.quantity * oi.unit_price AS item_amount,
                    latest_payment.payment_status,
                    latest_payment.payment_method,
                    latest_payment.paid_at
                FROM orders o
                JOIN user_accounts ua ON ua.id = o.user_id
                JOIN order_items oi ON oi.order_id = o.id
                LEFT JOIN (
                    SELECT order_id, payment_status, payment_method, paid_at
                    FROM (
                        SELECT
                            pr.order_id,
                            pr.payment_status,
                            pr.payment_method,
                            pr.paid_at,
                            ROW_NUMBER() OVER (
                                PARTITION BY pr.order_id
                                ORDER BY pr.paid_at DESC NULLS LAST, pr.id DESC
                            ) AS payment_rank
                        FROM payment_records pr
                    ) ranked_payments
                    WHERE payment_rank = 1
                ) latest_payment ON latest_payment.order_id = o.id
                """).executeUpdate();
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

    private Product createProduct(String sku, String category, BigDecimal price) {
        Product product = new Product();
        product.setName("测试商品-" + sku);
        product.setSku(sku);
        product.setCategory(category);
        product.setPrice(price);
        product.setStock(10);
        product.setStatus(ProductStatus.ACTIVE);
        entityManager.persist(product);
        return product;
    }

    private Instant toInstant(Object value) {
        if (value instanceof Instant instant) {
            return instant;
        }
        if (value instanceof java.time.OffsetDateTime offsetDateTime) {
            return offsetDateTime.toInstant();
        }
        if (value instanceof java.time.LocalDateTime localDateTime) {
            return localDateTime.toInstant(java.time.ZoneOffset.UTC);
        }
        return ((java.sql.Timestamp) value).toInstant();
    }

    private record ReviewFixture(UserAccount user, Product product, OrderItem orderItem) {
    }
}
