# Smart Office - Flutter Application

A comprehensive Flutter application for smart office management with face recognition, IoT device control, and real-time monitoring.

## 🚀 Features

### 👤 **User Management**
- **Face Recognition**: Register and verify users using face recognition
- **User CRUD**: Add, edit, and delete users
- **Real-time Sync**: Live updates across all devices

### 🏠 **Office Control**
- **Door Control**: Open/close doors with face recognition
- **Device Management**: Control lights, fans, and other IoT devices
- **Firebase Integration**: Real-time device status updates
- **Gas Detection**: Safety monitoring with alerts

### 📊 **Monitoring**
- **Temperature Tracking**: Real-time temperature monitoring with color-coded status
- **User Statistics**: Live user count and activity tracking
- **Status Indicators**: Visual feedback for all systems

## 🏗️ Architecture

The project follows clean architecture principles with clear separation of concerns:

```
lib/
├── core/                    # Core utilities and constants
├── models/                  # Data models
├── providers/               # State management (Provider pattern)
├── screens/                 # UI screens organized by feature
├── services/                # External API and Firebase services
├── theme/                   # App theming and styling
└── widgets/                 # Reusable UI components
```

## 🛠️ Setup

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd smart_office
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Realtime Database
   - Update Firebase configuration in `lib/main.dart`

4. **Run the application**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### Firebase Setup
Update the Firebase configuration in `lib/main.dart`:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "your-api-key",
    appId: "your-app-id",
    messagingSenderId: "your-sender-id",
    projectId: "your-project-id",
    databaseURL: "your-database-url",
    storageBucket: "your-storage-bucket",
  ),
);
```

### Face Recognition API
The app integrates with a face recognition API. Update the base URL in `lib/services/face_lock_service.dart` if needed:

```dart
static const String baseUrl = 'https://your-face-api-url.com';
```

## 📱 Usage

### Adding Users
1. Navigate to User Management
2. Tap "Take Photo & Add User"
3. Capture a photo and enter the user's name
4. The user will be registered with face recognition

### Device Control
1. Use the dashboard to control office devices
2. Toggle lights, fans, and other connected devices
3. Changes sync in real-time via Firebase

### Face Verification
1. Tap "Verify Face" in User Management
2. Take a photo to identify registered users
3. View verification results

## 🧪 Testing

### Run Tests
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze
```

### Format Code
```bash
flutter format .
```

## 📦 Dependencies

### Core Dependencies
- `flutter`: Flutter SDK
- `provider`: State management
- `firebase_core`: Firebase integration
- `firebase_database`: Realtime database
- `http`: API communication
- `image_picker`: Camera functionality

### UI Dependencies
- `google_fonts`: Typography
- `shared_preferences`: Local storage

## 🔒 Permissions

### Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for face recognition</string>
```

## 🚀 Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Check the [documentation](CLEAN_ARCHITECTURE.md)
- Review the [refactoring summary](REFACTORING_SUMMARY.md)
- Open an issue on GitHub

## 🔄 Version History

- **v1.0.0** - Initial release with face recognition and IoT control
- Clean architecture implementation
- Reusable widget components
- Firebase integration
- Real-time monitoring

---

Built with ❤️ using Flutter