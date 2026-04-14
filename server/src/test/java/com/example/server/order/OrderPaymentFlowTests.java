package com.example.server.order;

import static org.assertj.core.api.Assertions.assertThat;

import java.math.BigDecimal;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;
import org.springframework.transaction.annotation.Transactional;

import com.example.server.cart.CartItem;
import com.example.server.cart.CartItemRepository;
import com.example.server.order.dto.CreateOrderRequest;
import com.example.server.product.Product;
import com.example.server.product.ProductRepository;
import com.example.server.product.ProductStatus;
import com.example.server.user.UserAccount;
import com.example.server.user.UserAccountRepository;
import com.example.server.user.UserRole;
import com.example.server.user.address.UserAddress;
import com.example.server.user.address.UserAddressRepository;

@SpringBootTest
@TestPropertySource(properties = {
        "spring.datasource.url=jdbc:h2:mem:order-payment-flow-test;MODE=PostgreSQL;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE",
        "spring.datasource.driver-class-name=org.h2.Driver",
        "spring.datasource.username=sa",
        "spring.datasource.password=",
        "spring.jpa.hibernate.ddl-auto=create-drop",
        "spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.H2Dialect",
        "spring.sql.init.mode=never"
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

    @Test
    void createOrderPersistsProductIdOnOrderItems() {
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
    }
}
