package com.example.server.user;

import java.util.Locale;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.server.user.dto.UpdateUserProfileRequest;
import com.example.server.user.dto.UserProfileResponse;

@Service
public class UserProfileService {

    private final UserAccountRepository userAccountRepository;

    public UserProfileService(UserAccountRepository userAccountRepository) {
        this.userAccountRepository = userAccountRepository;
    }

    @Transactional(readOnly = true)
    public UserProfileResponse getProfile(Long userId) {
        UserAccount account = userAccountRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException(userId));
        return UserMapper.toProfile(account);
    }

    @Transactional
    public UserProfileResponse updateProfile(Long userId, UpdateUserProfileRequest request) {
        UserAccount account = userAccountRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException(userId));

        String username = request.username().trim();
        String email = request.email().trim().toLowerCase(Locale.ROOT);
        String phone = request.phone() == null ? null : request.phone().trim();

        if (username.isEmpty()) {
            throw new UserProfileException("请输入昵称");
        }

        if (email.isEmpty()) {
            throw new UserProfileException("请输入邮箱地址");
        }

        userAccountRepository.findByUsername(username)
                .filter(existing -> !existing.getId().equals(userId))
                .ifPresent(existing -> {
                    throw new UserProfileException("该昵称已被占用，请更换后重试");
                });

        userAccountRepository.findByEmail(email)
                .filter(existing -> !existing.getId().equals(userId))
                .ifPresent(existing -> {
                    throw new UserProfileException("该邮箱已绑定其他账号，请更换后重试");
                });

        if (phone != null && !phone.isEmpty()) {
            userAccountRepository.findByPhone(phone)
                    .filter(existing -> !existing.getId().equals(userId))
                    .ifPresent(existing -> {
                        throw new UserProfileException("该手机号已绑定其他账号，请更换后重试");
                    });
        } else {
            phone = null;
        }

        account.setUsername(username);
        account.setEmail(email);
        account.setPhone(phone);

        return UserMapper.toProfile(account);
    }
}
