package org.apereo.cas.config;

import org.apereo.cas.configuration.CasConfigurationProperties;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

@Configuration(value = "CasOverlayOverrideConfiguration", proxyBeanMethods = false)
@ComponentScan(basePackages = {"org.apereo.cas.config.StartupSecretsLoading"})
//@EnableConfigurationProperties(CasConfigurationProperties.class)
public class CasOverlayOverrideConfiguration {

}
