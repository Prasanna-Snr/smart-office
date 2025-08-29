# 📹 Camera Network Access Setup Guide

## Overview
This guide explains how to configure your ESP32-CAM for access from different networks, not just local Wi-Fi.

## 🏠 Current Setup (Local Network Only)
- **Default Configuration**: Camera accessible only on same Wi-Fi network
- **IP Address**: Usually `192.168.1.144` or similar local IP
- **Port**: `81` (standard ESP32-CAM WebServer port)
- **Stream URL**: `http://192.168.1.144:81/stream`

## 🌐 Remote Access Solutions

### 1. **Port Forwarding (Router Configuration)**
**Best for**: Permanent remote access with static setup

**Steps**:
1. **Find Camera's Local IP**: Check your router's connected devices
2. **Access Router Settings**: Usually `192.168.1.1` or `192.168.0.1`
3. **Configure Port Forwarding**:
   - External Port: `8081` (or any available port)
   - Internal IP: Your camera's IP (e.g., `192.168.1.144`)
   - Internal Port: `81`
   - Protocol: `TCP`
4. **Find Your Public IP**: Use whatismyipaddress.com
5. **Access URL**: `http://YOUR_PUBLIC_IP:8081/stream`

**Security**: Change default camera passwords, use non-standard ports

### 2. **Dynamic DNS (DDNS)**
**Best for**: Home networks with changing public IP addresses

**Popular DDNS Services**:
- **No-IP**: Free tier available, easy setup
- **DuckDNS**: Free, simple configuration
- **Dynu**: Free with good features

**Setup Process**:
1. **Register DDNS Account**: Choose a hostname (e.g., `mycamera.ddns.net`)
2. **Configure Router**: Enable DDNS in router settings
3. **Set Up Port Forwarding**: Same as method 1
4. **Access URL**: `http://mycamera.ddns.net:8081/stream`

### 3. **VPN Access**
**Best for**: Secure remote access, recommended for security

**Options**:
- **Router VPN**: Many routers support built-in VPN servers
- **Raspberry Pi VPN**: Set up OpenVPN or WireGuard
- **Commercial VPN**: Some allow port forwarding

**Benefits**:
- ✅ Secure encrypted connection
- ✅ Access entire home network
- ✅ No need to expose camera directly to internet

### 4. **Cloud Proxy Services**
**Best for**: Temporary access, testing, or when router configuration isn't possible

**ngrok (Temporary)**:
```bash
# Install ngrok
# Run on a computer in your network:
ngrok http 192.168.1.144:81
# Use the provided public URL
```

**Cloudflare Tunnel (Permanent)**:
- Free service for permanent tunnels
- Requires domain name
- More complex setup but very secure

### 5. **Mobile Hotspot Bridge**
**Best for**: Quick temporary access

**Setup**:
1. Connect a device to your home Wi-Fi
2. Create mobile hotspot from that device
3. Connect your phone to the hotspot
4. Access camera through the bridge device

## 📱 App Configuration

### Camera Settings Screen
The app now includes a **Camera Settings** screen accessible from **Settings → Camera Settings**.

**Configuration Options**:

1. **Connection Mode**:
   - **Auto**: Try all methods automatically
   - **Local Network Only**: Use local IP
   - **Public URL**: Use external URL
   - **Dynamic DNS**: Use DDNS hostname

2. **Local Network Settings**:
   - Camera IP Address
   - Camera Port (usually 81)

3. **Remote Access Settings**:
   - Public URL (full URL including port)
   - DDNS Hostname

4. **Connection Testing**:
   - Test current settings
   - Auto-detect working connection

### Usage Examples

**Local Network**:
- IP: `192.168.1.144`
- Port: `81`
- Result: `http://192.168.1.144:81/stream`

**Port Forwarding**:
- Public URL: `http://123.456.789.012:8081/stream`

**DDNS**:
- Hostname: `mycamera.ddns.net`
- Port: `8081`
- Result: `http://mycamera.ddns.net:8081/stream`

## 🔧 ESP32-CAM Configuration

### Basic WebServer Code
```cpp
#include "esp_camera.h"
#include <WiFi.h>
#include <WebServer.h>

const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

WebServer server(81);

void startCameraServer() {
  server.on("/stream", HTTP_GET, [](){
    // MJPEG streaming code
  });
  server.begin();
}

void setup() {
  // Camera initialization
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
  }
  startCameraServer();
}
```

### Security Enhancements
```cpp
// Add basic authentication
server.on("/stream", HTTP_GET, [](){
  if (!server.authenticate("admin", "your_password")) {
    return server.requestAuthentication();
  }
  // Stream code here
});
```

## 🛡️ Security Considerations

### Essential Security Measures
1. **Change Default Passwords**: Never use default credentials
2. **Use Strong Passwords**: Minimum 12 characters, mixed case, numbers, symbols
3. **Enable Authentication**: Add username/password to camera access
4. **Use Non-Standard Ports**: Avoid common ports like 80, 8080
5. **Regular Updates**: Keep firmware updated
6. **Monitor Access**: Check router logs for suspicious activity

### Recommended Security Levels
- **Low Security**: Port forwarding with authentication
- **Medium Security**: DDNS with strong passwords and non-standard ports
- **High Security**: VPN access only, no direct internet exposure

## 🚀 Quick Setup Guide

### For Beginners (Port Forwarding)
1. **Find Camera IP**: Check router's device list
2. **Configure App**: Settings → Camera Settings → Local IP
3. **Set Up Port Forwarding**: Router settings → Port Forwarding
4. **Configure Remote Access**: Settings → Camera Settings → Public URL
5. **Test Connection**: Use the test buttons in camera settings

### For Advanced Users (VPN)
1. **Set Up VPN Server**: Router or dedicated device
2. **Configure VPN Client**: On your mobile device
3. **Connect via VPN**: Access camera using local IP
4. **App Configuration**: Use local network settings

## 📞 Troubleshooting

### Common Issues
- **Connection Timeout**: Check firewall settings, verify port forwarding
- **Authentication Failed**: Verify username/password
- **Stream Not Loading**: Check camera power, Wi-Fi connection
- **Intermittent Connection**: Router may be blocking long connections

### Testing Steps
1. **Local Access**: Verify camera works on local network
2. **Port Test**: Use online port checker tools
3. **Firewall**: Temporarily disable to test
4. **Router Logs**: Check for blocked connections

### App Features for Troubleshooting
- **Connection Test**: Built-in connectivity testing
- **Auto-Detection**: Automatically find working URLs
- **Multiple Methods**: Fallback between connection types
- **Error Messages**: Detailed error reporting

## 🎯 Recommended Setup

**For Home Users**:
1. **Primary**: DDNS with port forwarding
2. **Backup**: VPN access
3. **App Config**: Auto mode with both configured

**For Office/Business**:
1. **Primary**: VPN access only
2. **Backup**: Dedicated network with firewall rules
3. **App Config**: Local network mode with VPN

This setup provides reliable remote access while maintaining security best practices.