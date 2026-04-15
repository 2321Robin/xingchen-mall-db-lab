package com.example.server.order;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ThreadLocalRandom;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.server.cart.CartItem;
import com.example.server.cart.CartItemRepository;
import com.example.server.cart.CartService;
import com.example.server.cart.dto.CartSummaryResponse;
import com.example.server.order.dto.CheckoutSummaryResponse;
import com.example.server.order.dto.CreateOrderRequest;
import com.example.server.order.dto.OrderResponse;
import com.example.server.payment.PaymentMethod;
import com.example.server.payment.PaymentRecord;
import com.example.server.payment.PaymentRecordRepository;
import com.example.server.payment.PaymentStatus;
import com.example.server.product.Product;
import com.example.server.product.ProductStatus;
import com.example.server.user.UserAccount;
import com.example.server.user.UserAccountRepository;
import com.example.server.user.address.UserAddress;
import com.example.server.user.address.UserAddressRepository;
import com.example.server.user.address.dto.UserAddressResponse;

@Service
public class OrderUserService {

    private static final DateTimeFormatter ORDER_NUMBER_FORMAT = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    private final CartService cartService;
    private final CartItemRepository cartItemRepository;
    private final CustomerOrderRepository customerOrderRepository;
    private final PaymentRecordRepository paymentRecordRepository;
    private final UserAccountRepository userAccountRepository;
    private final UserAddressRepository userAddressRepository;

    public OrderUserService(CartService cartService,
                            CartItemRepository cartItemRepository,
                            CustomerOrderRepository customerOrderRepository,
                            PaymentRecordRepository paymentRecordRepository,
                            UserAccountRepository userAccountRepository,
                            UserAddressRepository userAddressRepository) {
        this.cartService = cartService;
        this.cartItemRepository = cartItemRepository;
        this.customerOrderRepository = customerOrderRepository;
        this.paymentRecordRepository = paymentRecordRepository;
        this.userAccountRepository = userAccountRepository;
        this.userAddressRepository = userAddressRepository;
    }

    @Transactional(readOnly = true)
    public CheckoutSummaryResponse getCheckoutSummary(Long userId) {
        UserAccount user = requireUser(userId);
        CartSummaryResponse cartSummary = cartService.getCart(userId);

        List<UserAddressResponse> addresses = userAddressRepository.findByUserOrderByIsDefaultDescUpdatedAtDesc(user)
                .stream()
                .map(this::toResponse)
                .toList();

        Long selectedAddressId = addresses.stream()
                .filter(UserAddressResponse::isDefault)
                .map(UserAddressResponse::id)
                .findFirst()
                .orElseGet(() -> addresses.stream()
                        .map(UserAddressResponse::id)
                        .findFirst()
                        .orElse(null));

        return new CheckoutSummaryResponse(cartSummary, addresses, selectedAddressId);
    }

    @Transactional(readOnly = true)
    public List<OrderResponse> listOrders(Long userId) {
        requireUser(userId);
        List<CustomerOrder> orders = customerOrderRepository.findByUserIdOrderByCreatedAtDesc(userId);
        Map<Long, OrderPaymentSummary> paymentSummaries = paymentRecordRepository.findLatestPaymentSummariesByOrderIds(
                orders.stream().map(CustomerOrder::getId).toList()
        );
        return orders.stream()
                .map(order -> OrderMapper.toResponse(order, paymentSummaries.get(order.getId())))
                .toList();
    }

    @Transactional(readOnly = true)
    public OrderResponse getOrder(Long userId, Long orderId) {
        requireUser(userId);
        CustomerOrder order = customerOrderRepository.findByIdAndUserId(orderId, userId)
                .orElseThrow(() -> new OrderNotFoundException(orderId));
        return OrderMapper.toResponse(order, loadLatestPaymentSummary(order.getId()));
    }

    @Transactional
    public OrderResponse createOrder(Long userId, CreateOrderRequest request) {
        if (request.addressId() == null) {
            throw new OrderException("请选择收货地址");
        }

        UserAccount user = requireUser(userId);
        UserAddress address = userAddressRepository.findByIdAndUser(request.addressId(), user)
                .orElseThrow(() -> new OrderException("收货地址不存在或已删除"));

        List<CartItem> cartItems = cartItemRepository.findAllByUserIdOrderByCreatedAtDesc(userId);
        if (cartItems.isEmpty()) {
            throw new OrderException("购物车为空，无法下单");
        }

        CustomerOrder order = new CustomerOrder();
        order.setOrderNumber(generateOrderNumber());
        order.setUser(user);
        order.setShippingAddressId(address.getId());
        order.setShippingRecipient(address.getRecipientName());
        order.setShippingPhone(address.getPhone());
        order.setShippingProvince(address.getProvince());
        order.setShippingCity(address.getCity());
        order.setShippingDistrict(address.getDistrict());
        order.setShippingStreet(address.getStreet());
        order.setShippingPostalCode(address.getPostalCode());

        BigDecimal totalAmount = BigDecimal.ZERO;

        for (CartItem cartItem : cartItems) {
            Product product = cartItem.getProduct();
            ensureProductSellable(product);

            Integer quantity = cartItem.getQuantity();
            if (quantity == null || quantity < 1) {
                throw new OrderException("购物车中存在无效的商品数量");
            }

            ensureStockAvailable(product, quantity);

            OrderItem orderItem = new OrderItem();
            orderItem.setOrder(order);
            orderItem.setProductName(product.getName());
            orderItem.setProductSku(product.getSku());
            orderItem.setProductId(product.getId());
            orderItem.setQuantity(quantity);
            orderItem.setUnitPrice(product.getPrice());
            order.getItems().add(orderItem);

            BigDecimal subtotal = product.getPrice().multiply(BigDecimal.valueOf(quantity.longValue()));
            totalAmount = totalAmount.add(subtotal);
            product.setStock(product.getStock() - quantity);
        }

        order.setTotalAmount(totalAmount.setScale(2, RoundingMode.HALF_UP));

        CustomerOrder saved = customerOrderRepository.save(order);
        cartItemRepository.deleteByUserId(userId);

        return OrderMapper.toResponse(saved);
    }

    @Transactional
    public OrderResponse markAsPaid(Long userId, Long orderId) {
        requireUser(userId);
        CustomerOrder order = customerOrderRepository.findByIdAndUserIdForUpdate(orderId, userId)
                .orElseThrow(() -> new OrderNotFoundException(orderId));

        if (order.getStatus() == OrderStatus.PAID) {
            throw new OrderException("订单已支付，无需重复操作");
        }

        if (order.getStatus() != OrderStatus.PENDING_PAYMENT) {
            throw new OrderException("当前订单状态不支持支付更新");
        }

        PaymentRecord paymentRecord = new PaymentRecord();
        paymentRecord.setOrder(order);
        paymentRecord.setPaymentNo("PAY-" + order.getOrderNumber());
        paymentRecord.setPaymentMethod(PaymentMethod.ALIPAY);
        paymentRecord.setAmount(order.getTotalAmount());
        paymentRecord.setPaymentStatus(PaymentStatus.SUCCESS);
        paymentRecord.setPaidAt(Instant.now());
        order.getPaymentRecords().add(paymentRecord);
        order.setStatus(OrderStatus.PAID);

        return OrderMapper.toResponse(order, OrderPaymentSummary.from(paymentRecord));
    }

    private OrderPaymentSummary loadLatestPaymentSummary(Long orderId) {
        return paymentRecordRepository.findLatestPaymentSummariesByOrderIds(List.of(orderId)).get(orderId);
    }

    private UserAccount requireUser(Long userId) {
        return userAccountRepository.findById(userId)
                .orElseThrow(() -> new OrderException("未找到对应用户，无法继续下单"));
    }

    private UserAddressResponse toResponse(UserAddress address) {
        return new UserAddressResponse(
                address.getId(),
                address.getRecipientName(),
                address.getPhone(),
                address.getProvince(),
                address.getCity(),
                address.getDistrict(),
                address.getStreet(),
                address.getPostalCode(),
                address.isDefault(),
                address.getCreatedAt(),
                address.getUpdatedAt()
        );
    }

    private void ensureProductSellable(Product product) {
        if (product.getStatus() != ProductStatus.ACTIVE) {
            throw new OrderException("商品状态已更新，请返回购物车重新确认");
        }

        if (product.getStock() == null || product.getStock() <= 0) {
            throw new OrderException("商品库存不足，无法下单");
        }
    }

    private void ensureStockAvailable(Product product, int desiredQuantity) {
        if (product.getStock() < desiredQuantity) {
            throw new OrderException("商品库存不足，无法满足购买数量");
        }
    }

    private String generateOrderNumber() {
        String candidate;
        do {
            String timestamp = ORDER_NUMBER_FORMAT.format(LocalDateTime.now());
            int random = ThreadLocalRandom.current().nextInt(1000, 10000);
            candidate = "ORD-" + timestamp + "-" + random;
        } while (customerOrderRepository.existsByOrderNumber(candidate));
        return candidate;
    }
}
