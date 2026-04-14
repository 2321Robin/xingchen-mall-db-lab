package com.example.server.common.dto;

import java.util.List;

public record PagedResponse<T>(
        List<T> items,
        long totalItems,
        int totalPages,
        int page,
        int pageSize,
        boolean hasNext,
        boolean hasPrevious
) {
}
