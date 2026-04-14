package com.example.server.order;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.server.order.dto.OrderResponse;
import com.example.server.order.dto.UpdateOrderPriceRequest;
import com.example.server.order.dto.UpdateOrderStatusRequest;

@Service
public class OrderAdminService {

    private final CustomerOrderRepository customerOrderRepository;

    public OrderAdminService(CustomerOrderRepository customerOrderRepository) {
        this.customerOrderRepository = customerOrderRepository;
    }

    @Transactional(readOnly = true)
    public List<OrderResponse> listOrders() {
        return customerOrderRepository.findAllByOrderByCreatedAtDesc().stream()
                .map(OrderMapper::toResponse)
                .toList();
    }

    @Transactional
    public OrderResponse updateOrderTotal(Long id, UpdateOrderPriceRequest request) {
    CustomerOrder order = customerOrderRepository.findById(id)
        .orElseThrow(() -> new OrderNotFoundException(id));

    BigDecimal normalized = request.totalAmount().setScale(2, RoundingMode.HALF_UP);
        order.setTotalAmount(normalized);
        return OrderMapper.toResponse(order);
    }

    @Transactional
    public OrderResponse updateOrderStatus(Long id, UpdateOrderStatusRequest request) {
        CustomerOrder order = customerOrderRepository.findById(id)
                .orElseThrow(() -> new OrderNotFoundException(id));

        order.setStatus(request.status());
        return OrderMapper.toResponse(order);
    }
}
