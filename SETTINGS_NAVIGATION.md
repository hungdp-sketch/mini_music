# Mini Music Settings Navigation Flow

## User Interface Flow

```
Home Screen
    ↓
    [⚙️ Settings Button in AppBar]
    ↓
┌─────────────────────────────────────────────────────┐
│           SETTINGS SCREEN (Main Menu)                │
├─────────────────────────────────────────────────────┤
│                                                     │
│  🎵 AUDIO SETTINGS                                  │
│  ├─ High Quality         [Toggle Switch]            │
│  ├─ Stream Quality       [Slider 0-100%]            │
│  └─ Auto-play Next       [Toggle Switch]            │
│                                                     │
│  🎨 PERSONALIZATION                                 │
│  ├─ Language              [→] Vietnamese            │
│  │   └─ LanguageSettingsScreen                      │
│  │      • Vietnamese                                │
│  │      • English                                   │
│  │      • Spanish                                   │
│  │      • French                                    │
│  │      • German                                    │
│  │      • Japanese                                  │
│  │                                                  │
│  └─ Trending Category    [→] Global 🌍             │
│     └─ TrendingSettingsScreen                       │
│        • Global 🌍                                  │
│        • Vietnam 🇻🇳                               │
│        • Asia 🌏                                    │
│        • K-Pop 🎤                                   │
│        • Western 🎸                                 │
│                                                     │
│  🔔 NOTIFICATIONS                                   │
│  └─ Enable Notifications [Toggle Switch]            │
│                                                     │
│  ⚖️ LEGAL & POLICIES                                │
│  ├─ Privacy Policy       [→] PrivacyTermsScreen    │
│  │   (8 sections)                                   │
│  │   • Information Collection                       │
│  │   • Data Usage                                   │
│  │   • Data Security                                │
│  │   • Your Rights                                  │
│  │   • Children's Privacy                           │
│  │   • Policy Changes                               │
│  │   • Contact Info                                 │
│  │   • Data Retention                               │
│  │                                                  │
│  └─ Terms of Service     [→] PrivacyTermsScreen    │
│     (12 sections)                                   │
│     • Acceptance of Terms                           │
│     • Use License                                   │
│     • Disclaimer                                    │
│     • Limitations                                   │
│     • Materials Accuracy                            │
│     • Copyright                                     │
│     • Liability Limits                              │
│     • Modifications                                 │
│     • Third-party Services                          │
│     • Cancellation                                  │
│     • Governing Law                                 │
│     • Contact Information                           │
│                                                     │
│  ℹ️ ABOUT                                           │
│  └─ About Mini Music    [→] AboutScreen            │
│     • App Icon                                      │
│     • Version (1.0.0)                               │
│     • Description                                   │
│     • Features Showcase                             │
│     • Technology Stack                              │
│     • Copyright                                     │
│                                                     │
│  ⚠️ DANGER ZONE                                     │
│  └─ Reset Settings      [→] Confirmation Dialog    │
│     └─ Are you sure?                                │
│        • Cancel                                     │
│        • Reset (RED)                                │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## Data Flow (BLoC Pattern)

```
┌──────────────────────┐
│   Settings Screen    │
└──────↑───────────────┘
       │
       │ UI Events
       │ (toggleNotifications, changeLanguage, etc.)
       ↓
┌──────────────────────────────┐
│   SettingsCubit (BLoC)       │
├──────────────────────────────┤
│ loadSettings()               │
│ changeLanguage()             │
│ changeTrendingCategory()     │
│ toggleNotifications()        │
│ toggleHighQuality()          │
│ setStreamQuality()           │
│ toggleAutoPlayNext()         │
│ resetSettings()              │
└──────┬───────────────────────┘
       │
       │ State Changes
       │ (SettingsLoaded)
       ↓
┌──────────────────────────────┐
│   SettingsService            │
├──────────────────────────────┤
│ SharedPreferences Storage    │
│                              │
│ Keys:                        │
│ • app_language              │
│ • default_trending_category │
│ • enable_notifications      │
│ • enable_high_quality       │
│ • stream_quality            │
│ • auto_play_next            │
│ • dark_mode                 │
└──────────────────────────────┘
```

## Persistence Architecture

```
SharedPreferences (Local Storage)
│
├─ app_language ────────→ "vi" (T. Việt) / "en" (English) / etc.
├─ default_trending_category ──→ "global" / "vietnam" / "asia" / "kpop" / "western"
├─ enable_notifications ────────→ true/false
├─ enable_high_quality ────────→ true/false
├─ stream_quality ──────→ 0.0 to 1.0 (double)
├─ auto_play_next ──────→ true/false
└─ dark_mode ──────→ true/false

On App Launch:
SettingsService.init() → Load all settings → Pass to SettingsCubit → Update UI
```

## Color Scheme & Styling

```
Primary Theme: Dark Mode (Upbeat/Spotify-like)
├─ Background: #0A0A0F (Deep Black)
├─ Surface: #1A1A2E (Dark Blue-Black)
├─ Card: #16213E (Darker Blue)
├─ Primary: #1DB954 (Spotify Green)
├─ Primary Light: #1ED760 (Bright Green)
├─ Secondary Text: #B3B3B3 (Light Gray)
├─ Muted Text: #535353 (Dark Gray)
└─ Accent Gradient: Linear (#1DB954 → #1ED760)

Icons & Emojis:
├─ 🎵 Audio Settings
├─ 🎨 Personalization
├─ 🔔 Notifications
├─ ⚖️ Legal & Policies
├─ ℹ️ About
├─ ⚠️ Danger Zone
├─ 🌍 Global
├─ 🇻🇳 Vietnam
├─ 🌏 Asia
├─ 🎤 K-Pop
└─ 🎸 Western
```

## Component Hierarchy

```
SettingsScreen (StatefulWidget)
│
├─ AppBar
│  └─ Settings Icon (Back button)
│
└─ SingleChildScrollView
   ├─ Section Header
   ├─ _buildSettingsTile (Audio settings)
   │  └─ Icon + Title + Subtitle + Switch/Slider
   │
   ├─ Section Header
   ├─ _buildNavigationTile (Language)
   │  └─ Icon + Title + Subtitle + Forward Arrow
   ├─ _buildNavigationTile (Trending)
   │
   ├─ Section Header
   ├─ _buildSettingsTile (Notifications)
   │
   ├─ Section Header
   ├─ _buildNavigationTile (Privacy)
   ├─ _buildNavigationTile (Terms)
   │
   ├─ Section Header
   ├─ _buildNavigationTile (About)
   │
   └─ Section Header
      ├─ _buildActionTile (Reset - Orange)
```

## Testing Checklist

- [ ] Settings button appears in home screen app bar
- [ ] Settings screen loads without errors
- [ ] All toggles work and save settings
- [ ] Sliders work smoothly
- [ ] Language selection navigates and saves
- [ ] Trending category selection works
- [ ] Privacy policy loads and displays correctly
- [ ] Terms of service loads and displays correctly
- [ ] About screen shows app info
- [ ] Reset settings shows confirmation dialog
- [ ] Settings persist after app restart
- [ ] No analyzer errors complain
- [ ] All screens have proper back navigation
- [ ] UI is responsive on different screen sizes
- [ ] Gradle gradle warnings don't affect functionality
