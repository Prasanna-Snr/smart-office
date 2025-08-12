# Firebase LED Control Integration

This document explains how the Firebase Realtime Database LED control integration works in your Smart Office app.

## Overview

Your app now connects to Firebase Realtime Database to control an LED status in real-time. When you toggle the office light in the app, it updates the `led_status` field in your Firebase database.

**Firebase Database URL:** `https://iotproject-403ba-default-rtdb.firebaseio.com`

## How It Works

### 1. Firebase Service (`lib/services/firebase_service.dart`)
- **`updateLedStatus(bool status)`**: Updates the LED status in Firebase
- **`getLedStatus()`**: Gets the current LED status from Firebase
- **`ledStatusStream()`**: Provides real-time updates when LED status changes

### 2. Office Provider Integration
The `OfficeProvider` now:
- Listens to Firebase changes in real-time
- Updates the local state when Firebase data changes
- Syncs local changes back to Firebase

### 3. UI Components
- **LED Control Widget**: A dedicated widget showing Firebase sync status
- **Home Screen Integration**: Updated to show Firebase connectivity
- **Real-time Updates**: Changes reflect immediately across all connected devices

## Usage

### In Your App
1. Open the Smart Office app
2. Navigate to the "Smart LED Control" section
3. Toggle the LED ON/OFF using the button
4. The change will be reflected in Firebase immediately

### Firebase Database Structure
```json
{
  "led_status": true  // or false
}
```

### Code Examples

#### Turn LED ON
```dart
await FirebaseService.updateLedStatus(true);
```

#### Turn LED OFF
```dart
await FirebaseService.updateLedStatus(false);
```

#### Listen to Changes
```dart
FirebaseService.ledStatusStream().listen((bool status) {
  print('LED is now: ${status ? 'ON' : 'OFF'}');
});
```

## Features

✅ **Real-time Sync**: Changes are reflected immediately across all devices
✅ **Error Handling**: Graceful error handling with user feedback
✅ **Loading States**: Visual feedback during Firebase operations
✅ **Offline Support**: Firebase handles offline scenarios automatically
✅ **Connection Status**: Visual indicators showing Firebase connectivity

## Testing

### Manual Testing
1. Open your Firebase console: https://console.firebase.google.com
2. Navigate to your project: `iotproject-403ba`
3. Go to Realtime Database
4. Watch the `led_status` field change when you toggle in the app

### Multiple Device Testing
1. Open the app on multiple devices
2. Toggle the LED on one device
3. Watch it update on all other devices in real-time

## Integration with Physical Hardware

To connect this to actual hardware (like an Arduino or Raspberry Pi):

1. **Arduino/ESP32**: Use Firebase Arduino library to listen to `led_status` changes
2. **Raspberry Pi**: Use Firebase Python SDK to monitor the database
3. **IoT Platforms**: Most IoT platforms can integrate with Firebase Realtime Database

### Example Arduino Code
```cpp
#include <FirebaseESP32.h>

void setup() {
  // Initialize Firebase
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  
  // Listen to led_status changes
  Firebase.setStreamCallback(streamCallback, streamTimeoutCallback);
  Firebase.beginStream(firebaseData, "/led_status");
}

void streamCallback(StreamData data) {
  if (data.dataType() == "boolean") {
    bool ledStatus = data.boolData();
    digitalWrite(LED_PIN, ledStatus ? HIGH : LOW);
  }
}
```

## Troubleshooting

### Common Issues
1. **Connection Failed**: Check internet connection and Firebase configuration
2. **Permission Denied**: Verify Firebase security rules allow read/write access
3. **Data Not Syncing**: Ensure Firebase is properly initialized in `main.dart`

### Firebase Security Rules
Make sure your Firebase Realtime Database rules allow access:
```json
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```

## Next Steps

1. **Add More Controls**: Extend to control fans, doors, etc.
2. **User Authentication**: Add Firebase Auth for secure access
3. **Data Logging**: Store LED usage history
4. **Notifications**: Send push notifications on status changes
5. **Hardware Integration**: Connect to actual LED/relay modules

## Support

If you encounter any issues:
1. Check the Flutter console for error messages
2. Verify Firebase configuration in `main.dart`
3. Test Firebase connection using the demo widget
4. Check Firebase console for database activity