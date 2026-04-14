package com.example.server.order;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.server.order.dto.CheckoutSummaryResponse;
import com.example.server.order.dto.CreateOrderRequest;
import com.example.server.order.dto.OrderResponse;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/user/orders")
public class OrderUserController {

    private final OrderUserService orderUserService;

    public OrderUserController(OrderUserService orderUserService) {
        this.orderUserService = orderUserService;
    }

    @GetMapping("/{userId}/checkout")
    public CheckoutSummaryResponse checkout(@PathVariable Long userId) {
        return orderUserService.getCheckoutSummary(userId);
    }

    @GetMapping("/{userId}")
    public List<OrderResponse> list(@PathVariable Long userId) {
        return orderUserService.listOrders(userId);
    }

    @GetMapping("/{userId}/{orderId}")
    public OrderResponse detail(@PathVariable Long userId, @PathVariable Long orderId) {
        return orderUserService.getOrder(userId, orderId);
    }

    @PostMapping("/{userId}")
    public OrderResponse create(@PathVariable Long userId, @Valid @RequestBody CreateOrderRequest request) {
        return orderUserService.createOrder(userId, request);
    }

    @PostMapping("/{userId}/{orderId}/pay")
    public OrderResponse pay(@PathVariable Long userId, @PathVariable Long orderId) {
        return orderUserService.markAsPaid(userId, orderId);
    }
}
