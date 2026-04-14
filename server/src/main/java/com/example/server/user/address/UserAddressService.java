package com.example.server.user.address;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import com.example.server.user.UserAccount;
import com.example.server.user.UserAccountRepository;
import com.example.server.user.address.dto.CreateUserAddressRequest;
import com.example.server.user.address.dto.UpdateUserAddressRequest;
import com.example.server.user.address.dto.UserAddressResponse;

@Service
public class UserAddressService {

    private final UserAccountRepository userAccountRepository;
    private final UserAddressRepository userAddressRepository;

    public UserAddressService(UserAccountRepository userAccountRepository, UserAddressRepository userAddressRepository) {
        this.userAccountRepository = userAccountRepository;
        this.userAddressRepository = userAddressRepository;
    }

    @Transactional(readOnly = true)
    public List<UserAddressResponse> list(Long userId) {
        UserAccount user = getUser(userId);
        return userAddressRepository.findByUserOrderByIsDefaultDescUpdatedAtDesc(user).stream()
                .map(UserAddressMapper::toResponse)
                .toList();
    }

    @Transactional
    public UserAddressResponse create(Long userId, CreateUserAddressRequest request) {
        UserAccount user = getUser(userId);
        UserAddress address = new UserAddress();
        address.setUser(user);
        applyRequest(address,
                request.recipientName(),
                request.phone(),
                request.province(),
                request.city(),
                request.district(),
                request.street(),
                request.postalCode());

        boolean hasDefault = userAddressRepository.findByUserAndIsDefaultTrue(user).isPresent();
        boolean shouldBeDefault = request.isDefault() || !hasDefault;
        address.setDefault(shouldBeDefault);

        UserAddress saved = userAddressRepository.save(address);

        if (saved.isDefault()) {
            userAddressRepository.clearDefaultExcept(user, saved.getId());
        }

        return UserAddressMapper.toResponse(saved);
    }

    @Transactional
    public UserAddressResponse update(Long userId, Long addressId, UpdateUserAddressRequest request) {
        UserAccount user = getUser(userId);
        UserAddress address = userAddressRepository.findByIdAndUser(addressId, user)
                .orElseThrow(() -> new UserAddressNotFoundException(addressId));

        boolean wasDefault = address.isDefault();

        applyRequest(address,
                request.recipientName(),
                request.phone(),
                request.province(),
                request.city(),
                request.district(),
                request.street(),
                request.postalCode());

        address.setDefault(request.isDefault());

        if (address.isDefault()) {
            userAddressRepository.clearDefaultExcept(user, address.getId());
        } else if (wasDefault) {
            boolean reassigned = ensureDefaultForUser(user, address.getId());
            if (!reassigned) {
                address.setDefault(true);
                throw new UserAddressException("至少保留一个默认地址");
            }
        }

        return UserAddressMapper.toResponse(address);
    }

    @Transactional
    public void delete(Long userId, Long addressId) {
        UserAccount user = getUser(userId);
        UserAddress address = userAddressRepository.findByIdAndUser(addressId, user)
                .orElseThrow(() -> new UserAddressNotFoundException(addressId));

        boolean wasDefault = address.isDefault();

        userAddressRepository.delete(address);

        if (wasDefault) {
            ensureDefaultForUser(user, addressId);
        }
    }

    @Transactional
    public UserAddressResponse setDefault(Long userId, Long addressId) {
        UserAccount user = getUser(userId);
        UserAddress address = userAddressRepository.findByIdAndUser(addressId, user)
                .orElseThrow(() -> new UserAddressNotFoundException(addressId));

        if (!address.isDefault()) {
            address.setDefault(true);
        }

        userAddressRepository.clearDefaultExcept(user, address.getId());

        return UserAddressMapper.toResponse(address);
    }

    private boolean ensureDefaultForUser(UserAccount user, Long excludeId) {
        boolean hasDefault = userAddressRepository.findByUserAndIsDefaultTrue(user).isPresent();
        if (hasDefault) {
            return true;
        }

        return userAddressRepository.findByUserOrderByIsDefaultDescUpdatedAtDesc(user).stream()
                .filter(item -> excludeId == null || !item.getId().equals(excludeId))
                .findFirst()
                .map(item -> {
                    item.setDefault(true);
                    return true;
                })
                .orElse(false);
    }

    private UserAccount getUser(Long userId) {
        return userAccountRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "未找到用户，ID=" + userId));
    }

    private void applyRequest(UserAddress address,
                              String recipientName,
                              String phone,
                              String province,
                              String city,
                              String district,
                              String street,
                              String postalCode) {
        address.setRecipientName(recipientName.trim());
        address.setPhone(phone.trim());
        address.setProvince(province.trim());
        address.setCity(city.trim());
        address.setDistrict(district.trim());
        address.setStreet(street.trim());
        address.setPostalCode(postalCode == null || postalCode.isBlank() ? null : postalCode.trim());
    }
}
