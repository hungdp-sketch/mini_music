# Mini Music - Language & Trending Updates

## Changes Made

### 1. **Language Support Reduced to 2 Options**
   - **Before**: 6 languages (Vietnamese, English, Spanish, French, German, Japanese)
   - **After**: Only 2 languages
     - ✅ Tiếng Việt (Vietnamese)
     - ✅ English

**File Modified**: `lib/models/settings_model.dart`

### 2. **Trending Category Now Affects Entire App**
   - Each trending category now maps to a **country code** that changes trending content
   - When user selects a category in settings, the entire app reloads trending songs for that region

**Trending Categories with Country Codes**:
- 🌍 Toàn cầu (Global) → **VN** (Vietnam - Default)
- 🇻🇳 Việt Nam → **VN** (Vietnam)
- 🌏 Châu Á (Asia) → **TH** (Thailand)
- 🎤 K-Pop → **KR** (Korea)
- 🎸 Phương Tây (Western) → **US** (USA)

**Files Modified**:
1. `lib/models/settings_model.dart` - Added `countryCode` property to TrendingCategory
2. `lib/services/settings/settings_service.dart` - Added helper method for extracting country code
3. `lib/blocs/search/search_cubit.dart` - Updated `loadTrending()` to accept category parameter
4. `lib/blocs/settings/settings_cubit.dart` - Integrated with SearchCubit to reload trending
5. `lib/screens/home/home_screen.dart` - Load initial trending with default category
6. `lib/main.dart` - Pass SearchCubit to SettingsCubit

### 3. **How It Works**

```
User Changes Trending Category in Settings
    ↓
SettingsCubit.changeTrendingCategory()
    ↓
Save to SharedPreferences
    ↓
Get country code from selected category
    ↓
Call SearchCubit.loadTrending(category: selectedCategory)
    ↓
MusicApi.getTrending(countryCode: category.countryCode)
    ↓
Entire app updates with new region's trending songs
```

### 4. **App Startup Flow**

1. SettingsService initializes and loads saved settings
2. SettingsCubit loads settings from StorageService
3. HomeScreen checks default trending category from settings
4. SearchCubit loads trending with category's country code
5. Home screen displays appropriate trending content

### 5. **User Experience**

**Before**: Users could select from 6 languages but trending was always the same (Vietnam by default)

**After**: 
- Only 2 language options (simpler UI)
- Users can select different regions to see trending music from that region
- Category selection immediately updates all trending content across the app
- Settings persist when app is closed and reopened

### 6. **Testing Changes**

To test the new features:

1. **Language Selection**:
   - Open Settings (⚙️ icon)
   - Go to "Ngôn ngữ" (Language)
   - Should see only 2 options: Tiếng Việt and English
   - Select one and go back

2. **Trending Category Selection & Impact**:
   - Open Settings (⚙️ icon)
   - Go to "Thể loại xu hướng mặc định" (Trending Category)
   - Select different regions (Global, Vietnam, Asia, K-Pop, Western)
   - Go back to home screen
   - **The trending songs should update** based on selected region
   - Try K-Pop to see Korean music, Western to see American/UK music, etc.

3. **Persistence**:
   - Change settings
   - Close and reopen the app
   - Settings should be preserved

### 7. **Code Quality**

✅ No compilation errors
✅ All state management follows BLoC pattern
✅ Properly uses SharedPreferences for persistence
✅ Context usage is safe with `mounted` checks
✅ Follows existing code conventions and style

### 8. **Summary of Benefits**

| Aspect | Before | After |
|--------|--------|-------|
| Languages | 6 languages | 2 languages (simplified) |
| Trending Categories | No effect on app | Affects all trending content |
| Region-specific Music | Not possible | Can select from 5 regions |
| User Customization | Limited | Full control over content |
| App Load | Always Vietnam | Uses selected region |

## Technical Implementation

### Country Code Mapping
```dart
enum TrendingCategory {
  global('global', '🌍 Toàn cầu', 'VN'),      // Default
  vietnam('vietnam', '🇻🇳 Việt Nam', 'VN'),
  asia('asia', '🌏 Châu Á', 'TH'),
  kpop('kpop', '🎤 K-Pop', 'KR'),
  western('western', '🎸 Phương Tây', 'US');
  
  final String countryCode;  // Used for MusicApi.getTrending()
}
```

### Integration Points
1. **Settings Screen** - User selects category
2. **SettingsCubit** - Saves and triggers reload
3. **SearchCubit** - Loads trending with new country code
4. **Home Screen** - Displays updated content
5. **MusicApi** - Fetches region-specific trending content

All changes maintain backward compatibility and don't break existing functionality.
