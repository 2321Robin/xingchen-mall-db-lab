package com.example.server.payment;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface PaymentRecordRepository extends JpaRepository<PaymentRecord, Long> {

    Optional<PaymentRecord> findTopByOrderIdOrderByCreatedAtDesc(Long orderId);
}
