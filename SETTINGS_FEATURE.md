# Mini Music - Settings Feature Documentation

## Overview
The Mini Music app has been upgraded with a comprehensive settings menu that includes all necessary features for app store submission, plus user customization options.

## New Features Added

### 1. **Settings Screen** (`lib/screens/settings/settings_screen.dart`)
The main settings page with organized sections:

#### 🎵 Audio Settings
- **High Quality**: Toggle between standard and high-quality audio streaming
- **Stream Quality**: Slider control for audio quality (0-100%)
- **Auto-play Next**: Automatically play the next song when current finishes

#### 🎨 Personalization
- **Language Selection**: Choose between:
  - Tiếng Việt (Vietnamese)
  - English
  - Español (Spanish)
  - Français (French)
  - Deutsch (German)
  - 日本語 (Japanese)
  
- **Default Trending Category**: Select default trending music source:
  - 🌍 Global
  - 🇻🇳 Vietnam
  - 🌏 Asia
  - 🎤 K-Pop
  - 🎸 Western

#### 🔔 Notifications
- **Enable Notifications**: Toggle push notifications for new music and updates

#### ⚖️ Legal & Policies
- **Privacy Policy**: Comprehensive privacy documentation
- **Terms of Service**: Full terms and conditions for app usage

#### ℹ️ About App
- App version and build information
- Feature showcase
- Technology stack information
- Credits and acknowledgments

#### ⚠️ Danger Zone
- **Reset Settings**: Restore all settings to defaults with confirmation dialog

### 2. **State Management** (BLoC Pattern)
- **SettingsCubit** (`lib/blocs/settings/settings_cubit.dart`): Handles all settings state management
- **SettingsState** (`lib/blocs/settings/settings_state.dart`): Defines state classes (Initial, Loading, Loaded, Error)

### 3. **Data Models** (`lib/models/settings_model.dart`)
- **AppSettings**: Main settings model with copyWith support
- **AppLanguage**: Enum with language codes and display names
- **TrendingCategory**: Enum for trending music categories

### 4. **Persistent Storage** (`lib/services/settings/settings_service.dart`)
- Uses `SharedPreferences` for data persistence
- Auto-saves settings when changed
- Loads settings on app startup

### 5. **Sub-screens**

#### Language Settings Screen
- Selectable list of all available languages
- Visual indicator for currently selected language
- Automatically saves and closes on selection

#### Trending Settings Screen  
- Selectable list of trending categories
- Visual indicator for default category
- Smooth navigation back to main settings

#### Privacy & Terms Screen
- Scrollable content view
- Full privacy policy with 8 sections
- Complete terms of service with 12 sections
- Professional legal documentation

#### About Screen
- App branding and version info
- Feature highlights with emoji icons
- Technology stack information
- Professional design with gradient header

### 6. **UI Enhancements**
All screens feature:
- Modern dark theme consistent with app design
- Gradient accents with Spotify green (#1DB954)
- Smooth animations and transitions
- Responsive design for all screen sizes
- Professional spacing and typography

## Integration Points

### Main App (`lib/main.dart`)
- SettingsService initialized before app launch
- SettingsCubit added to BlocProvider
- Settings loaded on startup

### Home Screen (`lib/screens/home/home_screen.dart`)
- Settings icon button added to app bar
- Easy access to settings from main screen
- Smooth navigation with MaterialPageRoute

## File Structure
```
lib/
├── blocs/
│   └── settings/
│       ├── settings_cubit.dart
│       └── settings_state.dart
├── models/
│   └── settings_model.dart
├── screens/
│   ├── settings/
│   │   ├── settings_screen.dart
│   │   ├── language_settings_screen.dart
│   │   ├── trending_settings_screen.dart
│   │   ├── privacy_terms_screen.dart
│   │   ├── about_screen.dart
│   │   ├── components/
│   │   │   └── settings_widgets.dart
│   │   └── privacy_body.dart
│   └── home/
│       └── home_screen.dart (updated)
└── services/
    └── settings/
        └── settings_service.dart
```

## Usage Example

### Accessing Settings
```dart
// From home screen or any page
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const SettingsScreen(),
  ),
);
```

### Using Settings in Your Code
```dart
// Get current settings
final settings = context.read<SettingsCubit>().state as SettingsLoaded;
final currentLanguage = settings.settings.language;

// Update a setting
context.read<SettingsCubit>().changeLanguage(AppLanguage.english);
```

## App Store Compliance

This settings menu includes all necessary elements for app store submission:

✅ **Privacy Policy** - Legal document outlining data collection practices  
✅ **Terms of Service** - User agreement and terms  
✅ **About Section** - App information and version  
✅ **Settings** - User preferences and customization  
✅ **Permissions Info** - Technology stack transparency  

## Future Enhancements

Potential features to add:
- Biometric authentication for settings lock
- Cloud sync of settings across devices
- Dark/Light theme toggle
- Offline mode settings
- Download quality preferences
- Playlist management settings
- Cache management and cleanup
- User feedback and bug reporting

## Testing

To test the settings feature:
1. Run the app: `flutter run`
2. Tap the ⚙️ settings icon in the top-right of the home screen
3. Navigate through different settings sections
4. Test language switching (requires app restart or rebuilding)
5. Test persistence by killing and restarting the app

## Dependencies Used

- `flutter_bloc`: State management
- `shared_preferences`: Persistent storage
- `equatable`: Value equality in BLoC

All dependencies are already included in pubspec.yaml
