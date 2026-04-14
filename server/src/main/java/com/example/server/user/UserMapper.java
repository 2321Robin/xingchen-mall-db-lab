package com.example.server.user;

import com.example.server.user.dto.UserProfileResponse;
import com.example.server.user.dto.UserSummaryResponse;

final class UserMapper {

    private UserMapper() {
    }

    static UserSummaryResponse toSummary(UserAccount account) {
        return new UserSummaryResponse(
                account.getId(),
                account.getUsername(),
                account.getEmail(),
                account.getPhone(),
                account.getRole(),
                account.isActive(),
                account.getCreatedAt(),
                account.getUpdatedAt()
        );
    }

    static UserProfileResponse toProfile(UserAccount account) {
        return new UserProfileResponse(
                account.getId(),
                account.getUsername(),
                account.getEmail(),
                account.getPhone(),
                account.getRole(),
                account.isActive(),
                account.getCreatedAt(),
                account.getUpdatedAt()
        );
    }
}
