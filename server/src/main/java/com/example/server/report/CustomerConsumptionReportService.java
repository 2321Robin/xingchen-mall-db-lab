package com.example.server.report;

import java.util.List;

import org.springframework.stereotype.Service;

@Service
public class CustomerConsumptionReportService {

    private final CustomerConsumptionReportRepository customerConsumptionReportRepository;

    public CustomerConsumptionReportService(CustomerConsumptionReportRepository customerConsumptionReportRepository) {
        this.customerConsumptionReportRepository = customerConsumptionReportRepository;
    }

    public List<CustomerConsumptionReportRow> listCustomerConsumption() {
        return customerConsumptionReportRepository.fetchCustomerConsumptionReport();
    }
}
