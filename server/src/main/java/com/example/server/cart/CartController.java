package com.example.server.cart;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.server.cart.dto.AddCartItemRequest;
import com.example.server.cart.dto.CartSummaryResponse;
import com.example.server.cart.dto.UpdateCartItemRequest;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/user/cart")
public class CartController {

    private final CartService cartService;

    public CartController(CartService cartService) {
        this.cartService = cartService;
    }

    @GetMapping("/{userId}")
    public CartSummaryResponse list(@PathVariable Long userId) {
        return cartService.getCart(userId);
    }

    @PostMapping("/{userId}")
    public CartSummaryResponse add(@PathVariable Long userId, @Valid @RequestBody AddCartItemRequest request) {
        return cartService.addItem(userId, request);
    }

    @PutMapping("/{userId}/{itemId}")
    public CartSummaryResponse update(@PathVariable Long userId,
                                      @PathVariable Long itemId,
                                      @Valid @RequestBody UpdateCartItemRequest request) {
        return cartService.updateItem(userId, itemId, request);
    }

    @DeleteMapping("/{userId}/{itemId}")
    public CartSummaryResponse remove(@PathVariable Long userId, @PathVariable Long itemId) {
        return cartService.removeItem(userId, itemId);
    }

    @DeleteMapping("/{userId}")
    public CartSummaryResponse clear(@PathVariable Long userId) {
        return cartService.clearCart(userId);
    }
}
