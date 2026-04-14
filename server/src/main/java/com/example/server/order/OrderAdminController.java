package com.example.server.order;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.server.order.dto.OrderResponse;
import com.example.server.order.dto.UpdateOrderPriceRequest;
import com.example.server.order.dto.UpdateOrderStatusRequest;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/admin/orders")
public class OrderAdminController {

    private final OrderAdminService orderAdminService;

    public OrderAdminController(OrderAdminService orderAdminService) {
        this.orderAdminService = orderAdminService;
    }

    @GetMapping
    public List<OrderResponse> listOrders() {
        return orderAdminService.listOrders();
    }

    @PutMapping("/{id}/price")
    public OrderResponse updateOrderPrice(@PathVariable Long id, @Valid @RequestBody UpdateOrderPriceRequest request) {
        return orderAdminService.updateOrderTotal(id, request);
    }

    @PutMapping("/{id}/status")
    public OrderResponse updateOrderStatus(@PathVariable Long id, @Valid @RequestBody UpdateOrderStatusRequest request) {
        return orderAdminService.updateOrderStatus(id, request);
    }
}
