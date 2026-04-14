import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import '../../models/settings_model.dart';
import '../../models/song_model.dart';
import '../../youtube/yt_audio_resolver.dart';
import 'eq_service.dart';

// Player repeat mode enum
enum PlayerRepeatMode {
  // off, // No repeat
  all, // Repeat all songs in queue
  one, // Repeat current song
}

class AudioPlayerService {
  static final AudioPlayerService instance = AudioPlayerService._init();
  AudioPlayerService._init() {
    _setupListeners();
  }

  final AudioPlayer _player = AudioPlayer(
    audioPipeline: EqService.instance.audioPipeline,
  );
  final List<SongModel> _queue = [];
  int _currentIndex = -1;
  double _currentSpeed = 1.0;
  bool _playRelated = true;
  bool _relatedLoaded = false;
  bool _isShuffle = false;
  PlayerRepeatMode _repeatMode = PlayerRepeatMode.all;

  // Playback-related settings (UI writes -> service applies).
  bool _autoPlayNext = true;
  bool _enableHighQuality = true;
  double _streamQuality = 0.8; // 0.0..1.0

  final BehaviorSubject<bool> playingStream = BehaviorSubject.seeded(false);
  final BehaviorSubject<Duration> _positionSubject = BehaviorSubject.seeded(
    Duration.zero,
  );
  final BehaviorSubject<Duration?> _durationSubject = BehaviorSubject.seeded(
    Duration.zero,
  );

  AudioPlayer get player => _player;
  List<SongModel> get queue => _queue;
  int get currentIndex => _currentIndex;
  bool get isShuffle => _isShuffle;
  PlayerRepeatMode get repeatMode => _repeatMode;

  /// Stream of current playing song (updated immediately on tap, then updated with URL)
  final BehaviorSubject<SongModel?> currentSongStream = BehaviorSubject.seeded(
    null,
  );

  /// Stream of loading state (true while fetching stream URL)
  final BehaviorSubject<bool> loadingStream = BehaviorSubject.seeded(false);

  /// Stream of error messages (null when no error)
  final BehaviorSubject<String?> errorStream = BehaviorSubject.seeded(null);

  /// Stream of playback speed
  final BehaviorSubject<double> speedStream = BehaviorSubject.seeded(1.0);

  /// Stream of player state, filtered to ignore high-frequency position-only updates.
  Stream<PlayerState> get playerStateStream =>
      _player.playerStateStream.distinct(
        (previous, next) =>
            previous.playing == next.playing &&
            previous.processingState == next.processingState,
      );

  /// Stream of playback status.
  Stream<bool> get isPlayingStream => playingStream.distinct();

  /// Stream of position updates, merged between audio and video.
  Stream<Duration> get positionStream => _positionSubject.distinct();

  /// Stream of duration updates with duplicate suppression.
  Stream<Duration?> get durationStream => _durationSubject.distinct();

  /// Setup listeners for player events
  void _setupListeners() {
    // Listen for audio player state changes
    _player.playerStateStream.listen((playerState) {
      playingStream.add(playerState.playing);

      // Hide loading when playback actually starts
      if (playerState.playing) {
        debugPrint('[AudioPlayerService] Playback started, hiding loading...');
        loadingStream.add(false);
      }

      // Auto-play next song when current finishes
      if (playerState.processingState == ProcessingState.completed) {
        if (_autoPlayNext) {
          debugPrint('[AudioPlayerService] Song completed, playing next...');
          playNext();
        } else {
          debugPrint('[AudioPlayerService] Song completed, autoPlayNext=false');
          stop();
        }
      }
    });

    _player.positionStream.sampleTime(const Duration(milliseconds: 300)).listen(
      (position) {
        _positionSubject.add(position);
      },
    );

    _player.durationStream
        .distinct((previous, next) => previous == next)
        .listen((duration) {
          _durationSubject.add(duration);
        });
  }

  void applySettings(AppSettings settings) {
    _autoPlayNext = settings.autoPlayNext;
    _enableHighQuality = settings.enableHighQuality;
    _streamQuality = settings.streamQuality.clamp(0.0, 1.0);
  }

  Future<SongModel?> loadAndPlay(
    SongModel song, {
    bool playRelated = true,
    List<SongModel>? queue,
  }) async {
    try {
      debugPrint(
        '[AudioPlayerService] loadAndPlay: ${song.title} (${song.songId})',
      );
      await _player.stop();

      _playRelated = playRelated;
      _relatedLoaded = false;

      // Show song immediately (without URL) so UI updates fast
      currentSongStream.add(song);
      loadingStream.add(true);
      errorStream.add(null);

      // Manage queue
      if (queue != null) {
        _queue
          ..clear()
          ..addAll(queue);
        _currentIndex = _queue.indexWhere((s) => s.songId == song.songId);
        if (_currentIndex == -1) {
          _queue.add(song);
          _currentIndex = _queue.length - 1;
        }
      } else {
        _currentIndex = _queue.indexWhere((s) => s.songId == song.songId);
        if (_currentIndex == -1) {
          _queue.add(song);
          _currentIndex = _queue.length - 1;
        }
      }

      // Resolve or reuse the URL for the current track
      final queueSong = _queue[_currentIndex];
      final resolvedSong = await _resolveSongUrl(queueSong);
      if (resolvedSong == null) {
        debugPrint('[AudioPlayerService] Failed to get URL for ${song.songId}');
        loadingStream.add(false);
        errorStream.add(
          'Không thể tải bài "${song.title}". YouTube có thể đang rate limit, hãy thử lại sau vài phút.',
        );
        return null;
      }

      _queue[_currentIndex] = resolvedSong;
      currentSongStream.add(resolvedSong);

      // MediaItem for lockscreen/notification
      final mediaItem = MediaItem(
        id: resolvedSong.songId!,
        title: resolvedSong.title ?? 'Unknown',
        artist: resolvedSong.channel ?? 'Unknown',
        artUri: resolvedSong.thumb != null
            ? Uri.parse(resolvedSong.thumb!)
            : null,
        duration: resolvedSong.duration != null
            ? Duration(seconds: resolvedSong.duration!)
            : null,
      );
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(resolvedSong.url!), tag: mediaItem),
        preload: true,
      );

      await _player.play();
      debugPrint('[AudioPlayerService] Audio source set and play initiated');

      if (_playRelated) {
        // Load related songs immediately for better UX
        loadRelated();
      }

      return resolvedSong;
    } catch (e) {
      debugPrint('[AudioPlayerService] Error: $e');
      loadingStream.add(false);
      if (e.toString().contains('RequestLimitExceededException')) {
        errorStream.add(
          'YouTube rate limit exceeded. Please wait a few minutes and try again.',
        );
      } else {
        errorStream.add('Lỗi phát nhạc. Vui lòng thử lại.');
      }
      return null;
    }
  }

  bool get isPlaying => _player.playing;

  void play() {
    _player.play();
  }

  void pause() {
    _player.pause();
  }

  void stop() async {
    await _player.stop();
    await _player.seek(Duration.zero);
  }

  void seek(Duration position) {
    _player.seek(position);
  }

  /// Set playback speed (0.5x to 2.0x)
  Future<void> setSpeed(double speed) async {
    if (speed >= 0.5 && speed <= 2.0) {
      _currentSpeed = speed;
      await _player.setSpeed(speed);
      speedStream.add(speed);
      debugPrint('[AudioPlayerService] Playback speed set to ${speed}x');
    } else {
      debugPrint(
        '[AudioPlayerService] Invalid speed: $speed (range: 0.5x - 2.0x)',
      );
    }
  }

  double getSpeed() => _currentSpeed;

  void playNext() {
    // Handle repeat one mode
    if (_repeatMode == PlayerRepeatMode.one) {
      loadAndPlay(_queue[_currentIndex]);
      return;
    }

    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
      loadAndPlay(_queue[_currentIndex]);
    } else {
      // End of queue - handle repeat all
      if (_repeatMode == PlayerRepeatMode.all) {
        _currentIndex = 0;
        loadAndPlay(_queue[_currentIndex]);
      } else {
        debugPrint('[AudioPlayerService] No next song in queue');
        stop();
      }
    }
  }

  void playPrevious() {
    if (_currentIndex > 0) {
      _currentIndex--;
      loadAndPlay(_queue[_currentIndex]);
    }
  }

  void addToQueue(SongModel song) {
    if (!_queue.any((s) => s.songId == song.songId)) {
      _queue.add(song);
    }
  }

  void clearQueue() {
    _queue.clear();
    _currentIndex = -1;
    _relatedLoaded = false;
  }

  Future<void> loadRelated() async {
    if (!_playRelated || _relatedLoaded) return;
    if (_currentIndex < 0 || _currentIndex >= _queue.length) return;

    final currentSong = _queue[_currentIndex];
    if (currentSong.songId == null) return;

    debugPrint(
      '[AudioPlayerService] Loading related songs for ${currentSong.songId}',
    );
    final relatedSongs = await YtAudioResolver.getRelatedSongs(
      videoId: currentSong.songId!,
      title: currentSong.title,
    );

    if (relatedSongs.isEmpty) {
      debugPrint('[AudioPlayerService] No related songs found');
      _relatedLoaded = true;
      return;
    }

    final newRelated = relatedSongs.where(
      (song) => !_queue.any((existing) => existing.songId == song.songId),
    );

    _queue.addAll(newRelated);
    _relatedLoaded = true;
    debugPrint(
      '[AudioPlayerService] Added ${newRelated.length} related songs to queue',
    );
  }

  Future<SongModel?> _resolveSongUrl(SongModel song) async {
    if (song.url != null) return song;

    for (final queued in _queue) {
      if (queued.songId == song.songId && queued.url != null) {
        return queued;
      }
    }

    final url = await YtAudioResolver.getAudioUrl(
      song.songId!,
      preferHighQuality: _enableHighQuality,
      streamQuality: _streamQuality,
    );
    if (url == null) return null;
    return song.copyWith(url: url);
  }

  /// Toggle shuffle mode
  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    if (_isShuffle && _queue.isNotEmpty) {
      _shuffleQueue();
    } else {
      // When disable shuffle, restore original queue order (not implemented here,
      // would need to store original order)
      debugPrint('[AudioPlayerService] Shuffle disabled');
    }
  }

  /// Shuffle the queue while keeping current song at same position
  void _shuffleQueue() {
    if (_queue.isEmpty || _currentIndex < 0) return;

    final currentSong = _queue[_currentIndex];
    final randomizer = Random();

    // Fisher-Yates shuffle
    for (int i = _queue.length - 1; i > 0; i--) {
      final j = randomizer.nextInt(i + 1);
      final temp = _queue[i];
      _queue[i] = _queue[j];
      _queue[j] = temp;
    }

    // Update current index to where the current song ended up
    _currentIndex = _queue.indexOf(currentSong);
    debugPrint('[AudioPlayerService] Queue shuffled');
  }

  /// Cycle through repeat modes: OFF -> ALL -> ONE -> OFF
  void toggleRepeatMode() {
    switch (_repeatMode) {
      // case PlayerRepeatMode.off:
      //   _repeatMode = PlayerRepeatMode.all;
      //   break;
      case PlayerRepeatMode.all:
        _repeatMode = PlayerRepeatMode.one;
        break;
      case PlayerRepeatMode.one:
        _repeatMode = PlayerRepeatMode.all;
        break;
    }
    debugPrint('[AudioPlayerService] Repeat mode: $_repeatMode');
  }

  // Video rendering is intentionally not owned by this service.
}

