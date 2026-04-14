package com.example.server.cart;

public class CartItemNotFoundException extends CartException {

    public CartItemNotFoundException(Long id) {
        super("未找到购物车条目：" + id);
    }
}
