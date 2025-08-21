package com.smartoffice.controller;

import com.smartoffice.model.OfficeState;
import com.smartoffice.service.OfficeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class ApiController {

    @Autowired
    private OfficeService officeService;

    @GetMapping("/status")
    public ResponseEntity<OfficeState> getOfficeStatus() {
        return ResponseEntity.ok(officeService.getOfficeState());
    }

    @PostMapping("/door/toggle")
    public ResponseEntity<Map<String, Object>> toggleDoor(@RequestBody Map<String, Boolean> request) {
        boolean isOpen = request.getOrDefault("open", false);
        officeService.updateDoorStatus(isOpen);
        return ResponseEntity.ok(Map.of(
            "success", true,
            "message", "Door " + (isOpen ? "opened" : "closed") + " successfully",
            "doorOpen", isOpen
        ));
    }

    @PostMapping("/light/toggle")
    public ResponseEntity<Map<String, Object>> toggleLight(@RequestBody Map<String, Boolean> request) {
        boolean isOn = request.getOrDefault("on", false);
        officeService.updateLightStatus(isOn);
        return ResponseEntity.ok(Map.of(
            "success", true,
            "message", "Light " + (isOn ? "turned on" : "turned off") + " successfully",
            "lightOn", isOn
        ));
    }

    @PostMapping("/fan/toggle")
    public ResponseEntity<Map<String, Object>> toggleFan(@RequestBody Map<String, Boolean> request) {
        boolean isOn = request.getOrDefault("on", false);
        officeService.updateFanStatus(isOn);
        return ResponseEntity.ok(Map.of(
            "success", true,
            "message", "Fan " + (isOn ? "turned on" : "turned off") + " successfully",
            "fanOn", isOn
        ));
    }

    @PostMapping("/temperature/update")
    public ResponseEntity<Map<String, Object>> updateTemperature(@RequestBody Map<String, Double> request) {
        double temperature = request.getOrDefault("temperature", 22.0);
        officeService.updateTemperature(temperature);
        return ResponseEntity.ok(Map.of(
            "success", true,
            "message", "Temperature updated successfully",
            "temperature", temperature
        ));
    }

    @PostMapping("/garbage/update")
    public ResponseEntity<Map<String, Object>> updateGarbageLevel(@RequestBody Map<String, Double> request) {
        double level = request.getOrDefault("level", 45.0);
        officeService.updateGarbageLevel(level);
        return ResponseEntity.ok(Map.of(
            "success", true,
            "message", "Garbage level updated successfully",
            "garbageLevel", level
        ));
    }

    @PostMapping("/gas/alert")
    public ResponseEntity<Map<String, Object>> triggerGasAlert(@RequestBody Map<String, Boolean> request) {
        boolean detected = request.getOrDefault("detected", false);
        officeService.updateGasDetection(detected);
        return ResponseEntity.ok(Map.of(
            "success", true,
            "message", "Gas detection " + (detected ? "triggered" : "cleared"),
            "gasDetected", detected
        ));
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> healthCheck() {
        return ResponseEntity.ok(Map.of(
            "status", "healthy",
            "timestamp", System.currentTimeMillis(),
            "service", "Smart Office API"
        ));
    }
}