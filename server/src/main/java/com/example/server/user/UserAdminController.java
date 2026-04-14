package com.example.server.user;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.server.user.dto.UpdateUserStatusRequest;
import com.example.server.user.dto.UserSummaryResponse;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/admin/users")
public class UserAdminController {

    private final UserAdminService userAdminService;

    public UserAdminController(UserAdminService userAdminService) {
        this.userAdminService = userAdminService;
    }

    @GetMapping
    public List<UserSummaryResponse> listUsers() {
        return userAdminService.listUsers();
    }

    @PutMapping("/{id}/status")
    public UserSummaryResponse updateUserStatus(@PathVariable Long id, @Valid @RequestBody UpdateUserStatusRequest request) {
        return userAdminService.updateStatus(id, request);
    }
}
