package com.example.envapi;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api")
@Tag(name = "Environment Variables", description = "API for retrieving environment variables")
public class EnvController {

    @GetMapping("/env")
    @Operation(summary = "Get all environment variables", description = "Returns a map of all environment variables.")
    public Map<String, String> getAllEnvVariables() {
        return System.getenv();
    }

    @GetMapping("/env/HyperTeam")
    @Operation(summary = "Get HyperTeam environment variable", description = "Returns the value of the HyperTeam environment variable.")
    public String getHyperTeamEnv() {
        String value = System.getenv("HyperTeam");
        return (value != null) ? value : "Nie znaleziono zmiennej HyperTeam w ENV";
    }
}
