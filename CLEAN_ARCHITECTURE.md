# Smart Office - Clean Architecture

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart          # App-wide constants
│   └── utils/
│       ├── image_utils.dart            # Image processing utilities
│       └── temperature_utils.dart      # Temperature-related utilities
├── models/
│   ├── office_state.dart              # Office state model
│   └── user_model.dart                # User model
├── providers/
│   └── office_provider.dart           # State management
├── screens/
│   ├── home/
│   │   └── home_screen.dart           # Main dashboard
│   └── user_management/
│       └── user_management_screen.dart # User management
├── services/
│   ├── face_lock_service.dart         # Face recognition API
│   └── firebase_service.dart          # Firebase integration
├── theme/
│   └── app_theme.dart                 # App theming
└── widgets/
    ├── common/                        # Reusable components
    │   ├── info_card.dart
    │   ├── loading_button.dart
    │   └── status_indicator.dart
    ├── home/                          # Home screen widgets
    │   ├── device_controls_widget.dart
    │   ├── door_control_widget.dart
    │   ├── temperature_widget.dart
    │   └── user_count_widget.dart
    ├── user_management/               # User management widgets
    │   └── user_list_item.dart
    ├── camera_view.dart               # Camera component
    └── gas_detector.dart              # Gas detection alert
```

## Key Improvements

### 1. **Separation of Concerns**
- **Core**: Constants and utilities
- **Models**: Data structures
- **Providers**: State management
- **Services**: External API calls
- **Widgets**: UI components organized by feature

### 2. **Reusable Components**
- `InfoCard`: Generic information display card
- `LoadingButton`: Button with loading state
- `StatusIndicator`: Online/offline status display
- `UserListItem`: Individual user display component

### 3. **Feature-Based Organization**
- Home screen widgets grouped together
- User management widgets separated
- Common widgets for shared components

### 4. **Utility Classes**
- `ImageUtils`: Image processing and compression
- `TemperatureUtils`: Temperature calculations and colors
- `AppConstants`: Centralized configuration

### 5. **Removed Redundancy**
- Eliminated duplicate LED control widget
- Removed unnecessary demo files
- Consolidated similar functionality

## Benefits

1. **Maintainability**: Clear structure makes code easier to maintain
2. **Reusability**: Common widgets can be used across screens
3. **Testability**: Separated concerns make unit testing easier
4. **Scalability**: Easy to add new features without cluttering
5. **Performance**: Smaller, focused widgets improve rendering

## Usage

### Adding New Features
1. Create models in `models/` if needed
2. Add business logic to appropriate provider
3. Create reusable widgets in `widgets/common/`
4. Implement feature-specific widgets in appropriate folders
5. Add constants to `app_constants.dart`

### Styling
- All colors and themes are centralized in `app_theme.dart`
- Use theme colors instead of hardcoded values
- Consistent spacing and sizing through constants

### State Management
- Use Provider pattern for state management
- Keep UI logic in widgets, business logic in providers
- Services handle external API calls only