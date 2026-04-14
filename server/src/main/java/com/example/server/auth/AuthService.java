package com.example.server.auth;

import java.util.Locale;
import java.util.Optional;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.server.user.UserAccount;
import com.example.server.user.UserAccountRepository;
import com.example.server.user.UserRole;

@Service
public class AuthService {

    private final UserAccountRepository userAccountRepository;
    private final PasswordEncoder passwordEncoder;

    public AuthService(UserAccountRepository userAccountRepository, PasswordEncoder passwordEncoder) {
        this.userAccountRepository = userAccountRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional(readOnly = true)
    public LoginResponse authenticate(LoginRequest request) {
        String identifier = request.account().trim();
        if (identifier.isEmpty()) {
            throw new InvalidCredentialsException("请输入有效的账号");
        }

        UserAccount account = resolveAccount(identifier)
                .orElseThrow(() -> new InvalidCredentialsException("账号或密码错误"));

        if (!account.isActive()) {
            throw new InvalidCredentialsException("账号已被禁用，请联系管理员");
        }

        if (!passwordEncoder.matches(request.password(), account.getPasswordHash())) {
            throw new InvalidCredentialsException("账号或密码错误");
        }

        return new LoginResponse(
                account.getId(),
                account.getUsername(),
                account.getRole(),
                account.getEmail(),
                buildWelcomeMessage(account.getRole())
        );
    }

    private String buildWelcomeMessage(UserRole role) {
        return role == UserRole.ADMIN ? "欢迎回来，管理员" : "登录成功";
    }

    private Optional<UserAccount> resolveAccount(String account) {
        String trimmed = account.trim();
        String emailCandidate = trimmed.toLowerCase(Locale.ROOT);
        return userAccountRepository.findByUsername(trimmed)
                .or(() -> userAccountRepository.findByEmail(emailCandidate))
                .or(() -> userAccountRepository.findByPhone(trimmed));
    }

    @Transactional
    public void changePassword(ChangePasswordRequest request) {
        String username = request.username().trim();
        if (username.isEmpty()) {
            throw new InvalidCredentialsException("用户名不能为空");
        }

        UserAccount account = userAccountRepository.findByUsername(username)
                .orElseThrow(() -> new InvalidCredentialsException("账号不存在"));

        if (!passwordEncoder.matches(request.oldPassword(), account.getPasswordHash())) {
            throw new InvalidCredentialsException("旧密码不正确");
        }

        account.setPasswordHash(passwordEncoder.encode(request.newPassword()));
    }

    @Transactional
    public RegisterResponse register(RegisterRequest request) {
        String username = request.username().trim();
        String email = request.email().trim().toLowerCase(Locale.ROOT);
        String phone = request.phone().trim();
        String password = request.password();

        if (username.isEmpty()) {
            throw new RegistrationException("请输入账号昵称");
        }

        if (userAccountRepository.findByUsername(username).isPresent()) {
            throw new RegistrationException("该账号昵称已被占用，请更换后重试");
        }

        userAccountRepository.findByEmail(email)
                .ifPresent(existing -> {
                    throw new RegistrationException("该邮箱已注册，请直接登录或更换邮箱");
                });

        if (!phone.isEmpty()) {
            userAccountRepository.findByPhone(phone)
                    .ifPresent(existing -> {
                        throw new RegistrationException("该手机号已注册，请直接登录或更换手机号");
                    });
        }

        UserAccount account = new UserAccount();
        account.setUsername(username);
        account.setEmail(email);
        account.setPhone(phone);
        account.setPasswordHash(passwordEncoder.encode(password));
        account.setRole(UserRole.CUSTOMER);
        account.setActive(true);

        UserAccount saved = userAccountRepository.save(account);
        return new RegisterResponse(saved.getId(), saved.getUsername(), "注册成功");
    }

    @Transactional
    public void resetPassword(ForgotPasswordRequest request) {
        String identifier = request.identifier().trim();
        if (identifier.isEmpty()) {
            throw new InvalidCredentialsException("请输入账号信息");
        }

        String email = request.email().trim().toLowerCase(Locale.ROOT);
        UserAccount account = resolveAccount(identifier)
                .orElseThrow(() -> new InvalidCredentialsException("账号不存在或信息不匹配"));

        if (!account.isActive()) {
            throw new InvalidCredentialsException("账号已被禁用，请联系管理员");
        }

        if (!account.getEmail().equalsIgnoreCase(email)) {
            throw new InvalidCredentialsException("账号与邮箱信息不匹配");
        }

        account.setPasswordHash(passwordEncoder.encode(request.newPassword()));
    }
}
