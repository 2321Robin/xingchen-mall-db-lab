package com.example.server.user.address;

import java.util.List;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.server.user.address.dto.CreateUserAddressRequest;
import com.example.server.user.address.dto.UpdateUserAddressRequest;
import com.example.server.user.address.dto.UserAddressResponse;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/user/addresses")
public class UserAddressController {

    private final UserAddressService userAddressService;

    public UserAddressController(UserAddressService userAddressService) {
        this.userAddressService = userAddressService;
    }

    @GetMapping("/{userId}")
    public List<UserAddressResponse> list(@PathVariable Long userId) {
        return userAddressService.list(userId);
    }

    @PostMapping("/{userId}")
    public UserAddressResponse create(@PathVariable Long userId, @Valid @RequestBody CreateUserAddressRequest request) {
        return userAddressService.create(userId, request);
    }

    @PutMapping("/{userId}/{addressId}")
    public UserAddressResponse update(@PathVariable Long userId,
                                      @PathVariable Long addressId,
                                      @Valid @RequestBody UpdateUserAddressRequest request) {
        return userAddressService.update(userId, addressId, request);
    }

    @DeleteMapping("/{userId}/{addressId}")
    public void delete(@PathVariable Long userId, @PathVariable Long addressId) {
        userAddressService.delete(userId, addressId);
    }

    @PostMapping("/{userId}/{addressId}/default")
    public UserAddressResponse setDefault(@PathVariable Long userId, @PathVariable Long addressId) {
        return userAddressService.setDefault(userId, addressId);
    }
}
