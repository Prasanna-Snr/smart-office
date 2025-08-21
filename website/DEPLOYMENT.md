# Smart Office - Deployment Guide

This guide covers various deployment options for the Smart Office Spring Boot web application.

## 🚀 Quick Start

### Local Development
```bash
# Clone and navigate to project
cd website

# Build the application
mvn clean install

# Run locally
mvn spring-boot:run

# Access at http://localhost:8080
```

## 🐳 Docker Deployment

### Build Docker Image
```dockerfile
# Dockerfile
FROM openjdk:17-jre-slim

# Set working directory
WORKDIR /app

# Copy the JAR file
COPY target/smart-office-web-1.0.0.jar app.jar

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Docker Commands
```bash
# Build image
docker build -t smart-office-web .

# Run container
docker run -p 8080:8080 smart-office-web

# Run with environment variables
docker run -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=production \
  -e SERVER_PORT=8080 \
  smart-office-web
```

### Docker Compose
```yaml
# docker-compose.yml
version: '3.8'
services:
  smart-office:
    build: .
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=production
      - FIREBASE_DATABASE_URL=https://your-project-default-rtdb.firebaseio.com/
    volumes:
      - ./logs:/app/logs
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

## ☁️ Cloud Deployment

### Heroku Deployment

1. **Create Heroku App**
```bash
heroku create smart-office-app
```

2. **Create Procfile**
```
web: java -Dserver.port=$PORT -jar target/smart-office-web-1.0.0.jar
```

3. **Deploy**
```bash
git add .
git commit -m "Deploy to Heroku"
git push heroku main
```

4. **Set Environment Variables**
```bash
heroku config:set SPRING_PROFILES_ACTIVE=production
heroku config:set FIREBASE_DATABASE_URL=https://your-project-default-rtdb.firebaseio.com/
```

### AWS Deployment

#### AWS Elastic Beanstalk
1. **Create application.yml for production**
```yaml
server:
  port: 5000
spring:
  profiles:
    active: production
logging:
  level:
    com.smartoffice: INFO
```

2. **Package and deploy**
```bash
mvn clean package
eb init
eb create smart-office-env
eb deploy
```

#### AWS ECS (Fargate)
1. **Task Definition**
```json
{
  "family": "smart-office-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::account:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "smart-office",
      "image": "your-account.dkr.ecr.region.amazonaws.com/smart-office:latest",
      "portMappings": [
        {
          "containerPort": 8080,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "SPRING_PROFILES_ACTIVE",
          "value": "production"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/smart-office",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

### Google Cloud Platform

#### Google App Engine
1. **Create app.yaml**
```yaml
runtime: java17
service: smart-office

env_variables:
  SPRING_PROFILES_ACTIVE: production
  FIREBASE_DATABASE_URL: https://your-project-default-rtdb.firebaseio.com/

automatic_scaling:
  min_instances: 1
  max_instances: 10
  target_cpu_utilization: 0.6

health_check:
  enable_health_check: true
  check_interval_sec: 30
  timeout_sec: 4
  unhealthy_threshold: 2
  healthy_threshold: 2
```

2. **Deploy**
```bash
gcloud app deploy
```

#### Google Cloud Run
```bash
# Build and push to Container Registry
gcloud builds submit --tag gcr.io/PROJECT-ID/smart-office

# Deploy to Cloud Run
gcloud run deploy smart-office \
  --image gcr.io/PROJECT-ID/smart-office \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 8080 \
  --set-env-vars SPRING_PROFILES_ACTIVE=production
```

## 🔧 Production Configuration

### Environment Variables
```bash
# Application
SPRING_PROFILES_ACTIVE=production
SERVER_PORT=8080

# Firebase (Optional)
FIREBASE_DATABASE_URL=https://your-project-default-rtdb.firebaseio.com/
FIREBASE_PROJECT_ID=your-project-id

# Face Recognition API
FACE_API_BASE_URL=https://face-lock-api.onrender.com
FACE_API_TIMEOUT=30000

# Logging
LOGGING_LEVEL_COM_SMARTOFFICE=INFO
LOGGING_LEVEL_ROOT=WARN
```

### Production Properties
```properties
# application-production.properties

# Server Configuration
server.port=${SERVER_PORT:8080}
server.compression.enabled=true
server.compression.mime-types=text/html,text/xml,text/plain,text/css,text/javascript,application/javascript,application/json

# Caching
spring.web.resources.cache.period=31536000
spring.web.resources.chain.strategy.content.enabled=true
spring.web.resources.chain.strategy.content.paths=/**

# Actuator Security
management.endpoints.web.exposure.include=health,info
management.endpoint.health.show-details=never

# Logging
logging.level.com.smartoffice=INFO
logging.level.org.springframework=WARN
logging.level.root=WARN
logging.pattern.console=%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n
```

## 📊 Monitoring & Health Checks

### Health Check Endpoints
```bash
# Application health
curl http://your-domain/actuator/health

# Application info
curl http://your-domain/actuator/info

# Custom health check script
#!/bin/bash
HEALTH_URL="http://localhost:8080/actuator/health"
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" $HEALTH_URL)

if [ $RESPONSE -eq 200 ]; then
    echo "Application is healthy"
    exit 0
else
    echo "Application is unhealthy (HTTP $RESPONSE)"
    exit 1
fi
```

### Monitoring Setup

#### Prometheus Metrics (Optional)
Add to `pom.xml`:
```xml
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
```

Add to `application.properties`:
```properties
management.endpoints.web.exposure.include=health,info,prometheus
management.metrics.export.prometheus.enabled=true
```

#### Log Aggregation
```yaml
# docker-compose with ELK stack
version: '3.8'
services:
  smart-office:
    build: .
    ports:
      - "8080:8080"
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    depends_on:
      - elasticsearch

  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.14.0
    environment:
      - discovery.type=single-node
    ports:
      - "9200:9200"

  kibana:
    image: docker.elastic.co/kibana/kibana:7.14.0
    ports:
      - "5601:5601"
    depends_on:
      - elasticsearch
```

## 🔒 Security Configuration

### HTTPS Setup
```properties
# application-production.properties
server.ssl.enabled=true
server.ssl.key-store=classpath:keystore.p12
server.ssl.key-store-password=password
server.ssl.key-store-type=PKCS12
server.ssl.key-alias=smartoffice
```

### Reverse Proxy (Nginx)
```nginx
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name your-domain.com;

    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /actuator/health {
        proxy_pass http://localhost:8080/actuator/health;
        access_log off;
    }
}
```

## 🚨 Troubleshooting

### Common Issues

1. **Port Already in Use**
```bash
# Find process using port 8080
lsof -i :8080
# Kill process
kill -9 <PID>
```

2. **Memory Issues**
```bash
# Increase JVM memory
java -Xmx1024m -jar smart-office-web-1.0.0.jar
```

3. **Camera Access Issues**
- Ensure HTTPS for camera access in production
- Check browser permissions
- Verify camera hardware availability

4. **Firebase Connection Issues**
- Verify Firebase configuration
- Check network connectivity
- Validate Firebase project settings

### Debug Mode
```bash
# Run with debug logging
java -jar smart-office-web-1.0.0.jar --logging.level.com.smartoffice=DEBUG

# Remote debugging
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 -jar smart-office-web-1.0.0.jar
```

## 📈 Performance Optimization

### JVM Tuning
```bash
java -Xms512m -Xmx1024m \
     -XX:+UseG1GC \
     -XX:MaxGCPauseMillis=200 \
     -jar smart-office-web-1.0.0.jar
```

### Application Tuning
```properties
# application-production.properties
server.tomcat.max-threads=200
server.tomcat.min-spare-threads=10
server.tomcat.connection-timeout=20000

spring.web.resources.cache.period=31536000
spring.web.resources.chain.strategy.content.enabled=true
```

## 🔄 CI/CD Pipeline

### GitHub Actions
```yaml
# .github/workflows/deploy.yml
name: Deploy Smart Office

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Set up JDK 17
      uses: actions/setup-java@v2
      with:
        java-version: '17'
        distribution: 'temurin'
    
    - name: Build with Maven
      run: mvn clean package
    
    - name: Build Docker image
      run: docker build -t smart-office-web .
    
    - name: Deploy to production
      run: |
        # Add your deployment commands here
        echo "Deploying to production..."
```

This deployment guide covers the most common scenarios for deploying the Smart Office Spring Boot application. Choose the deployment method that best fits your infrastructure and requirements.