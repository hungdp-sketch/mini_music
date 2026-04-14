# Upbeat Performance Audit

## 🔍 Issues Found

- `PlayerCubit` emitted on raw `positionStream` updates, causing frequent global state rebuilds.
- `HomeScreen` used a nested `BlocBuilder` for every song row, so playback state changes caused all visible list items to rebuild.
- `FullPlayerScreen` rebuilt the entire heavy UI tree (blurred background, artwork, controls) on each position update.
- `MiniPlayerBar` lacked `buildWhen` filtering and `RepaintBoundary`, increasing repaint scope.
- `AudioPlayerService` exposed raw audio streams without duplicate suppression or throttling.

## ⚡ Suggested Fixes

- Throttle playback position updates to `300ms`.
- Filter duplicate and noisy `PlayerState` emissions.
- Use `context.select` in song lists to react only to the current song / loading state.
- Add `buildWhen` to playback widgets and isolate frequently changing subtrees.
- Add `RepaintBoundary` around mini-player UI.
- Use `itemExtent` for queue lists to improve list layout performance.
- Clean up stream subscriptions in the cubit to avoid leaks.

## 🧠 Refactored Areas

- `lib/services/player/audio_player_service.dart`
  - Throttled `positionStream`
  - Filtered duplicate `playerStateStream`
- `lib/blocs/player/player_cubit.dart`
  - Added subscription management and `close()` cleanup
  - Added `distinct()` and duplicate suppression on audio streams
- `lib/screens/home/home_screen.dart`
  - Replaced nested playback `BlocBuilder` with `context.select`
  - Reduced rebuild scope for song tiles
- `lib/screens/player/mini_player_bar.dart`
  - Added `buildWhen`
  - Wrapped with `RepaintBoundary`
- `lib/screens/player/full_player_screen.dart`
  - Isolated seek bar updates in `_PlayerSeekBar`
  - Prevented full-screen redraws on every progress tick
- `lib/screens/queue/queue_bottom_sheet.dart`
  - Added `itemExtent` for fixed-height rows

## 🚀 Expected Impact

- Significantly fewer UI rebuilds from playback updates
- Smoother scrolling and stable 60fps in song lists
- Lower memory churn from managed subscriptions
- Better UI responsiveness while music playback continues
