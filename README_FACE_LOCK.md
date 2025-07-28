# Face Lock API Integration

This Smart Office app now integrates with the Face Lock API (https://face-lock-api.onrender.com/) for user management and face recognition.

## Features

### User Management
- **Add Users**: Create new users with name, email, and role
- **Edit Users**: Update existing user information
- **Delete Users**: Remove users from the system
- **Face Registration**: Add face images for users via camera
- **Face Verification**: Verify identity using face recognition

### How to Use

#### 1. Adding a New User
1. Tap "Add New User" button
2. Fill in name, email, and select role (Admin/Employee)
3. Tap "Add" to create the user

#### 2. Adding Face Image
1. Find the user in the list
2. Tap the menu button (⋮) next to their name
3. Select "Add Face"
4. Take a photo using the camera
5. The face image will be uploaded and associated with the user

#### 3. Face Verification
1. Tap "Verify Face" button on the main screen
2. Take a photo using the camera
3. The system will identify the person and show their details

#### 4. Managing Users
- **Edit**: Tap menu (⋮) → Edit to modify user details
- **Delete**: Tap menu (⋮) → Delete to remove user
- **Refresh**: Tap the refresh icon in the app bar to reload data

## API Endpoints Used

- `GET /users` - Fetch all users
- `POST /users` - Create new user
- `PUT /users/{id}` - Update user
- `DELETE /users/{id}` - Delete user
- `POST /users/{id}/face` - Upload face image
- `POST /verify` - Verify face identity

## Error Handling

The app includes comprehensive error handling:
- Network connectivity issues
- API server errors
- Invalid responses
- Camera access problems

All errors are displayed as user-friendly messages with appropriate actions.

## Requirements

- Camera permission for face capture
- Internet connection for API communication
- Flutter dependencies: `http`, `image_picker`