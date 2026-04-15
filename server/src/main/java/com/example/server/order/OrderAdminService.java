package com.example.server.order;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.server.order.dto.OrderResponse;
import com.example.server.order.dto.UpdateOrderPriceRequest;
import com.example.server.order.dto.UpdateOrderStatusRequest;
import com.example.server.payment.PaymentRecordRepository;

@Service
public class OrderAdminService {

    private final CustomerOrderRepository customerOrderRepository;
    private final PaymentRecordRepository paymentRecordRepository;

    public OrderAdminService(CustomerOrderRepository customerOrderRepository,
                             PaymentRecordRepository paymentRecordRepository) {
        this.customerOrderRepository = customerOrderRepository;
        this.paymentRecordRepository = paymentRecordRepository;
    }

    @Transactional(readOnly = true)
    public List<OrderResponse> listOrders() {
        List<CustomerOrder> orders = customerOrderRepository.findAllByOrderByCreatedAtDesc();
        var paymentSummaries = paymentRecordRepository.findLatestPaymentSummariesByOrderIds(
                orders.stream().map(CustomerOrder::getId).toList()
        );
        return orders.stream()
                .map(order -> OrderMapper.toResponse(order, paymentSummaries.get(order.getId())))
                .toList();
    }

    @Transactional
    public OrderResponse updateOrderTotal(Long id, UpdateOrderPriceRequest request) {
        CustomerOrder order = customerOrderRepository.findById(id)
                .orElseThrow(() -> new OrderNotFoundException(id));

        BigDecimal normalized = request.totalAmount().setScale(2, RoundingMode.HALF_UP);
        order.setTotalAmount(normalized);
        return OrderMapper.toResponse(order, loadLatestPaymentSummary(order.getId()));
    }

    @Transactional
    public OrderResponse updateOrderStatus(Long id, UpdateOrderStatusRequest request) {
        CustomerOrder order = customerOrderRepository.findById(id)
                .orElseThrow(() -> new OrderNotFoundException(id));

        order.setStatus(request.status());
        return OrderMapper.toResponse(order, loadLatestPaymentSummary(order.getId()));
    }

    private OrderPaymentSummary loadLatestPaymentSummary(Long orderId) {
        return paymentRecordRepository.findLatestPaymentSummariesByOrderIds(List.of(orderId)).get(orderId);
    }
}
