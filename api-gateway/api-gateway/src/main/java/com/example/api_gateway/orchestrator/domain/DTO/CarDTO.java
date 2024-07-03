package com.example.api_gateway.orchestrator.domain.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class Car {
    private Integer points;
    private BigDecimal cash;
    private BigDecimal total;
    private String method;
}
