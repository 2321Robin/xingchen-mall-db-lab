package com.example.server.report;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/reports")
public class CustomerConsumptionReportController {

    private final CustomerConsumptionReportService customerConsumptionReportService;

    public CustomerConsumptionReportController(CustomerConsumptionReportService customerConsumptionReportService) {
        this.customerConsumptionReportService = customerConsumptionReportService;
    }

    @GetMapping("/customer-consumption")
    public List<CustomerConsumptionReportRow> listCustomerConsumption() {
        return customerConsumptionReportService.listCustomerConsumption();
    }
}
