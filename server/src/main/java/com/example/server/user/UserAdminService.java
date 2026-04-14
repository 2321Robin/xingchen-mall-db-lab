package com.example.server.user;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.server.user.dto.UpdateUserStatusRequest;
import com.example.server.user.dto.UserSummaryResponse;

@Service
public class UserAdminService {

    private final UserAccountRepository userAccountRepository;

    public UserAdminService(UserAccountRepository userAccountRepository) {
        this.userAccountRepository = userAccountRepository;
    }

    @Transactional(readOnly = true)
    public List<UserSummaryResponse> listUsers() {
        return userAccountRepository.findAll().stream()
                .map(UserMapper::toSummary)
                .toList();
    }

    @Transactional
    public UserSummaryResponse updateStatus(Long id, UpdateUserStatusRequest request) {
        UserAccount account = userAccountRepository.findById(id)
                .orElseThrow(() -> new UserNotFoundException(id));

        account.setActive(Boolean.TRUE.equals(request.active()));
        return UserMapper.toSummary(account);
    }
}
