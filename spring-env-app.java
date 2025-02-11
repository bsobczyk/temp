package com.example.envapi;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api")
public class EnvController {

    @GetMapping("/env")
    public Map<String, String> getAllEnvVariables() {
        return System.getenv();
    }

    @GetMapping("/env/HyperTeam")
    public String getHyperTeamEnv() {
        return System.getenv("HyperTeam");
    }
}
