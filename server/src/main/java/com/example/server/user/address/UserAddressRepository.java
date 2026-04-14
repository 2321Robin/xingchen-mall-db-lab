package com.example.server.user.address;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.example.server.user.UserAccount;

public interface UserAddressRepository extends JpaRepository<UserAddress, Long> {

    List<UserAddress> findByUserOrderByIsDefaultDescUpdatedAtDesc(UserAccount user);

    Optional<UserAddress> findByIdAndUser(Long id, UserAccount user);

    Optional<UserAddress> findFirstByUserOrderByIsDefaultDescUpdatedAtDesc(UserAccount user);

    Optional<UserAddress> findByUserAndIsDefaultTrue(UserAccount user);

    @Modifying
    @Query("update UserAddress ua set ua.isDefault = false where ua.user = :user and ua.id <> :addressId")
    void clearDefaultExcept(@Param("user") UserAccount user, @Param("addressId") Long addressId);
}
