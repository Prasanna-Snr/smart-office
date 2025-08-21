// Smart Office - JavaScript Application

// Firebase Configuration
const firebaseConfig = {
    apiKey: "your-api-key",
    authDomain: "your-project.firebaseapp.com",
    databaseURL: "https://your-project-default-rtdb.firebaseio.com/",
    projectId: "your-project-id",
    storageBucket: "your-project.appspot.com",
    messagingSenderId: "123456789",
    appId: "your-app-id"
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
const database = firebase.database();

// Application State
let appState = {
    isDoorOpen: false,
    isLightOn: false,
    isFanOn: false,
    gasDetected: false,
    totalUsers: 0,
    roomTemperature: 22.0,
    garbageLevel: 45.0,
    users: []
};

// Camera variables
let cameraStream = null;
let userCameraStream = null;

// Face Lock API Configuration
const FACE_API_BASE_URL = 'https://face-lock-api.onrender.com';

// Initialize Application
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
    setupFirebaseListeners();
    loadUsers();
    startCameraFeed();
});

// Initialize Application
function initializeApp() {
    console.log('Smart Office Application Starting...');
    updateUI();
    
    // Simulate some initial data
    setTimeout(() => {
        simulateGasDetection();
    }, 5000);
}

// Firebase Listeners
function setupFirebaseListeners() {
    // Door status listener
    database.ref('door_status').on('value', (snapshot) => {
        const isOpen = snapshot.val() || false;
        appState.isDoorOpen = isOpen;
        updateDoorStatus();
    });

    // LED status listener
    database.ref('led_status').on('value', (snapshot) => {
        const isOn = snapshot.val() || false;
        appState.isLightOn = isOn;
        updateLightStatus();
    });

    // Temperature listener
    database.ref('temperature').on('value', (snapshot) => {
        const temp = snapshot.val() || 22.0;
        appState.roomTemperature = temp;
        updateTemperature();
    });

    // Garbage level listener
    database.ref('garbage_level').on('value', (snapshot) => {
        const level = snapshot.val() || 45.0;
        appState.garbageLevel = level;
        updateGarbageLevel();
        checkGarbageAlerts();
    });
}

// Update UI Elements
function updateUI() {
    updateDoorStatus();
    updateLightStatus();
    updateFanStatus();
    updateTemperature();
    updateGarbageLevel();
    updateStats();
}

// Door Control Functions
function updateDoorStatus() {
    const statusBadge = document.getElementById('doorStatusBadge');
    const statusText = document.getElementById('doorStatusText');
    const openBtn = document.getElementById('openDoorBtn');
    const closeBtn = document.getElementById('closeDoorBtn');

    if (appState.isDoorOpen) {
        statusBadge.className = 'status-badge open';
        statusText.textContent = 'OPEN';
        openBtn.disabled = true;
        closeBtn.disabled = false;
    } else {
        statusBadge.className = 'status-badge closed';
        statusText.textContent = 'CLOSED';
        openBtn.disabled = false;
        closeBtn.disabled = true;
    }
}

function toggleDoor(open) {
    database.ref('door_status').set(open)
        .then(() => {
            console.log(`Door ${open ? 'opened' : 'closed'} successfully`);
        })
        .catch((error) => {
            console.error('Error updating door status:', error);
            showNotification('Failed to update door status', 'error');
        });
}

// Light Control Functions
function updateLightStatus() {
    const lightSwitch = document.getElementById('lightSwitch');
    const lightStatus = document.getElementById('lightStatus');
    
    lightSwitch.checked = appState.isLightOn;
    lightStatus.textContent = appState.isLightOn ? 'Currently ON' : 'Currently OFF';
    lightStatus.className = appState.isLightOn ? 'status-normal' : '';
}

function toggleLight() {
    const newStatus = !appState.isLightOn;
    database.ref('led_status').set(newStatus)
        .then(() => {
            console.log(`Light ${newStatus ? 'turned on' : 'turned off'}`);
        })
        .catch((error) => {
            console.error('Error updating light status:', error);
            showNotification('Failed to toggle light', 'error');
        });
}

// Fan Control Functions
function updateFanStatus() {
    const fanSwitch = document.getElementById('fanSwitch');
    const fanStatus = document.getElementById('fanStatus');
    
    fanSwitch.checked = appState.isFanOn;
    fanStatus.textContent = appState.isFanOn ? 'Currently ON' : 'Currently OFF';
    fanStatus.className = appState.isFanOn ? 'status-normal' : '';
}

function toggleFan() {
    appState.isFanOn = !appState.isFanOn;
    updateFanStatus();
    console.log(`Fan ${appState.isFanOn ? 'turned on' : 'turned off'}`);
}

// Temperature Functions
function updateTemperature() {
    const tempValue = document.getElementById('temperatureValue');
    const tempProgress = document.getElementById('temperatureProgress');
    const tempStat = document.getElementById('tempStat');
    
    const temp = appState.roomTemperature;
    tempValue.textContent = `${temp.toFixed(1)}°C`;
    tempStat.textContent = `${temp.toFixed(1)}°C`;
    
    // Calculate progress (15°C to 35°C range)
    const minTemp = 15;
    const maxTemp = 35;
    const progress = Math.max(0, Math.min(1, (temp - minTemp) / (maxTemp - minTemp)));
    tempProgress.style.width = `${progress * 100}%`;
    
    // Color coding
    let color = '#4CAF50'; // Normal
    if (temp < 20 || temp > 25) {
        color = '#FF9800'; // Warning
    }
    if (temp < 15 || temp > 30) {
        color = '#f44336'; // Critical
    }
    
    tempValue.style.color = color;
    tempProgress.style.backgroundColor = color;
}

// Garbage Level Functions
function updateGarbageLevel() {
    const percentage = document.getElementById('garbagePercentage');
    const status = document.getElementById('garbageStatus');
    const progressArc = document.getElementById('garbageProgressArc');
    const needle = document.getElementById('garbageNeedle');
    const garbageStat = document.getElementById('garbageStat');
    
    const level = appState.garbageLevel;
    percentage.textContent = `${Math.round(level)}%`;
    garbageStat.textContent = `${Math.round(level)}%`;
    
    // Update status text and color
    let statusText = 'Normal (Sensor)';
    let color = '#4CAF50';
    
    if (level >= 95) {
        statusText = 'Critical (Sensor)';
        color = '#f44336';
    } else if (level >= 80) {
        statusText = 'Warning (Sensor)';
        color = '#FF9800';
    }
    
    status.textContent = statusText;
    status.style.color = color;
    
    // Update gauge arc (semicircle from 0 to 180 degrees)
    const circumference = 251.2; // Approximate arc length
    const offset = circumference - (level / 100) * circumference;
    progressArc.style.strokeDashoffset = offset;
    progressArc.style.stroke = color;
    
    // Update needle rotation (0 to 180 degrees)
    const angle = (level / 100) * 180;
    const needleX = 100 + 70 * Math.cos((angle - 90) * Math.PI / 180);
    const needleY = 100 + 70 * Math.sin((angle - 90) * Math.PI / 180);
    needle.setAttribute('x2', needleX);
    needle.setAttribute('y2', needleY);
}

function checkGarbageAlerts() {
    const level = appState.garbageLevel;
    const alert = document.getElementById('garbageAlert');
    const title = document.getElementById('garbageAlertTitle');
    const message = document.getElementById('garbageAlertMessage');
    
    if (level >= 95) {
        alert.className = 'alert alert-danger';
        title.textContent = 'Critical Garbage Level!';
        message.textContent = 'Dustbin is nearly full and needs immediate attention.';
        alert.style.display = 'block';
    } else if (level >= 80) {
        alert.className = 'alert alert-warning';
        title.textContent = 'Garbage Level Warning';
        message.textContent = 'Dustbin is getting full and should be emptied soon.';
        alert.style.display = 'block';
    } else {
        alert.style.display = 'none';
    }
}

function dismissGarbageAlert() {
    document.getElementById('garbageAlert').style.display = 'none';
}

// Statistics Update
function updateStats() {
    document.getElementById('userCount').textContent = appState.users.length;
}

// Gas Detection Functions
function simulateGasDetection() {
    if (!appState.gasDetected) {
        appState.gasDetected = true;
        document.getElementById('gasAlert').style.display = 'block';
        console.log('Gas detected! Alert shown.');
    }
}

function dismissGasAlert() {
    appState.gasDetected = false;
    document.getElementById('gasAlert').style.display = 'none';
}

// Camera Functions
async function startCameraFeed() {
    try {
        const stream = await navigator.mediaDevices.getUserMedia({ 
            video: { width: 1280, height: 720 } 
        });
        const video = document.getElementById('cameraFeed');
        video.srcObject = stream;
        cameraStream = stream;
        console.log('Camera feed started');
    } catch (error) {
        console.error('Error accessing camera:', error);
        showNotification('Camera access denied or not available', 'error');
    }
}

function capturePhoto() {
    if (!cameraStream) {
        showNotification('Camera not available', 'error');
        return;
    }
    
    const video = document.getElementById('cameraFeed');
    const canvas = document.createElement('canvas');
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    
    const ctx = canvas.getContext('2d');
    ctx.drawImage(video, 0, 0);
    
    // Convert to blob and process
    canvas.toBlob((blob) => {
        console.log('Photo captured:', blob.size, 'bytes');
        showNotification('Photo captured successfully!', 'success');
    }, 'image/jpeg', 0.8);
}

// User Management Functions
function openUserManagement() {
    document.getElementById('userModal').style.display = 'block';
    loadUsers();
}

function closeUserManagement() {
    document.getElementById('userModal').style.display = 'none';
    hideAddUserForm();
    stopUserCamera();
}

function showAddUserForm() {
    document.getElementById('addUserForm').style.display = 'block';
}

function hideAddUserForm() {
    document.getElementById('addUserForm').style.display = 'none';
    document.getElementById('userName').value = '';
    resetPhotoPreview();
}

function cancelAddUser() {
    hideAddUserForm();
    stopUserCamera();
}

// Camera functions for user registration
async function startCamera() {
    try {
        const stream = await navigator.mediaDevices.getUserMedia({ 
            video: { width: 640, height: 480 } 
        });
        const video = document.getElementById('userVideo');
        video.srcObject = stream;
        video.style.display = 'block';
        userCameraStream = stream;
        console.log('User camera started');
    } catch (error) {
        console.error('Error accessing camera:', error);
        showNotification('Camera access denied', 'error');
    }
}

function stopUserCamera() {
    if (userCameraStream) {
        userCameraStream.getTracks().forEach(track => track.stop());
        userCameraStream = null;
        document.getElementById('userVideo').style.display = 'none';
    }
}

function captureUserPhoto() {
    if (!userCameraStream) {
        showNotification('Please start camera first', 'error');
        return;
    }
    
    const video = document.getElementById('userVideo');
    const canvas = document.getElementById('userCanvas');
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    
    const ctx = canvas.getContext('2d');
    ctx.drawImage(video, 0, 0);
    
    // Show preview
    const dataURL = canvas.toDataURL('image/jpeg', 0.8);
    const preview = document.getElementById('photoPreview');
    preview.innerHTML = `<img src="${dataURL}" alt="Captured photo">`;
    
    stopUserCamera();
    console.log('User photo captured');
}

function resetPhotoPreview() {
    const preview = document.getElementById('photoPreview');
    preview.innerHTML = `
        <span class="material-icons">camera_alt</span>
        <p>Click to capture photo</p>
    `;
}

// User Registration
async function registerUser() {
    const username = document.getElementById('userName').value.trim();
    const canvas = document.getElementById('userCanvas');
    
    if (!username) {
        showNotification('Please enter a username', 'error');
        return;
    }
    
    if (!canvas.width || !canvas.height) {
        showNotification('Please capture a photo first', 'error');
        return;
    }
    
    try {
        // Convert canvas to blob
        const blob = await new Promise(resolve => {
            canvas.toBlob(resolve, 'image/jpeg', 0.8);
        });
        
        // Create FormData
        const formData = new FormData();
        formData.append('username', username);
        formData.append('image', blob, 'image.jpg');
        
        // Show loading
        showNotification('Registering user...', 'info');
        
        // Send to Face API
        const response = await fetch(`${FACE_API_BASE_URL}/register`, {
            method: 'POST',
            body: formData
        });
        
        if (response.ok) {
            const result = await response.json();
            console.log('User registered:', result);
            showNotification('User registered successfully!', 'success');
            hideAddUserForm();
            loadUsers();
        } else {
            const error = await response.text();
            throw new Error(`Registration failed: ${error}`);
        }
    } catch (error) {
        console.error('Registration error:', error);
        showNotification('Failed to register user: ' + error.message, 'error');
    }
}

// Load Users
async function loadUsers() {
    try {
        const response = await fetch(`${FACE_API_BASE_URL}/users`);
        if (response.ok) {
            const data = await response.json();
            appState.users = data.users || [];
            displayUsers();
            updateStats();
        } else {
            throw new Error('Failed to load users');
        }
    } catch (error) {
        console.error('Error loading users:', error);
        showNotification('Failed to load users', 'error');
    }
}

function displayUsers() {
    const container = document.getElementById('usersList');
    
    if (appState.users.length === 0) {
        container.innerHTML = '<p style="text-align: center; color: #666;">No users registered yet.</p>';
        return;
    }
    
    container.innerHTML = appState.users.map(user => `
        <div class="user-item">
            <img src="data:image/jpeg;base64,${user.image}" alt="${user.username}" class="user-avatar">
            <div class="user-name">${user.username}</div>
            <div class="user-actions-item">
                <button class="btn btn-sm btn-danger" onclick="deleteUser('${user.username}')">
                    <span class="material-icons">delete</span>
                    Delete
                </button>
            </div>
        </div>
    `).join('');
}

// Delete User
async function deleteUser(username) {
    if (!confirm(`Are you sure you want to delete user "${username}"?`)) {
        return;
    }
    
    try {
        const response = await fetch(`${FACE_API_BASE_URL}/users/${username}`, {
            method: 'DELETE'
        });
        
        if (response.ok) {
            showNotification('User deleted successfully!', 'success');
            loadUsers();
        } else {
            throw new Error('Failed to delete user');
        }
    } catch (error) {
        console.error('Delete error:', error);
        showNotification('Failed to delete user', 'error');
    }
}

// Face Verification
async function verifyFace() {
    if (!cameraStream) {
        showNotification('Camera not available', 'error');
        return;
    }
    
    try {
        // Capture current frame
        const video = document.getElementById('cameraFeed');
        const canvas = document.createElement('canvas');
        canvas.width = video.videoWidth;
        canvas.height = video.videoHeight;
        
        const ctx = canvas.getContext('2d');
        ctx.drawImage(video, 0, 0);
        
        // Convert to blob
        const blob = await new Promise(resolve => {
            canvas.toBlob(resolve, 'image/jpeg', 0.8);
        });
        
        // Create FormData
        const formData = new FormData();
        formData.append('image', blob, 'image.jpg');
        
        showNotification('Verifying face...', 'info');
        
        // Send to Face API
        const response = await fetch(`${FACE_API_BASE_URL}/authenticate`, {
            method: 'POST',
            body: formData
        });
        
        if (response.ok) {
            const result = await response.json();
            if (result.authenticated) {
                showNotification(`Welcome back, ${result.username}!`, 'success');
                // Open door automatically
                toggleDoor(true);
            } else {
                showNotification('Face not recognized', 'error');
            }
        } else {
            throw new Error('Verification failed');
        }
    } catch (error) {
        console.error('Verification error:', error);
        showNotification('Face verification failed', 'error');
    }
}

// Notification System
function showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.innerHTML = `
        <span class="material-icons">${getNotificationIcon(type)}</span>
        <span>${message}</span>
    `;
    
    // Add styles
    Object.assign(notification.style, {
        position: 'fixed',
        top: '20px',
        right: '20px',
        background: getNotificationColor(type),
        color: 'white',
        padding: '1rem 1.5rem',
        borderRadius: '8px',
        display: 'flex',
        alignItems: 'center',
        gap: '0.5rem',
        zIndex: '10000',
        boxShadow: '0 4px 20px rgba(0,0,0,0.3)',
        animation: 'slideIn 0.3s ease-out'
    });
    
    document.body.appendChild(notification);
    
    // Auto remove after 3 seconds
    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s ease-out';
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 300);
    }, 3000);
}

function getNotificationIcon(type) {
    switch (type) {
        case 'success': return 'check_circle';
        case 'error': return 'error';
        case 'warning': return 'warning';
        default: return 'info';
    }
}

function getNotificationColor(type) {
    switch (type) {
        case 'success': return '#4CAF50';
        case 'error': return '#f44336';
        case 'warning': return '#FF9800';
        default: return '#2196F3';
    }
}

// Utility Functions
function formatTimestamp(timestamp) {
    return new Date(timestamp).toLocaleString();
}

// Close modal when clicking outside
window.onclick = function(event) {
    const modal = document.getElementById('userModal');
    if (event.target === modal) {
        closeUserManagement();
    }
}

// Keyboard shortcuts
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeUserManagement();
    }
});

console.log('Smart Office Application Loaded Successfully!');