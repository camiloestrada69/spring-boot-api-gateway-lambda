package com.example.api_gateway.orchestrator.rest;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.function.Supplier;

@Configuration
public class OrchestratorController {

    @Bean("supplier")
    public Supplier<String> supplier(){
        return () -> "Hola Camilo";
    }
}
