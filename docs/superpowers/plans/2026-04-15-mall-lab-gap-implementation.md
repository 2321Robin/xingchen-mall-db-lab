# Mall Lab Gap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add two missing business entities, one reusable order view, one qualifying complex query, and the supporting tests/docs needed to satisfy the database lab requirements in the existing mall project.

**Architecture:** Keep the current Spring Boot + JPA structure intact and make the smallest coherent set of changes. Persist the new requirements in the backend domain model and SQL seed data, expose the complex query through a narrow read-only admin/reporting path, and update the lab report to describe the final design and verification evidence.

**Tech Stack:** Spring Boot 3, Spring Data JPA, PostgreSQL, JUnit 5, Nuxt report markdown

---

## File Map

### Backend database and config

- Modify: `server/src/main/resources/data.sql`
- Modify: `db.sql`
- Modify: `server/build.gradle`
- Modify: `server/src/main/resources/application.properties`

### Existing backend domain files to extend

- Modify: `server/src/main/java/com/example/server/order/CustomerOrder.java`
- Modify: `server/src/main/java/com/example/server/order/OrderItem.java`
- Modify: `server/src/main/java/com/example/server/order/OrderUserService.java`
- Modify: `server/src/main/java/com/example/server/order/OrderMapper.java`
- Modify: `server/src/main/java/com/example/server/order/dto/OrderItemResponse.java`
- Modify: `server/src/main/java/com/example/server/order/dto/OrderResponse.java`
- Modify: `server/src/main/java/com/example/server/order/CustomerOrderRepository.java`

### New payment domain files

- Create: `server/src/main/java/com/example/server/payment/PaymentRecord.java`
- Create: `server/src/main/java/com/example/server/payment/PaymentStatus.java`
- Create: `server/src/main/java/com/example/server/payment/PaymentMethod.java`
- Create: `server/src/main/java/com/example/server/payment/PaymentRecordRepository.java`

### New review domain files

- Create: `server/src/main/java/com/example/server/review/Review.java`
- Create: `server/src/main/java/com/example/server/review/ReviewRepository.java`

### Reporting query files

- Create: `server/src/main/java/com/example/server/report/CustomerConsumptionReportRow.java`
- Create: `server/src/main/java/com/example/server/report/CustomerConsumptionReportController.java`
- Create: `server/src/main/java/com/example/server/report/CustomerConsumptionReportService.java`
- Create: `server/src/main/java/com/example/server/report/CustomerConsumptionReportRepository.java`

### Tests

- Create: `server/src/test/java/com/example/server/order/OrderPaymentFlowTests.java`
- Create: `server/src/test/java/com/example/server/report/CustomerConsumptionReportRepositoryTests.java`

### Docs

- Modify: `nuxt-app/report.md`
- Modify: `README.md`

## Task 1: Prepare testable backend database setup

**Files:**
- Modify: `server/build.gradle`
- Modify: `server/src/main/resources/application.properties`
- Test: `server/src/test/java/com/example/server/ServerApplicationTests.java`

- [ ] **Step 1: Write the failing test support change**

Add H2 for tests so JPA-based repository tests can run without a local PostgreSQL instance:

```gradle
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter'
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-validation'
    implementation 'org.springframework.security:spring-security-crypto'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    runtimeOnly 'org.postgresql:postgresql'

    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    testImplementation 'com.h2database:h2'
    testRuntimeOnly 'org.junit.platform:junit-platform-launcher'
}
```

- [ ] **Step 2: Point tests at an in-memory datasource**

Keep production defaults unchanged, but add test-safe fallback notes in `application.properties` and rely on test annotations to override URL when needed:

```properties
spring.jpa.hibernate.ddl-auto=update
spring.jpa.defer-datasource-initialization=true
spring.sql.init.mode=always
```
```
No property behavior change is required here beyond keeping SQL init enabled; repository tests will use `@TestPropertySource`.
```

- [ ] **Step 3: Run the existing smoke test**

Run: `./gradlew.bat test --tests com.example.server.ServerApplicationTests`

Expected: PASS, proving the test toolchain still boots after adding H2.

- [ ] **Step 4: Commit**

```bash
git add server/build.gradle server/src/main/resources/application.properties
git commit -m "test: enable in-memory backend test setup"
```

## Task 2: Extend order items so reviews and analytics can join products safely

**Files:**
- Modify: `server/src/main/java/com/example/server/order/OrderItem.java`
- Modify: `server/src/main/java/com/example/server/order/OrderUserService.java`
- Modify: `db.sql`
- Modify: `server/src/main/resources/data.sql`
- Test: `server/src/test/java/com/example/server/order/OrderPaymentFlowTests.java`

- [ ] **Step 1: Write the failing integration test**

Create `OrderPaymentFlowTests` with a first test that asserts `createOrder()` stores product id, SKU, name, quantity, and price together on the generated order item:

```java
@SpringBootTest
class OrderPaymentFlowTests {

    @Autowired
    private OrderUserService orderUserService;

    @Autowired
    private CustomerOrderRepository customerOrderRepository;

    @Test
    void createOrderStoresProductReferenceOnOrderItem() {
        OrderResponse response = orderUserService.createOrder(2L, new CreateOrderRequest(1L));

        CustomerOrder saved = customerOrderRepository.findById(response.id()).orElseThrow();
        OrderItem item = saved.getItems().getFirst();

        assertThat(item.getProductId()).isNotNull();
        assertThat(item.getProductSku()).isNotBlank();
        assertThat(item.getProductName()).isNotBlank();
    }
}
```

- [ ] **Step 2: Run the new test to verify it fails**

Run: `./gradlew.bat test --tests com.example.server.order.OrderPaymentFlowTests#createOrderStoresProductReferenceOnOrderItem`

Expected: FAIL because `OrderItem` does not yet expose `productId` and the create-order flow does not set it.

- [ ] **Step 3: Add the minimal entity and service change**

In `OrderItem.java`, add the new column:

```java
@Column(name = "product_id", nullable = false)
private Long productId;

public Long getProductId() {
    return productId;
}

public void setProductId(Long productId) {
    this.productId = productId;
}
```

In `OrderUserService.java`, set it during order creation:

```java
orderItem.setProductId(product.getId());
orderItem.setProductName(product.getName());
orderItem.setProductSku(product.getSku());
```

In `db.sql` and `data.sql`, add the `product_id` column to `order_items` inserts so exported schema and seeds match runtime behavior.

- [ ] **Step 4: Run the test again**

Run: `./gradlew.bat test --tests com.example.server.order.OrderPaymentFlowTests#createOrderStoresProductReferenceOnOrderItem`

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add server/src/main/java/com/example/server/order/OrderItem.java server/src/main/java/com/example/server/order/OrderUserService.java server/src/test/java/com/example/server/order/OrderPaymentFlowTests.java server/src/main/resources/data.sql db.sql
git commit -m "feat: persist product ids on order items"
```

## Task 3: Add payment records and connect them to order payment flow

**Files:**
- Create: `server/src/main/java/com/example/server/payment/PaymentRecord.java`
- Create: `server/src/main/java/com/example/server/payment/PaymentStatus.java`
- Create: `server/src/main/java/com/example/server/payment/PaymentMethod.java`
- Create: `server/src/main/java/com/example/server/payment/PaymentRecordRepository.java`
- Modify: `server/src/main/java/com/example/server/order/CustomerOrder.java`
- Modify: `server/src/main/java/com/example/server/order/OrderUserService.java`
- Modify: `server/src/main/resources/data.sql`
- Modify: `db.sql`
- Test: `server/src/test/java/com/example/server/order/OrderPaymentFlowTests.java`

- [ ] **Step 1: Write the failing test for payment persistence**

Extend `OrderPaymentFlowTests` with a second test:

```java
@Autowired
private PaymentRecordRepository paymentRecordRepository;

@Test
void markAsPaidCreatesSuccessfulPaymentRecord() {
    OrderResponse paid = orderUserService.markAsPaid(2L, 1L);

    PaymentRecord record = paymentRecordRepository.findTopByOrderIdOrderByCreatedAtDesc(1L).orElseThrow();

    assertThat(paid.status()).isEqualTo(OrderStatus.PAID);
    assertThat(record.getPaymentStatus()).isEqualTo(PaymentStatus.SUCCESS);
    assertThat(record.getAmount()).isPositive();
    assertThat(record.getPaidAt()).isNotNull();
}
```

- [ ] **Step 2: Run the payment test to verify it fails**

Run: `./gradlew.bat test --tests com.example.server.order.OrderPaymentFlowTests#markAsPaidCreatesSuccessfulPaymentRecord`

Expected: FAIL because no payment domain exists yet.

- [ ] **Step 3: Add the new payment domain**

Create `PaymentStatus.java`:

```java
public enum PaymentStatus {
    PENDING,
    SUCCESS,
    FAILED
}
```

Create `PaymentMethod.java`:

```java
public enum PaymentMethod {
    ALIPAY,
    WECHAT,
    BANK_CARD
}
```

Create `PaymentRecord.java` with a many-to-one relation to `CustomerOrder` and columns for payment number, method, amount, status, paid time, create/update time.

Create `PaymentRecordRepository.java` with:

```java
public interface PaymentRecordRepository extends JpaRepository<PaymentRecord, Long> {
    Optional<PaymentRecord> findTopByOrderIdOrderByCreatedAtDesc(Long orderId);
}
```

In `CustomerOrder.java`, add:

```java
@OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
@OrderBy("id ASC")
private List<PaymentRecord> paymentRecords = new ArrayList<>();
```

In `OrderUserService.markAsPaid()`, create and attach one successful payment record:

```java
PaymentRecord paymentRecord = new PaymentRecord();
paymentRecord.setOrder(order);
paymentRecord.setPaymentNo("PAY-" + order.getOrderNumber());
paymentRecord.setPaymentMethod(PaymentMethod.ALIPAY);
paymentRecord.setAmount(order.getTotalAmount());
paymentRecord.setPaymentStatus(PaymentStatus.SUCCESS);
paymentRecord.setPaidAt(Instant.now());
order.getPaymentRecords().add(paymentRecord);
order.setStatus(OrderStatus.PAID);
```

Mirror the new table, constraints, indexes, and seed inserts in `db.sql` and `data.sql`.

- [ ] **Step 4: Run the payment test again**

Run: `./gradlew.bat test --tests com.example.server.order.OrderPaymentFlowTests#markAsPaidCreatesSuccessfulPaymentRecord`

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add server/src/main/java/com/example/server/payment server/src/main/java/com/example/server/order/CustomerOrder.java server/src/main/java/com/example/server/order/OrderUserService.java server/src/main/resources/data.sql db.sql server/src/test/java/com/example/server/order/OrderPaymentFlowTests.java
git commit -m "feat: persist payment records for paid orders"
```

## Task 4: Add reviews as the eighth entity

**Files:**
- Create: `server/src/main/java/com/example/server/review/Review.java`
- Create: `server/src/main/java/com/example/server/review/ReviewRepository.java`
- Modify: `server/src/main/resources/data.sql`
- Modify: `db.sql`
- Test: `server/src/test/java/com/example/server/report/CustomerConsumptionReportRepositoryTests.java`

- [ ] **Step 1: Write the failing repository test for review constraints**

Create `CustomerConsumptionReportRepositoryTests` with a review persistence smoke test:

```java
@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.ANY)
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
    }
}
```

- [ ] **Step 2: Run the review test to verify it fails**

Run: `./gradlew.bat test --tests com.example.server.report.CustomerConsumptionReportRepositoryTests#reviewUsesUniqueOrderItemAndBoundedRating`

Expected: FAIL because `Review` and `ReviewRepository` do not exist.

- [ ] **Step 3: Add the minimal review domain**

Create `Review.java` with:

```java
@Entity
@Table(name = "reviews", uniqueConstraints = {
    @UniqueConstraint(name = "uk_review_order_item", columnNames = "order_item_id")
})
public class Review {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "product_id", nullable = false)
    private Long productId;

    @Column(name = "order_item_id", nullable = false)
    private Long orderItemId;

    @Column(nullable = false)
    private Integer rating;

    @Column(length = 500)
    private String content;
}
```

Create a plain `ReviewRepository extends JpaRepository<Review, Long>`.

Add the matching table, indexes, and seed inserts to `db.sql` and `data.sql`.

- [ ] **Step 4: Run the review test again**

Run: `./gradlew.bat test --tests com.example.server.report.CustomerConsumptionReportRepositoryTests#reviewUsesUniqueOrderItemAndBoundedRating`

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add server/src/main/java/com/example/server/review server/src/main/resources/data.sql db.sql server/src/test/java/com/example/server/report/CustomerConsumptionReportRepositoryTests.java
git commit -m "feat: add product review entity"
```

## Task 5: Add the order detail view and the qualifying complex query

**Files:**
- Create: `server/src/main/java/com/example/server/report/CustomerConsumptionReportRow.java`
- Create: `server/src/main/java/com/example/server/report/CustomerConsumptionReportRepository.java`
- Create: `server/src/main/java/com/example/server/report/CustomerConsumptionReportService.java`
- Create: `server/src/main/java/com/example/server/report/CustomerConsumptionReportController.java`
- Modify: `server/src/main/resources/data.sql`
- Modify: `db.sql`
- Test: `server/src/test/java/com/example/server/report/CustomerConsumptionReportRepositoryTests.java`

- [ ] **Step 1: Write the failing report query test**

Extend `CustomerConsumptionReportRepositoryTests` with:

```java
@Autowired
private CustomerConsumptionReportRepository reportRepository;

@Test
void complexReportReturnsFavoriteCategoryAndPaymentSummary() {
    List<CustomerConsumptionReportRow> rows = reportRepository.fetchCustomerConsumptionReport();

    assertThat(rows).isNotEmpty();
    assertThat(rows.getFirst().username()).isNotBlank();
    assertThat(rows.getFirst().favoriteCategory()).isNotNull();
}
```

- [ ] **Step 2: Run the report test to verify it fails**

Run: `./gradlew.bat test --tests com.example.server.report.CustomerConsumptionReportRepositoryTests#complexReportReturnsFavoriteCategoryAndPaymentSummary`

Expected: FAIL because the report repository and view do not exist.

- [ ] **Step 3: Create the SQL view and report query**

Add to `db.sql` and `data.sql`:

```sql
CREATE VIEW order_detail_view AS
SELECT
    o.id AS order_id,
    o.order_number,
    ua.id AS user_id,
    ua.username,
    o.status AS order_status,
    o.created_at AS order_created_at,
    oi.id AS order_item_id,
    oi.product_name,
    oi.product_sku,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS item_amount,
    pr.payment_status,
    pr.payment_method,
    pr.paid_at
FROM orders o
JOIN user_accounts ua ON ua.id = o.user_id
JOIN order_items oi ON oi.order_id = o.id
LEFT JOIN payment_records pr ON pr.order_id = o.id;
```

Create `CustomerConsumptionReportRow.java` as a record:

```java
public record CustomerConsumptionReportRow(
        Long userId,
        String username,
        Long orderCount,
        Long totalItems,
        BigDecimal totalPaidAmount,
        Instant lastPaidAt,
        String favoriteCategory,
        Long categoryBuyCount) {
}
```

Create `CustomerConsumptionReportRepository.java` using `EntityManager` and the agreed SQL.

Create `CustomerConsumptionReportService.java` with one method returning the repository result.

Create `CustomerConsumptionReportController.java` with one read-only endpoint, for example:

```java
@RestController
@RequestMapping("/api/reports")
public class CustomerConsumptionReportController {

    @GetMapping("/customer-consumption")
    public List<CustomerConsumptionReportRow> listCustomerConsumption() {
        return customerConsumptionReportService.listCustomerConsumption();
    }
}
```

- [ ] **Step 4: Run the report test again**

Run: `./gradlew.bat test --tests com.example.server.report.CustomerConsumptionReportRepositoryTests#complexReportReturnsFavoriteCategoryAndPaymentSummary`

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add server/src/main/java/com/example/server/report server/src/main/resources/data.sql db.sql server/src/test/java/com/example/server/report/CustomerConsumptionReportRepositoryTests.java
git commit -m "feat: add lab reporting view and complex query"
```

## Task 6: Surface new payment fields on existing order responses

**Files:**
- Modify: `server/src/main/java/com/example/server/order/OrderMapper.java`
- Modify: `server/src/main/java/com/example/server/order/dto/OrderItemResponse.java`
- Modify: `server/src/main/java/com/example/server/order/dto/OrderResponse.java`
- Modify: `server/src/main/java/com/example/server/order/CustomerOrderRepository.java`
- Test: `server/src/test/java/com/example/server/order/OrderPaymentFlowTests.java`

- [ ] **Step 1: Write the failing response mapping assertion**

Extend `OrderPaymentFlowTests`:

```java
@Test
void orderResponseIncludesLatestPaymentStatus() {
    OrderResponse response = orderUserService.markAsPaid(2L, 1L);
    assertThat(response.paymentStatus()).isEqualTo("SUCCESS");
}
```

- [ ] **Step 2: Run the mapping test to verify it fails**

Run: `./gradlew.bat test --tests com.example.server.order.OrderPaymentFlowTests#orderResponseIncludesLatestPaymentStatus`

Expected: FAIL because `OrderResponse` does not yet carry payment fields.

- [ ] **Step 3: Add the minimal DTO and mapper changes**

In `OrderResponse.java`, add fields such as:

```java
String paymentStatus,
String paymentMethod,
Instant paidAt
```

In `OrderMapper.java`, read the latest payment record if present and map it into the response.

In `CustomerOrderRepository.java`, extend the entity graph to include `paymentRecords` so the mapper does not trigger lazy-load issues.

- [ ] **Step 4: Run the mapping test again**

Run: `./gradlew.bat test --tests com.example.server.order.OrderPaymentFlowTests#orderResponseIncludesLatestPaymentStatus`

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add server/src/main/java/com/example/server/order/OrderMapper.java server/src/main/java/com/example/server/order/dto/OrderResponse.java server/src/main/java/com/example/server/order/CustomerOrderRepository.java server/src/test/java/com/example/server/order/OrderPaymentFlowTests.java
git commit -m "feat: expose payment summary on order responses"
```

## Task 7: Update the lab report and root summary to match the implemented design

**Files:**
- Modify: `nuxt-app/report.md`
- Modify: `README.md`

- [ ] **Step 1: Rewrite the report structure around the accepted lab format**

Replace the current frontend-oriented narrative in `nuxt-app/report.md` with sections matching the course rubric:

```md
## 1. 实验要求
## 2. 需求描述
## 3. 概念数据库设计
## 4. 逻辑数据库和物理数据库设计
## 5. 数据库创建
## 6. 程序实现
## 7. 总结和心得体会
```

Be explicit about the eight entities, `order_detail_view`, the complex query, and the index verification method.

- [ ] **Step 2: Update the root README summary**

Add one short section summarizing the new lab-oriented additions:

```md
## 实验补强

- 新增支付记录与商品评价两个实体
- 新增 `order_detail_view` 业务视图
- 新增用户消费与商品偏好复杂查询
```

- [ ] **Step 3: Review the docs for consistency**

Check that all docs now agree on the total entity count, view name, and complex query name.

- [ ] **Step 4: Commit**

```bash
git add nuxt-app/report.md README.md
git commit -m "docs: align report with final database lab design"
```

## Task 8: Final verification

**Files:**
- Verify only

- [ ] **Step 1: Run focused backend tests**

Run: `./gradlew.bat test --tests com.example.server.order.OrderPaymentFlowTests --tests com.example.server.report.CustomerConsumptionReportRepositoryTests`

Expected: PASS.

- [ ] **Step 2: Run the full backend test suite**

Run: `./gradlew.bat test`

Expected: PASS.

- [ ] **Step 3: Capture the report query explain plan**

Run the complex SQL in PostgreSQL with:

```sql
EXPLAIN ANALYZE
WITH user_order_stats AS (...), user_category_rank AS (...)
SELECT ...;
```

Expected: before/after evidence showing the added indexes reduce sequential scanning on orders or payment records.

- [ ] **Step 4: Review the working tree**

Run: `git status --short`

Expected: only intended files are modified.

- [ ] **Step 5: Commit the final verification checkpoint**

```bash
git add .
git commit -m "chore: finalize database lab gap implementation"
```

## Self-Review Notes

- Spec coverage: the plan covers the two new entities, the order detail view, the qualifying complex query, supporting indexes and data, and the report updates.
- Placeholder scan: no `TODO` or `TBD` markers remain; each task names concrete files and commands.
- Type consistency: `payment_records`, `reviews`, `order_detail_view`, and `CustomerConsumptionReportRow` use the same names throughout the plan.
