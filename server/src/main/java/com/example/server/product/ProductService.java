package com.example.server.product;

import java.math.BigDecimal;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import com.example.server.common.dto.PagedResponse;
import com.example.server.product.dto.CreateProductRequest;
import com.example.server.product.dto.ProductResponse;
import com.example.server.product.dto.UpdateProductRequest;

@Service
public class ProductService {

    private final ProductRepository productRepository;

    public ProductService(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    @Transactional(readOnly = true)
    public List<ProductResponse> listProducts() {
        return productRepository.findAll().stream()
                .map(ProductMapper::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public ProductResponse getProduct(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new ProductNotFoundException(id));
        return ProductMapper.toResponse(product);
    }

    @Transactional
    public ProductResponse createProduct(CreateProductRequest request) {
        if (productRepository.existsBySku(request.sku())) {
            throw new ProductValidationException("SKU 已存在，无法重复创建");
        }

        Product product = new Product();
        applyRequest(product, request.name(), request.sku(), request.category(), request.price(), request.stock(), request.status());

        Product saved = productRepository.save(product);
        return ProductMapper.toResponse(saved);
    }

    @Transactional
    public ProductResponse updateProduct(Long id, UpdateProductRequest request) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new ProductNotFoundException(id));

        if (!product.getSku().equals(request.sku()) && productRepository.existsBySku(request.sku())) {
            throw new ProductValidationException("SKU 已存在，无法重复使用");
        }

        applyRequest(product, request.name(), request.sku(), request.category(), request.price(), request.stock(), request.status());
        return ProductMapper.toResponse(product);
    }

    @Transactional
    public void deleteProduct(Long id) {
        if (!productRepository.existsById(id)) {
            throw new ProductNotFoundException(id);
        }
        productRepository.deleteById(id);
    }

    @Transactional(readOnly = true)
    public PagedResponse<ProductResponse> browseActiveProducts(String keyword, Set<String> categories, Pageable pageable) {
    Specification<Product> spec = Specification.allOf(ProductSpecifications.hasStatus(ProductStatus.ACTIVE));

        if (StringUtils.hasText(keyword)) {
            spec = spec.and(ProductSpecifications.keywordContains(keyword));
        }

        Set<String> normalizedCategories = categories == null
                ? new LinkedHashSet<>()
                : categories.stream()
                        .map(value -> value == null ? null : value.trim())
                        .filter(StringUtils::hasText)
                        .collect(Collectors.toCollection(LinkedHashSet::new));

        if (!normalizedCategories.isEmpty()) {
            spec = spec.and(ProductSpecifications.categoryIn(normalizedCategories));
        }

        Page<Product> page = productRepository.findAll(spec, pageable);

        if (page.getTotalPages() > 0 && page.isEmpty() && page.getNumber() >= page.getTotalPages()) {
            Pageable lastPageable = PageRequest.of(page.getTotalPages() - 1, pageable.getPageSize(), pageable.getSort());
            page = productRepository.findAll(spec, lastPageable);
        }

        List<ProductResponse> items = page.getContent().stream()
                .map(ProductMapper::toResponse)
                .toList();

        return new PagedResponse<>(
                items,
                page.getTotalElements(),
                page.getTotalPages(),
                page.getNumber() + 1,
                page.getSize(),
                page.hasNext(),
                page.hasPrevious()
        );
    }

    @Transactional(readOnly = true)
    public List<String> listActiveCategories() {
        return productRepository.findDistinctCategoryByStatus(ProductStatus.ACTIVE).stream()
                .filter(StringUtils::hasText)
                .toList();
    }

    private void applyRequest(Product product, String name, String sku, String category, BigDecimal price, Integer stock, ProductStatus status) {
        product.setName(name.trim());
        product.setSku(sku.trim());
        product.setCategory(category.trim());
        product.setPrice(price);
        product.setStock(stock);
        product.setStatus(status);
    }
}
