package com.smart_office.com;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;

@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class})
public class SmartOfficeApplication {
    public static void main(String[] args) {
        SpringApplication.run(SmartOfficeApplication.class, args);
    }
}

