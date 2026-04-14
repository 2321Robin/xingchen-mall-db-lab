package com.example.server.product;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ProductRepository extends JpaRepository<Product, Long>, JpaSpecificationExecutor<Product> {
    boolean existsBySku(String sku);
    Optional<Product> findBySku(String sku);

    @Query("select distinct p.category from Product p where p.status = :status order by p.category asc")
    List<String> findDistinctCategoryByStatus(@Param("status") ProductStatus status);
}
