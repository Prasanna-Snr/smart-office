# Smart Office - Spring Boot Web Application

A comprehensive Spring Boot web application for smart office management with IoT device control, face recognition, and real-time monitoring. This is the web version of the Flutter Smart Office application.

## 🚀 Features

### 👤 **User Management**
- **Face Recognition**: Register and verify users using face recognition API
- **User CRUD**: Add, edit, and delete users through web interface
- **Real-time Camera**: Live camera feed for face capture and verification

### 🏠 **Office Control**
- **Door Control**: Open/close doors with manual controls and face recognition
- **Device Management**: Control lights, fans, and other IoT devices
- **Firebase Integration**: Real-time device status updates (optional)
- **Gas Detection**: Safety monitoring with visual alerts

### 📊 **Monitoring**
- **Temperature Tracking**: Real-time temperature monitoring with color-coded status
- **Garbage Level**: Visual gauge showing dustbin fill levels with sensor integration
- **User Statistics**: Live user count and activity tracking
- **Status Indicators**: Visual feedback for all systems

## 🏗️ Architecture

The project follows Spring Boot best practices with clear separation of concerns:

```
src/
├── main/
│   ├── java/com/smartoffice/
│   │   ├── SmartOfficeApplication.java    # Main application class
│   │   ├── controller/                    # REST controllers
│   │   │   ├── HomeController.java        # Web page controller
│   │   │   └── ApiController.java         # REST API endpoints
│   │   ├── model/                         # Data models
│   │   │   └── OfficeState.java          # Office state model
│   │   ├── service/                       # Business logic
│   │   │   └── OfficeService.java        # Office management service
│   │   └── config/                        # Configuration classes
│   │       └── WebConfig.java            # Web configuration
│   └── resources/
│       ├── templates/                     # Thymeleaf templates
│       │   └── index.html                # Main dashboard page
│       ├── static/                        # Static resources
│       │   ├── css/style.css             # Application styles
│       │   └── script/app.js             # JavaScript application
│       └── application.properties         # Application configuration
```

## 🛠️ Setup

### Prerequisites
- Java 17 or higher
- Maven 3.6 or higher
- Modern web browser with camera support
- Firebase project (optional, for real-time sync)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd website
   ```

2. **Build the application**
   ```bash
   mvn clean install
   ```

3. **Run the application**
   ```bash
   mvn spring-boot:run
   ```

4. **Access the application**
   - Open your browser and navigate to `http://localhost:8080`
   - The dashboard will load with all IoT controls

## 🔧 Configuration

### Application Properties
Update `src/main/resources/application.properties`:

```properties
# Server Configuration
server.port=8080

# Firebase Configuration (Optional)
firebase.database.url=https://your-project-default-rtdb.firebaseio.com/
firebase.project.id=your-project-id

# Face Recognition API
face.api.base.url=https://face-lock-api.onrender.com
```

### Firebase Setup (Optional)
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Enable Realtime Database
3. Update Firebase configuration in `app.js`:

```javascript
const firebaseConfig = {
    apiKey: "your-api-key",
    authDomain: "your-project.firebaseapp.com",
    databaseURL: "https://your-project-default-rtdb.firebaseio.com/",
    projectId: "your-project-id",
    // ... other config
};
```

### Face Recognition API
The application integrates with the same face recognition API as the Flutter version. Update the base URL in `app.js` if needed:

```javascript
const FACE_API_BASE_URL = 'https://face-lock-api.onrender.com';
```

## 📱 Usage

### Dashboard Features
1. **Live Camera Feed**: Real-time camera display for monitoring
2. **Door Control**: Manual open/close buttons with status indicator
3. **Device Controls**: Toggle switches for lights and fans
4. **Temperature Display**: Real-time temperature with color-coded status
5. **Garbage Level Gauge**: Visual gauge showing fill percentage
6. **Office Statistics**: Summary cards with key metrics

### User Management
1. Click "User Management" in the header
2. **Add Users**: Click "Add New User", enter username, capture photo
3. **Face Verification**: Click "Verify Face" to identify users
4. **Delete Users**: Remove users from the system

### IoT Device Control
1. **Lights**: Use toggle switch to control office lighting
2. **Fan**: Use toggle switch to control ceiling fan
3. **Door**: Use Open/Close buttons for door control
4. **Monitoring**: View real-time sensor data

## 🔌 API Endpoints

### REST API
- `GET /api/status` - Get current office state
- `POST /api/door/toggle` - Toggle door status
- `POST /api/light/toggle` - Toggle light status
- `POST /api/fan/toggle` - Toggle fan status
- `POST /api/temperature/update` - Update temperature
- `POST /api/garbage/update` - Update garbage level
- `POST /api/gas/alert` - Trigger gas alert
- `GET /api/health` - Health check endpoint

### Example API Usage
```bash
# Get office status
curl http://localhost:8080/api/status

# Toggle door
curl -X POST http://localhost:8080/api/door/toggle \
  -H "Content-Type: application/json" \
  -d '{"open": true}'

# Update temperature
curl -X POST http://localhost:8080/api/temperature/update \
  -H "Content-Type: application/json" \
  -d '{"temperature": 24.5}'
```

## 🧪 Testing

### Run Tests
```bash
mvn test
```

### Manual Testing
1. Start the application
2. Open browser to `http://localhost:8080`
3. Test camera access (allow permissions)
4. Test device controls
5. Test user management features

## 📦 Dependencies

### Core Dependencies
- **Spring Boot 3.2.0**: Main framework
- **Spring Web**: REST API and web controllers
- **Thymeleaf**: Template engine for HTML
- **Spring Boot Actuator**: Monitoring and health checks
- **Jackson**: JSON processing

### Optional Dependencies
- **Firebase Admin SDK**: Firebase integration
- **WebFlux**: Reactive web client for external APIs
- **WebSocket**: Real-time communication support

## 🔒 Security Considerations

### Camera Permissions
- Application requires camera access for face recognition
- Users must grant camera permissions in browser
- Camera streams are processed locally (not transmitted)

### API Security
- CORS configured for cross-origin requests
- Input validation on all endpoints
- Error handling to prevent information disclosure

### Data Privacy
- Face images processed by external API
- No persistent storage of biometric data in application
- User data managed through external face recognition service

## 🚀 Deployment

### Local Development
```bash
mvn spring-boot:run
```

### Production Build
```bash
mvn clean package
java -jar target/smart-office-web-1.0.0.jar
```

### Docker Deployment
```dockerfile
FROM openjdk:17-jre-slim
COPY target/smart-office-web-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

### Cloud Deployment
- **Heroku**: Use `Procfile` with `web: java -jar target/smart-office-web-1.0.0.jar`
- **AWS**: Deploy to Elastic Beanstalk or ECS
- **Google Cloud**: Deploy to App Engine or Cloud Run

## 🔄 Integration Points

### Hardware Integration
- **IoT Sensors**: Temperature, garbage level, gas detection
- **Smart Devices**: Lights, fans, door locks
- **Camera Systems**: Face recognition, monitoring

### External Services
- **Firebase**: Real-time database for device states
- **Face Recognition API**: User registration and verification
- **Notification Services**: Alerts and monitoring

## 📊 Monitoring

### Health Checks
- Application health: `http://localhost:8080/actuator/health`
- Application info: `http://localhost:8080/actuator/info`
- Metrics: `http://localhost:8080/actuator/metrics`

### Logging
- Console logging for development
- File logging for production
- Configurable log levels

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
- Check the application logs
- Review the API documentation
- Test with the health check endpoints
- Open an issue on GitHub

## 🔄 Version History

- **v1.0.0** - Initial Spring Boot web version
  - Complete Flutter feature parity
  - REST API implementation
  - Real-time dashboard
  - Face recognition integration
  - IoT device control
  - Firebase integration ready

---

Built with ❤️ using Spring Boot, HTML5, CSS3, and JavaScript