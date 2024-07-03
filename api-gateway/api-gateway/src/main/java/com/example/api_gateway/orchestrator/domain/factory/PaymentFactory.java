package com.example.api_gateway.orchestrator.domain.factory;

import com.example.api_gateway.orchestrator.domain.IPayment;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)
public class MyPaymentFactory {

    private final Map<String, IPayment> iPaymentMap;


    public MyPaymentFactory(List<IPayment> service) {
        iPaymentMap = service.stream().collect(Collectors.toMap(IPayment::getClassIdentifier, Function.identity()));
    }

    public IPayment getImplementation(String identifier) {
        return Optional.ofNullable(iPaymentMap.get(identifier)).orElseThrow(IllegalArgumentException::new);
    }
}
