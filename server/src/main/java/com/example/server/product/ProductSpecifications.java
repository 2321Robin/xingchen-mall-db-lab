package com.example.server.product;

import java.util.Set;

import org.springframework.data.jpa.domain.Specification;

final class ProductSpecifications {

    private ProductSpecifications() {
    }

    static Specification<Product> hasStatus(ProductStatus status) {
        return (root, query, builder) -> builder.equal(root.get("status"), status);
    }

    static Specification<Product> keywordContains(String keyword) {
        String pattern = "%" + keyword.trim().toLowerCase() + "%";
        return (root, query, builder) -> builder.or(
                builder.like(builder.lower(root.get("name")), pattern),
                builder.like(builder.lower(root.get("sku")), pattern)
        );
    }

    static Specification<Product> categoryIn(Set<String> categories) {
        return (root, query, builder) -> root.get("category").in(categories);
    }
}
