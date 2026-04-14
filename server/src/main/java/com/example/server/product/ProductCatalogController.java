package com.example.server.product;

import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.server.common.dto.PagedResponse;
import com.example.server.product.dto.ProductResponse;

@RestController
@RequestMapping("/api/catalog/products")
public class ProductCatalogController {

    private final ProductService productService;

    public ProductCatalogController(ProductService productService) {
        this.productService = productService;
    }

    @GetMapping
    public PagedResponse<ProductResponse> browseProducts(
            @RequestParam(name = "page", defaultValue = "1") int page,
            @RequestParam(name = "pageSize", defaultValue = "12") int pageSize,
            @RequestParam(name = "keyword", required = false) String keyword,
            @RequestParam(name = "category", required = false) String category,
            @RequestParam(name = "categories", required = false) Set<String> categories
    ) {
        int safePage = Math.max(page, 1);
        int safePageSize = Math.min(Math.max(pageSize, 1), 60);

        Pageable pageable = PageRequest.of(safePage - 1, safePageSize, Sort.by(Sort.Direction.DESC, "updatedAt"));

        if (categories == null) {
            categories = Collections.emptySet();
        }

        Set<String> combinedCategories = new LinkedHashSet<>(categories);
        if (StringUtils.hasText(category)) {
            combinedCategories.add(category.trim());
        }

        return productService.browseActiveProducts(keyword, combinedCategories, pageable);
    }

    @GetMapping("/categories")
    public List<String> listCategories() {
        return productService.listActiveCategories();
    }
}
