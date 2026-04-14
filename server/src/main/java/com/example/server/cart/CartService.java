package com.example.server.cart;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.server.cart.dto.AddCartItemRequest;
import com.example.server.cart.dto.CartItemResponse;
import com.example.server.cart.dto.CartSummaryResponse;
import com.example.server.cart.dto.UpdateCartItemRequest;
import com.example.server.product.Product;
import com.example.server.product.ProductRepository;
import com.example.server.product.ProductStatus;

@Service
public class CartService {

    private final CartItemRepository cartItemRepository;
    private final ProductRepository productRepository;

    public CartService(CartItemRepository cartItemRepository, ProductRepository productRepository) {
        this.cartItemRepository = cartItemRepository;
        this.productRepository = productRepository;
    }

    @Transactional(readOnly = true)
    public CartSummaryResponse getCart(Long userId) {
        return buildSummary(userId);
    }

    @Transactional
    public CartSummaryResponse addItem(Long userId, AddCartItemRequest request) {
        int quantity = requirePositiveQuantity(request.quantity());
        Product product = productRepository.findById(request.productId())
                .orElseThrow(() -> new CartException("商品不存在或已下架"));

        ensureProductSellable(product);

        CartItem cartItem = cartItemRepository.findByUserIdAndProductId(userId, product.getId()).orElse(null);
        int newQuantity = quantity;

        if (cartItem != null) {
            newQuantity = cartItem.getQuantity() + quantity;
        } else {
            cartItem = new CartItem();
            cartItem.setUserId(userId);
            cartItem.setProduct(product);
        }

        ensureStockAvailable(product, newQuantity);

        cartItem.setQuantity(newQuantity);
        cartItemRepository.save(cartItem);

        return buildSummary(userId);
    }

    @Transactional
    public CartSummaryResponse updateItem(Long userId, Long itemId, UpdateCartItemRequest request) {
        int quantity = requirePositiveQuantity(request.quantity());
        CartItem cartItem = cartItemRepository.findByIdAndUserId(itemId, userId)
                .orElseThrow(() -> new CartItemNotFoundException(itemId));

        Product product = cartItem.getProduct();
        ensureProductSellable(product);
        ensureStockAvailable(product, quantity);

        cartItem.setQuantity(quantity);
        cartItemRepository.save(cartItem);

        return buildSummary(userId);
    }

    @Transactional
    public CartSummaryResponse removeItem(Long userId, Long itemId) {
        CartItem cartItem = cartItemRepository.findByIdAndUserId(itemId, userId)
                .orElseThrow(() -> new CartItemNotFoundException(itemId));

        cartItemRepository.delete(cartItem);
        return buildSummary(userId);
    }

    @Transactional
    public CartSummaryResponse clearCart(Long userId) {
        cartItemRepository.deleteByUserId(userId);
        return buildSummary(userId);
    }

    private int requirePositiveQuantity(Integer quantity) {
        if (quantity == null || quantity < 1) {
            throw new CartException("数量必须大于 0");
        }
        return quantity;
    }

    private void ensureProductSellable(Product product) {
        if (product.getStatus() != ProductStatus.ACTIVE) {
            throw new CartException("商品未上架或已下架");
        }

        if (product.getStock() <= 0) {
            throw new CartException("商品库存不足");
        }
    }

    private void ensureStockAvailable(Product product, int desiredQuantity) {
        if (desiredQuantity > product.getStock()) {
            throw new CartException("购买数量超出库存");
        }
    }

    private CartSummaryResponse buildSummary(Long userId) {
        List<CartItem> cartItems = cartItemRepository.findAllByUserIdOrderByCreatedAtDesc(userId);
        List<CartItemResponse> responses = cartItems.stream()
                .map(CartItemMapper::toResponse)
                .toList();

        int totalItems = responses.size();
        int totalQuantity = responses.stream()
                .map(CartItemResponse::quantity)
                .filter(q -> q != null)
                .mapToInt(Integer::intValue)
                .sum();

        BigDecimal totalAmount = responses.stream()
                .map(CartItemResponse::subtotal)
                .filter(subtotal -> subtotal != null)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        return new CartSummaryResponse(responses, totalItems, totalQuantity, totalAmount);
    }
}
