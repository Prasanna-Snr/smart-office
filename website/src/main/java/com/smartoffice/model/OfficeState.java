package com.smartoffice.model;

import com.fasterxml.jackson.annotation.JsonProperty;

public class OfficeState {
    
    @JsonProperty("isDoorOpen")
    private boolean isDoorOpen = false;
    
    @JsonProperty("isLightOn")
    private boolean isLightOn = false;
    
    @JsonProperty("isFanOn")
    private boolean isFanOn = false;
    
    @JsonProperty("gasDetected")
    private boolean gasDetected = false;
    
    @JsonProperty("totalUsers")
    private int totalUsers = 0;
    
    @JsonProperty("roomTemperature")
    private double roomTemperature = 22.0;
    
    @JsonProperty("garbageLevel")
    private double garbageLevel = 45.0;
    
    @JsonProperty("lastUpdated")
    private long lastUpdated = System.currentTimeMillis();

    // Default constructor
    public OfficeState() {}

    // Constructor with all fields
    public OfficeState(boolean isDoorOpen, boolean isLightOn, boolean isFanOn, 
                      boolean gasDetected, int totalUsers, double roomTemperature, 
                      double garbageLevel) {
        this.isDoorOpen = isDoorOpen;
        this.isLightOn = isLightOn;
        this.isFanOn = isFanOn;
        this.gasDetected = gasDetected;
        this.totalUsers = totalUsers;
        this.roomTemperature = roomTemperature;
        this.garbageLevel = garbageLevel;
        this.lastUpdated = System.currentTimeMillis();
    }

    // Getters and Setters
    public boolean isDoorOpen() {
        return isDoorOpen;
    }

    public void setDoorOpen(boolean doorOpen) {
        isDoorOpen = doorOpen;
        updateTimestamp();
    }

    public boolean isLightOn() {
        return isLightOn;
    }

    public void setLightOn(boolean lightOn) {
        isLightOn = lightOn;
        updateTimestamp();
    }

    public boolean isFanOn() {
        return isFanOn;
    }

    public void setFanOn(boolean fanOn) {
        isFanOn = fanOn;
        updateTimestamp();
    }

    public boolean isGasDetected() {
        return gasDetected;
    }

    public void setGasDetected(boolean gasDetected) {
        this.gasDetected = gasDetected;
        updateTimestamp();
    }

    public int getTotalUsers() {
        return totalUsers;
    }

    public void setTotalUsers(int totalUsers) {
        this.totalUsers = totalUsers;
        updateTimestamp();
    }

    public double getRoomTemperature() {
        return roomTemperature;
    }

    public void setRoomTemperature(double roomTemperature) {
        this.roomTemperature = roomTemperature;
        updateTimestamp();
    }

    public double getGarbageLevel() {
        return garbageLevel;
    }

    public void setGarbageLevel(double garbageLevel) {
        this.garbageLevel = Math.max(0.0, Math.min(100.0, garbageLevel)); // Clamp between 0-100
        updateTimestamp();
    }

    public long getLastUpdated() {
        return lastUpdated;
    }

    public void setLastUpdated(long lastUpdated) {
        this.lastUpdated = lastUpdated;
    }

    private void updateTimestamp() {
        this.lastUpdated = System.currentTimeMillis();
    }

    // Utility methods
    public String getTemperatureStatus() {
        if (roomTemperature < 20 || roomTemperature > 25) {
            return roomTemperature < 15 || roomTemperature > 30 ? "CRITICAL" : "WARNING";
        }
        return "NORMAL";
    }

    public String getGarbageStatus() {
        if (garbageLevel >= 95) return "CRITICAL";
        if (garbageLevel >= 80) return "WARNING";
        return "NORMAL";
    }

    public boolean needsGarbageAlert() {
        return garbageLevel >= 80;
    }

    public boolean isCriticalGarbageLevel() {
        return garbageLevel >= 95;
    }

    @Override
    public String toString() {
        return "OfficeState{" +
                "isDoorOpen=" + isDoorOpen +
                ", isLightOn=" + isLightOn +
                ", isFanOn=" + isFanOn +
                ", gasDetected=" + gasDetected +
                ", totalUsers=" + totalUsers +
                ", roomTemperature=" + roomTemperature +
                ", garbageLevel=" + garbageLevel +
                ", lastUpdated=" + lastUpdated +
                '}';
    }
}