package com.example.api_gateway.orchestrator.application.feign;

import com.example.api_gateway.utils.config.FeignOrchestratorConfig;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;

@FeignClient(name = "orchestrator", url = "http://localhost:8080/api/", configuration = FeignOrchestratorConfig.class)
public interface OrchestratorFeignClient {

    @GetMapping("categorias")
    Object makePaymentByPoints();

    @GetMapping("categorias")
    Object makePaymentByCash();

    @GetMapping("categorias")
    Object makeMixedPayment();
}
