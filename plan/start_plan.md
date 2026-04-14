# Kế hoạch: Mini Music Player — audio-only + EQ

## Tóm tắt thay đổi so với draft cũ

| Quyết định | Lựa chọn |
|---|---|
| 📁 Vị trí project | `/Users/hung/Documents/job/mini_music/` |
| 🗄 Database local | **Không** — queue in-memory, mất khi tắt app |
| 🏠 Home screen | **Có** — trending list mặc định |
| 📱 Platform | **iOS + Android** cả hai |
| 🎵 Player engine | **just_audio** (thay toàn bộ video_player) |
| 🎞 Stream type | **Audio-only** (không dùng video stream) |
| 🎛 Equalizer | **AndroidEqualizer** (built-in just_audio) + custom iOS |

---

## Thay đổi kiến trúc lớn nhất: PlayerService mới

Dự án cũ dùng `video_player` + `VideoPlayerController` để phát video (âm thanh lấy từ video stream). App mới **viết lại hoàn toàn** PlayerService dùng `just_audio`:

```
youtube_explode_dart
    → manifest.audioOnly.withHighestBitrate()  ← chỉ lấy audio stream
    → AudioSource.uri(audioUrl)
    → just_audio AudioPlayer
    → just_audio_background (lockscreen/notification)
    → audio_session (interrupt handling)
    → AndroidEqualizer (Android EQ)
```

### EQ Strategy — thực tế nhất cho cả 2 platform

| Platform | Giải pháp | Lý do |
|---|---|---|
| **Android** | `AndroidEqualizer` (tích hợp sẵn trong `just_audio`) | Native Android audio session EQ, full band control |
| **iOS** | `AVAudioUnitEQ` qua platform channel | iOS không có public EQ API, phải dùng AVAudioEngine bridge |

> [!WARNING]
> **EQ trên iOS là custom native code.** Sẽ cần viết Swift code dùng `AVAudioEngine` + `AVAudioUnitEQ` và bridge qua `MethodChannel`. Phức tạp hơn Android nhưng khả thi. Nếu muốn đơn giản hơn, có thể **chỉ làm Android EQ trước**, iOS hiển thị UI nhưng không có effect.

---

## Cấu trúc project mới

```
/Users/hung/Documents/job/mini_music/
├── lib/
│   ├── main.dart                        # App entry, init AudioPlayer + EQ
│   ├── app.dart                         # MaterialApp, dark theme, routes
│   │
│   ├── core/
│   │   ├── constants.dart               # API keys, endpoint URLs
│   │   └── theme.dart                   # Dark theme, colors, typography
│   │
│   ├── models/
│   │   └── song_model.dart              # Copy + simplify từ upbeat-v-3
│   │
│   ├── network/
│   │   ├── api_network.dart             # HTTP client (Dio)
│   │   ├── session_network.dart         # Session HTTP
│   │   └── music_api.dart               # Chỉ giữ: search, trending, suggestions
│   │
│   ├── youtube/
│   │   └── yt_audio_resolver.dart       # Wrap youtube_explode: lấy audioOnly URL
│   │
│   ├── helper/
│   │   ├── aes_crypto/                  # Copy từ upbeat-v-3 (decrypt API)
│   │   └── utils.dart                   # Copy + trim
│   │
│   ├── services/
│   │   └── player/
│   │       ├── audio_player_service.dart # VIẾT MỚI — just_audio core
│   │       ├── eq_service.dart           # EQ: AndroidEqualizer + iOS bridge
│   │       └── audio_handler.dart        # just_audio_background handler
│   │
│   ├── blocs/
│   │   ├── search/
│   │   │   ├── search_cubit.dart         # Search state
│   │   │   └── search_state.dart
│   │   └── player/
│   │       ├── player_cubit.dart         # Play/pause/queue state
│   │       └── player_state.dart
│   │
│   └── screens/
│       ├── home/
│       │   ├── home_screen.dart          # Search bar + trending list
│       │   └── components/
│       │       ├── song_tile.dart        # Bài hát trong list
│       │       └── trending_section.dart
│       ├── player/
│       │   ├── full_player_screen.dart   # Full-screen player
│       │   ├── mini_player_bar.dart      # Bottom mini player
│       │   └── components/
│       │       ├── seek_bar.dart         # Progress bar
│       │       ├── player_controls.dart  # Play/pause/next/prev buttons
│       │       └── eq_panel.dart         # EQ bands UI
│       └── queue/
│           └── queue_bottom_sheet.dart   # Danh sách hàng chờ
│
├── android/                             # Android config (EQ permissions, etc.)
├── ios/
│   └── Runner/
│       └── AVAudioEQBridge.swift         # iOS EQ native bridge
├── pubspec.yaml
└── assets/
    └── icons/
```

---

## Dependencies tối giản

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_bloc: ^8.1.1
  equatable: ^2.0.3

  # Audio player (CORE — thay thế video_player)
  just_audio: ^0.9.41
  just_audio_background: ^0.0.1-beta.12
  audio_session: ^0.1.21

  # YouTube audio extraction (giữ nguyên logic)
  youtube_explode_dart: ^2.3.6

  # Network
  dio: ^5.0.0
  http: ^1.2.0

  # UI
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  flutter_screenutil: ^5.9.0
  marquee: ^2.2.3

  # Utilities
  shared_preferences: ^2.2.3
  encrypt: ^5.0.3
  xml2json: ^5.3.6
  html_unescape: ^2.0.0
  rxdart: ^0.28.0
  collection: ^1.18.0
  html: ^0.15.4
```

**Bỏ hoàn toàn so với upbeat-v-3:**
`video_player`, `audio_service` (thay bằng `just_audio_background`), `firebase_*`, `google_mobile_ads`, `in_app_purchase*`, `speech_to_text`, `flutter_shazam_kit`, `background_fetch`, `wakelock`, `app_tracking_transparency`, `share_plus`, `facebook_app_events`, `easy_localization`, `flutter_svg`, `app_links`, `url_launcher`, `permission_handler`, `flutter_slidable`, `hive`, `path_provider`, `unicode`, `quiver`, `tuple`, `ripple_wave`, `app_settings`, `material_design_icons_flutter`, `package_info_plus`, `device_info_plus`, `webview_flutter`, `in_app_purchase_storekit`

---

## Luồng phát nhạc mới (audio-only)

```
1. User tap bài hát (SongModel có songId = YouTube video ID)
         ↓
2. YtAudioResolver.getAudioUrl(songId)
   → youtube_explode_dart
   → yt.videos.streamsClient.getManifest(songId)
   → manifest.audioOnly.withHighestBitrate()
   → trả về stream URL (string)
         ↓
3. AudioPlayerService.playFromUrl(url, metadata)
   → player.setAudioSource(AudioSource.uri(Uri.parse(url)))
   → player.play()
         ↓
4. just_audio_background
   → lockscreen notification (iOS + Android)
   → media buttons (headset, CarPlay)
         ↓
5. audio_session xử lý interrupt
   → phone call → tự pause
   → headphones unplug → pause
         ↓
6. EQ applied realtime
   → Android: AndroidEqualizer.enabled = true
   → iOS: AVAudioUnitEQ bands adjusted qua MethodChannel
```

---

## Chi tiết EQ Implementation

### Android (built-in just_audio)
```dart
// Khởi tạo player với EQ
final equalizer = AndroidEqualizer();
final player = AudioPlayer(
  androidAudioEffects: [equalizer],
);

// Điều chỉnh band
final params = await equalizer.parameters;
for (final band in params.bands) {
  band.setGain(0.0); // reset
}
// Ví dụ: boost bass
params.bands[0].setGain(6.0); // 60Hz
params.bands[1].setGain(3.0); // 230Hz
```

### iOS (AVAudioEngine bridge)
```swift
// ios/Runner/AVAudioEQBridge.swift
// Đăng ký MethodChannel "mini_music/eq"
// Expose: setGain(band: Int, gain: Float)
// AVAudioEngine → AVAudioUnitEQ → setBands
```

### EQ Presets (5 preset phổ biến)
| Preset | Bass | Low-Mid | Mid | High-Mid | Treble |
|---|---|---|---|---|---|
| Flat | 0 | 0 | 0 | 0 | 0 |
| Bass Boost | +6 | +3 | 0 | 0 | 0 |
| Treble Boost | 0 | 0 | 0 | +3 | +6 |
| Rock | +4 | +2 | -1 | +2 | +4 |
| Pop | -1 | +3 | +4 | +3 | -1 |

---

## 3 Màn hình chính

### 🏠 Home Screen
- Search bar luôn hiện trên cùng
- Gõ → instant suggestions (debounce 400ms)
- Trending list bên dưới (load khi mở app)
- Tap bài → load audio URL → phát ngay
- Mini player bar dính bottom (ẩn khi chưa phát)

### 🎵 Full Player Screen
- Swipe up từ mini player
- Thumbnail lớn (circle/square animated)
- Tên bài + kênh (marquee nếu dài)
- Seek bar + thời gian
- Nút: prev / play-pause / next
- Toggle: repeat / shuffle
- Nút mở EQ panel
- Nút mở Queue

### 🎛 EQ Panel (bottom sheet từ Full Player)
- 5 band sliders (vertical)
- 5 preset buttons
- Toggle bật/tắt EQ
- Label: 60Hz / 230Hz / 910Hz / 3.6kHz / 14kHz

---

## Kế hoạch thực thi (5 Phase)

### Phase 1 — Setup project (1 ngày)
- [ ] `flutter create mini_music --org com.hung.minimusic`
- [ ] Cập nhật `pubspec.yaml`
- [ ] Setup Android manifest (INTERNET permission, cleartext localhost)
- [ ] Setup iOS Info.plist (NSAllowsArbitraryLoads, background modes)
- [ ] Setup dark theme + typography

### Phase 2 — Copy & build core modules (2 ngày)
- [ ] Copy `helper/aes_crypto/` từ upbeat-v-3
- [ ] Copy & trim `models/song_model.dart`
- [ ] Copy & clean network layer → giữ: search, trending, suggestion APIs
- [ ] Viết `youtube/yt_audio_resolver.dart` (audio-only URL fetch bằng youtube_explode_dart)
- [ ] Test resolver: log URL ra console

### Phase 3 — Player Engine (2 ngày)
- [ ] Viết `audio_handler.dart` (BaseAudioHandler cho just_audio_background)
- [ ] Viết `audio_player_service.dart`:
  - loadAndPlay(SongModel): gọi resolver → setAudioSource → play
  - queue management: skipNext, skipPrevious, addToQueue
  - repeat/shuffle toggle
  - error handling: skip khi lỗi, max retry 3 lần
- [ ] Viết `eq_service.dart`:
  - Android: AndroidEqualizer setup
  - iOS: MethodChannel bridge stub
  - applyPreset(EqPreset) method
- [ ] Viết Swift `AVAudioEQBridge.swift` cho iOS

### Phase 4 — BLoC + UI (3 ngày)
- [ ] `SearchCubit`: state idle/loading/results/error + suggestion debounce
- [ ] `PlayerCubit`: wrap AudioPlayerService streams
- [ ] Home screen: search bar + song list + shimmer loading
- [ ] Full player screen: controls + seek bar
- [ ] Mini player bar: slide-up gesture
- [ ] Queue bottom sheet: list + reorder
- [ ] EQ panel bottom sheet: sliders + presets

### Phase 5 — Test & ổn định (2 ngày)
- [ ] Test background playback (iOS + Android)
- [ ] Test lockscreen controls
- [ ] Test headphone unplug → pause
- [ ] Test phone call interrupt → pause → resume
- [ ] Test error URL → auto skip
- [ ] Test EQ Android bật/tắt
- [ ] Test EQ iOS bridge
- [ ] Test search suggestion debounce
- [ ] Test queue: thêm, xóa, reorder

---

## Rủi ro & cách xử lý

| Rủi ro | Khả năng | Cách xử lý |
|---|---|---|
| YouTube stream URL expired | Cao | Không cache URL, luôn fetch mới trước khi play |
| youtube_explode_dart bị block | Trung bình | Giữ fallback dùng server API (như upbeat-v-3) |
| iOS EQ bridge phức tạp | Cao | Làm Android trước, iOS EQ là Phase 5+ |
| Audio format không hỗ trợ trên iOS | Trung bình | Chọn m4a/aac thay vì webm khi filter audioOnly |
