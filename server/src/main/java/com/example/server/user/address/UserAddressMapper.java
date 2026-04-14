package com.example.server.user.address;

import com.example.server.user.address.dto.UserAddressResponse;

final class UserAddressMapper {

    private UserAddressMapper() {
    }

    static UserAddressResponse toResponse(UserAddress address) {
        return new UserAddressResponse(
                address.getId(),
                address.getRecipientName(),
                address.getPhone(),
                address.getProvince(),
                address.getCity(),
                address.getDistrict(),
                address.getStreet(),
                address.getPostalCode(),
                address.isDefault(),
                address.getCreatedAt(),
                address.getUpdatedAt()
        );
    }
}
