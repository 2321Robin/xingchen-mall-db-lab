package com.example.server.user;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.server.user.dto.UpdateUserProfileRequest;
import com.example.server.user.dto.UserProfileResponse;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/user/profile")
public class UserProfileController {

    private final UserProfileService userProfileService;

    public UserProfileController(UserProfileService userProfileService) {
        this.userProfileService = userProfileService;
    }

    @GetMapping("/{userId}")
    public UserProfileResponse getProfile(@PathVariable Long userId) {
        return userProfileService.getProfile(userId);
    }

    @PutMapping("/{userId}")
    public UserProfileResponse updateProfile(@PathVariable Long userId, @Valid @RequestBody UpdateUserProfileRequest request) {
        return userProfileService.updateProfile(userId, request);
    }
}
