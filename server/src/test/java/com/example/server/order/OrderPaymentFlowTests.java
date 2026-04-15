package com.example.server.order;

import static org.assertj.core.api.Assertions.assertThat;

import java.math.BigDecimal;
import java.lang.reflect.Method;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.test.context.TestPropertySource;
import org.springframework.transaction.annotation.Transactional;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;

import com.example.server.cart.CartItem;
import com.example.server.cart.CartItemRepository;
import com.example.server.order.dto.CreateOrderRequest;
import com.example.server.order.dto.OrderResponse;
import com.example.server.payment.PaymentRecord;
import com.example.server.payment.PaymentRecordRepository;
import com.example.server.payment.PaymentStatus;
import com.example.server.product.Product;
import com.example.server.product.ProductRepository;
import com.example.server.product.ProductStatus;
import com.example.server.user.UserAccount;
import com.example.server.user.UserAccountRepository;
import com.example.server.user.UserRole;
import com.example.server.user.address.UserAddress;
import com.example.server.user.address.UserAddressRepository;

import jakarta.persistence.LockModeType;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;

@SpringBootTest
@TestPropertySource(properties = {
        "spring.datasource.url=jdbc:h2:mem:order-payment-flow-test;MODE=PostgreSQL;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE",
        "spring.datasource.driver-class-name=org.h2.Driver",
        "spring.datasource.username=sa",
        "spring.datasource.password=",
        "spring.jpa.hibernate.ddl-auto=update",
        "spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.H2Dialect",
        "spring.jpa.properties.hibernate.generate_statistics=true",
        "spring.jpa.defer-datasource-initialization=false",
        "spring.sql.init.mode=always",
        "spring.sql.init.schema-locations=classpath:order/order-payment-flow-legacy-schema.sql",
        "spring.sql.init.data-locations=classpath:order/order-payment-flow-legacy-data.sql"
})
@Transactional
class OrderPaymentFlowTests {

    @Autowired
    private OrderUserService orderUserService;

    @Autowired
    private CustomerOrderRepository customerOrderRepository;

    @Autowired
    private UserAccountRepository userAccountRepository;

    @Autowired
    private UserAddressRepository userAddressRepository;

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private CartItemRepository cartItemRepository;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private PaymentRecordRepository paymentRecordRepository;

    @Autowired
    private EntityManager entityManager;

    @Autowired
    private EntityManagerFactory entityManagerFactory;

    @Test
    void createOrderPersistsProductIdWithoutBreakingLegacyOrderItems() {
        Long legacyProductId = jdbcTemplate.queryForObject(
                "select product_id from order_items where id = 10",
                Long.class
        );
        assertThat(legacyProductId).isNull();

        UserAccount user = new UserAccount();
        user.setUsername("buyer01");
        user.setPasswordHash("{noop}secret");
        user.setEmail("buyer01@example.com");
        user.setPhone("13900000001");
        user.setRole(UserRole.CUSTOMER);
        user.setActive(true);
        user = userAccountRepository.save(user);

        UserAddress address = new UserAddress();
        address.setUser(user);
        address.setRecipientName("张三");
        address.setPhone("13900000001");
        address.setProvince("广东省");
        address.setCity("广州市");
        address.setDistrict("天河区");
        address.setStreet("科韵路 99 号");
        address.setPostalCode("510000");
        address.setDefault(true);
        address = userAddressRepository.save(address);

        Product product = new Product();
        product.setName("星辰蓝牙耳机");
        product.setSku("SC-AIR-01");
        product.setCategory("数码影音");
        product.setPrice(new BigDecimal("299.00"));
        product.setStock(10);
        product.setStatus(ProductStatus.ACTIVE);
        product = productRepository.save(product);
        Long productId = product.getId();
        String productName = product.getName();
        String productSku = product.getSku();

        CartItem cartItem = new CartItem();
        cartItem.setUserId(user.getId());
        cartItem.setProduct(product);
        cartItem.setQuantity(2);
        cartItemRepository.save(cartItem);

        var response = orderUserService.createOrder(user.getId(), new CreateOrderRequest(address.getId()));

        CustomerOrder savedOrder = customerOrderRepository.findByIdAndUserId(response.id(), user.getId()).orElseThrow();
        assertThat(savedOrder.getItems()).singleElement().satisfies(item -> {
            assertThat(item.getProductName()).isEqualTo(productName);
            assertThat(item.getProductSku()).isEqualTo(productSku);
            assertThat(item.getProductId()).isEqualTo(productId);
        });

        Long savedProductId = jdbcTemplate.queryForObject(
                "select product_id from order_items where order_id = ?",
                Long.class,
                savedOrder.getId()
        );
        assertThat(savedProductId).isEqualTo(productId);
    }

    @Test
    void markAsPaidCreatesSuccessfulPaymentRecord() {
        UserAccount user = new UserAccount();
        user.setUsername("buyer02");
        user.setPasswordHash("{noop}secret");
        user.setEmail("buyer02@example.com");
        user.setPhone("13900000002");
        user.setRole(UserRole.CUSTOMER);
        user.setActive(true);
        user = userAccountRepository.save(user);

        UserAddress address = new UserAddress();
        address.setUser(user);
        address.setRecipientName("李四");
        address.setPhone("13900000002");
        address.setProvince("广东省");
        address.setCity("深圳市");
        address.setDistrict("南山区");
        address.setStreet("科技园 1 号");
        address.setPostalCode("518000");
        address.setDefault(true);
        address = userAddressRepository.save(address);

        Product product = new Product();
        product.setName("星河充电器");
        product.setSku("SC-CHARGE-01");
        product.setCategory("数码配件");
        product.setPrice(new BigDecimal("99.00"));
        product.setStock(10);
        product.setStatus(ProductStatus.ACTIVE);
        product = productRepository.save(product);

        CartItem cartItem = new CartItem();
        cartItem.setUserId(user.getId());
        cartItem.setProduct(product);
        cartItem.setQuantity(1);
        cartItemRepository.save(cartItem);

        OrderResponse created = orderUserService.createOrder(user.getId(), new CreateOrderRequest(address.getId()));
        OrderResponse paid = orderUserService.markAsPaid(user.getId(), created.id());

        PaymentRecord record = paymentRecordRepository.findTopByOrderIdOrderByCreatedAtDesc(created.id()).orElseThrow();

        assertThat(paid.status()).isEqualTo(OrderStatus.PAID);
        assertThat(record.getPaymentStatus()).isEqualTo(PaymentStatus.SUCCESS);
        assertThat(record.getAmount()).isPositive();
        assertThat(record.getPaidAt()).isNotNull();
    }

    @Test
    void orderResponseIncludesLatestPaymentSummary() {
        UserAccount user = new UserAccount();
        user.setUsername("buyer03");
        user.setPasswordHash("{noop}secret");
        user.setEmail("buyer03@example.com");
        user.setPhone("13900000003");
        user.setRole(UserRole.CUSTOMER);
        user.setActive(true);
        user = userAccountRepository.save(user);

        UserAddress address = new UserAddress();
        address.setUser(user);
        address.setRecipientName("王五");
        address.setPhone("13900000003");
        address.setProvince("广东省");
        address.setCity("珠海市");
        address.setDistrict("香洲区");
        address.setStreet("情侣路 8 号");
        address.setPostalCode("519000");
        address.setDefault(true);
        address = userAddressRepository.save(address);

        Product product = new Product();
        product.setName("星河数据线");
        product.setSku("SC-CABLE-01");
        product.setCategory("数码配件");
        product.setPrice(new BigDecimal("39.00"));
        product.setStock(10);
        product.setStatus(ProductStatus.ACTIVE);
        product = productRepository.save(product);

        CartItem cartItem = new CartItem();
        cartItem.setUserId(user.getId());
        cartItem.setProduct(product);
        cartItem.setQuantity(1);
        cartItemRepository.save(cartItem);

        OrderResponse created = orderUserService.createOrder(user.getId(), new CreateOrderRequest(address.getId()));
        orderUserService.markAsPaid(user.getId(), created.id());

        entityManager.flush();
        entityManager.clear();

        OrderResponse fetched = orderUserService.getOrder(user.getId(), created.id());

        assertThat(fetched.paymentStatus()).isEqualTo("SUCCESS");
        assertThat(fetched.paymentMethod()).isEqualTo("ALIPAY");
        assertThat(fetched.paidAt()).isNotNull();
    }

    @Test
    void orderResponsePrefersLatestSuccessfulPaymentAndKeepsItemsLoaded() {
        UserAccount user = new UserAccount();
        user.setUsername("buyer04");
        user.setPasswordHash("{noop}secret");
        user.setEmail("buyer04@example.com");
        user.setPhone("13900000004");
        user.setRole(UserRole.CUSTOMER);
        user.setActive(true);
        user = userAccountRepository.save(user);

        UserAddress address = new UserAddress();
        address.setUser(user);
        address.setRecipientName("赵六");
        address.setPhone("13900000004");
        address.setProvince("广东省");
        address.setCity("佛山市");
        address.setDistrict("禅城区");
        address.setStreet("季华路 18 号");
        address.setPostalCode("528000");
        address.setDefault(true);
        address = userAddressRepository.save(address);

        Product product = new Product();
        product.setName("星云移动电源");
        product.setSku("SC-POWER-01");
        product.setCategory("数码配件");
        product.setPrice(new BigDecimal("129.00"));
        product.setStock(10);
        product.setStatus(ProductStatus.ACTIVE);
        product = productRepository.save(product);

        CartItem cartItem = new CartItem();
        cartItem.setUserId(user.getId());
        cartItem.setProduct(product);
        cartItem.setQuantity(2);
        cartItemRepository.save(cartItem);

        OrderResponse created = orderUserService.createOrder(user.getId(), new CreateOrderRequest(address.getId()));
        orderUserService.markAsPaid(user.getId(), created.id());

        CustomerOrder order = customerOrderRepository.findById(created.id()).orElseThrow();
        PaymentRecord pendingRecord = new PaymentRecord();
        pendingRecord.setOrder(order);
        pendingRecord.setPaymentNo("PAY-PENDING-" + created.orderNumber());
        pendingRecord.setPaymentMethod(com.example.server.payment.PaymentMethod.WECHAT);
        pendingRecord.setAmount(order.getTotalAmount());
        pendingRecord.setPaymentStatus(PaymentStatus.PENDING);
        pendingRecord.setPaidAt(null);
        paymentRecordRepository.saveAndFlush(pendingRecord);

        entityManager.clear();

        OrderResponse fetched = orderUserService.getOrder(user.getId(), created.id());

        assertThat(fetched.items()).singleElement().satisfies(item -> {
            assertThat(item.productName()).isEqualTo("星云移动电源");
            assertThat(item.productSku()).isEqualTo("SC-POWER-01");
            assertThat(item.quantity()).isEqualTo(2);
        });
        assertThat(fetched.paymentStatus()).isEqualTo("SUCCESS");
        assertThat(fetched.paymentMethod()).isEqualTo("ALIPAY");
        assertThat(fetched.paidAt()).isNotNull();
    }

    @Test
    void listOrdersLoadsPaymentSummariesInBatchWhileKeepingItemsLoaded() {
        UserAccount user = new UserAccount();
        user.setUsername("buyer05");
        user.setPasswordHash("{noop}secret");
        user.setEmail("buyer05@example.com");
        user.setPhone("13900000005");
        user.setRole(UserRole.CUSTOMER);
        user.setActive(true);
        user = userAccountRepository.save(user);

        UserAddress address = new UserAddress();
        address.setUser(user);
        address.setRecipientName("孙七");
        address.setPhone("13900000005");
        address.setProvince("广东省");
        address.setCity("东莞市");
        address.setDistrict("南城区");
        address.setStreet("鸿福路 66 号");
        address.setPostalCode("523000");
        address.setDefault(true);
        address = userAddressRepository.save(address);

        Product firstProduct = new Product();
        firstProduct.setName("星环键盘");
        firstProduct.setSku("SC-KEY-01");
        firstProduct.setCategory("数码配件");
        firstProduct.setPrice(new BigDecimal("199.00"));
        firstProduct.setStock(10);
        firstProduct.setStatus(ProductStatus.ACTIVE);
        firstProduct = productRepository.save(firstProduct);

        CartItem firstCartItem = new CartItem();
        firstCartItem.setUserId(user.getId());
        firstCartItem.setProduct(firstProduct);
        firstCartItem.setQuantity(1);
        cartItemRepository.save(firstCartItem);

        OrderResponse firstOrder = orderUserService.createOrder(user.getId(), new CreateOrderRequest(address.getId()));
        orderUserService.markAsPaid(user.getId(), firstOrder.id());

        Product secondProduct = new Product();
        secondProduct.setName("星环鼠标");
        secondProduct.setSku("SC-MOUSE-01");
        secondProduct.setCategory("数码配件");
        secondProduct.setPrice(new BigDecimal("129.00"));
        secondProduct.setStock(10);
        secondProduct.setStatus(ProductStatus.ACTIVE);
        secondProduct = productRepository.save(secondProduct);

        CartItem secondCartItem = new CartItem();
        secondCartItem.setUserId(user.getId());
        secondCartItem.setProduct(secondProduct);
        secondCartItem.setQuantity(2);
        cartItemRepository.save(secondCartItem);

        OrderResponse secondOrder = orderUserService.createOrder(user.getId(), new CreateOrderRequest(address.getId()));
        orderUserService.markAsPaid(user.getId(), secondOrder.id());

        entityManager.flush();
        entityManager.clear();

        Statistics statistics = entityManagerFactory.unwrap(SessionFactory.class).getStatistics();
        statistics.clear();

        java.util.List<OrderResponse> orders = orderUserService.listOrders(user.getId());

        assertThat(statistics.getPrepareStatementCount()).isEqualTo(3);
        assertThat(orders).hasSize(2);
        assertThat(orders).allSatisfy(order -> {
            assertThat(order.items()).singleElement();
            assertThat(order.paymentStatus()).isEqualTo("SUCCESS");
            assertThat(order.paymentMethod()).isEqualTo("ALIPAY");
            assertThat(order.paidAt()).isNotNull();
        });
    }

    @Test
    void paymentUpdateLookupUsesPessimisticWriteLock() throws NoSuchMethodException {
        Method method = CustomerOrderRepository.class.getMethod(
                "findByIdAndUserIdForUpdate",
                Long.class,
                Long.class
        );

        Lock lock = method.getAnnotation(Lock.class);

        assertThat(lock).isNotNull();
        assertThat(lock.value()).isEqualTo(LockModeType.PESSIMISTIC_WRITE);
    }
}
