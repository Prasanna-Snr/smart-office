package com.smartoffice.service;

import com.smartoffice.model.OfficeState;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class OfficeService {
    
    private static final Logger logger = LoggerFactory.getLogger(OfficeService.class);
    
    private OfficeState officeState;
    
    public OfficeService() {
        // Initialize with default values
        this.officeState = new OfficeState();
        logger.info("OfficeService initialized with default state: {}", officeState);
    }
    
    public OfficeState getOfficeState() {
        return officeState;
    }
    
    public void updateDoorStatus(boolean isOpen) {
        boolean previousState = officeState.isDoorOpen();
        officeState.setDoorOpen(isOpen);
        logger.info("Door status updated: {} -> {}", previousState, isOpen);
        
        // Here you could integrate with Firebase or other real-time services
        // firebaseService.updateDoorStatus(isOpen);
    }
    
    public void updateLightStatus(boolean isOn) {
        boolean previousState = officeState.isLightOn();
        officeState.setLightOn(isOn);
        logger.info("Light status updated: {} -> {}", previousState, isOn);
        
        // Here you could integrate with IoT devices
        // iotService.updateLightStatus(isOn);
    }
    
    public void updateFanStatus(boolean isOn) {
        boolean previousState = officeState.isFanOn();
        officeState.setFanOn(isOn);
        logger.info("Fan status updated: {} -> {}", previousState, isOn);
        
        // Here you could integrate with IoT devices
        // iotService.updateFanStatus(isOn);
    }
    
    public void updateTemperature(double temperature) {
        double previousTemp = officeState.getRoomTemperature();
        officeState.setRoomTemperature(temperature);
        logger.info("Temperature updated: {}°C -> {}°C", previousTemp, temperature);
        
        // Check for temperature alerts
        String status = officeState.getTemperatureStatus();
        if (!"NORMAL".equals(status)) {
            logger.warn("Temperature alert: {} - Current: {}°C", status, temperature);
        }
        
        // Here you could integrate with Firebase or sensor systems
        // firebaseService.updateTemperature(temperature);
    }
    
    public void updateGarbageLevel(double level) {
        double previousLevel = officeState.getGarbageLevel();
        officeState.setGarbageLevel(level);
        logger.info("Garbage level updated: {}% -> {}%", previousLevel, level);
        
        // Check for garbage alerts
        if (officeState.isCriticalGarbageLevel()) {
            logger.error("CRITICAL: Garbage level at {}% - Immediate action required!", level);
        } else if (officeState.needsGarbageAlert()) {
            logger.warn("WARNING: Garbage level at {}% - Should be emptied soon", level);
        }
        
        // Here you could integrate with Firebase or sensor systems
        // firebaseService.updateGarbageLevel(level);
    }
    
    public void updateGasDetection(boolean detected) {
        boolean previousState = officeState.isGasDetected();
        officeState.setGasDetected(detected);
        
        if (detected) {
            logger.error("GAS DETECTED! Emergency alert triggered!");
        } else {
            logger.info("Gas detection cleared");
        }
        
        // Here you could integrate with emergency systems
        // emergencyService.handleGasAlert(detected);
    }
    
    public void updateUserCount(int count) {
        int previousCount = officeState.getTotalUsers();
        officeState.setTotalUsers(count);
        logger.info("User count updated: {} -> {}", previousCount, count);
        
        // Here you could integrate with face recognition systems
        // faceRecognitionService.updateUserCount(count);
    }
    
    // Utility methods for system health and monitoring
    public boolean isSystemHealthy() {
        // Check if all systems are operating within normal parameters
        return !officeState.isGasDetected() && 
               "NORMAL".equals(officeState.getTemperatureStatus()) &&
               !officeState.isCriticalGarbageLevel();
    }
    
    public String getSystemStatus() {
        if (officeState.isGasDetected()) {
            return "EMERGENCY - Gas Detected";
        }
        if (officeState.isCriticalGarbageLevel()) {
            return "CRITICAL - Garbage Full";
        }
        if (!"NORMAL".equals(officeState.getTemperatureStatus())) {
            return "WARNING - Temperature " + officeState.getTemperatureStatus();
        }
        if (officeState.needsGarbageAlert()) {
            return "WARNING - Garbage Level High";
        }
        return "NORMAL";
    }
    
    // Simulate sensor data updates (for testing/demo purposes)
    public void simulateTemperatureChange() {
        double currentTemp = officeState.getRoomTemperature();
        double newTemp = currentTemp + (Math.random() - 0.5) * 2; // ±1°C change
        updateTemperature(Math.round(newTemp * 10.0) / 10.0); // Round to 1 decimal
    }
    
    public void simulateGarbageLevelChange() {
        double currentLevel = officeState.getGarbageLevel();
        double newLevel = Math.max(0, Math.min(100, currentLevel + (Math.random() - 0.3) * 5)); // Slight increase bias
        updateGarbageLevel(Math.round(newLevel * 10.0) / 10.0); // Round to 1 decimal
    }
    
    public void resetToDefaults() {
        this.officeState = new OfficeState();
        logger.info("Office state reset to defaults");
    }
}