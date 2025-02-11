// pom.xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <groupId>com.example</groupId>
    <artifactId>env-variables-demo</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.2</version>
    </parent>
    
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springdoc</groupId>
            <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
            <version>2.3.0</version>
        </dependency>
    </dependencies>
    
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>

// src/main/java/com/example/EnvVariablesApplication.java
package com.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class EnvVariablesApplication {
    public static void main(String[] args) {
        SpringApplication.run(EnvVariablesApplication.class, args);
    }
}

// src/main/java/com/example/controller/EnvController.java
package com.example.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/env")
@Tag(name = "Environment Variables", description = "Endpoints for retrieving environment variables")
public class EnvController {

    @Value("${server.port:8080}")
    private String serverPort;

    @Value("${spring.application.name:env-variables-demo}")
    private String applicationName;

    @GetMapping("/all")
    @Operation(summary = "Get all environment variables",
               description = "Returns all configured environment variables for the application")
    public Map<String, String> getAllEnvVariables() {
        Map<String, String> envVariables = new HashMap<>();
        envVariables.put("SERVER_PORT", serverPort);
        envVariables.put("APPLICATION_NAME", applicationName);
        envVariables.put("JAVA_VERSION", System.getProperty("java.version"));
        envVariables.put("OS_NAME", System.getProperty("os.name"));
        return envVariables;
    }

    @GetMapping("/system")
    @Operation(summary = "Get system environment variables",
               description = "Returns basic system environment information")
    public Map<String, String> getSystemEnv() {
        Map<String, String> systemEnv = new HashMap<>();
        systemEnv.put("OS_NAME", System.getProperty("os.name"));
        systemEnv.put("OS_VERSION", System.getProperty("os.version"));
        systemEnv.put("OS_ARCH", System.getProperty("os.arch"));
        return systemEnv;
    }

    @GetMapping("/application")
    @Operation(summary = "Get application environment variables",
               description = "Returns application-specific environment variables")
    public Map<String, String> getApplicationEnv() {
        Map<String, String> appEnv = new HashMap<>();
        appEnv.put("SERVER_PORT", serverPort);
        appEnv.put("APPLICATION_NAME", applicationName);
        return appEnv;
    }
}

// src/main/resources/application.yml
server:
  port: 8080

spring:
  application:
    name: env-variables-demo
