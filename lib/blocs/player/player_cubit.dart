import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/song_model.dart';
import '../../services/history/history_service.dart';
import '../../services/player/audio_player_service.dart';
import '../../blocs/history/history_cubit.dart';
import 'package:just_audio/just_audio.dart';

// States
class PlayerCubitState extends Equatable {
  final SongModel? currentSong;
  final PlayerState? playerState;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final List<SongModel> queue;
  final bool isLoading;
  final String? errorMessage;
  final double playbackSpeed;
  // final LyricContent? lyrics;
  final bool lyricsLoading;
  final bool isShuffle;
  final PlayerRepeatMode repeatMode;
  final bool isVideoEnabled;

  const PlayerCubitState({
    this.currentSong,
    this.playerState,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.queue = const [],
    this.isLoading = false,
    this.errorMessage,
    this.playbackSpeed = 1.0,
    // this.lyrics,
    this.lyricsLoading = false,
    this.isShuffle = false,
    this.repeatMode = PlayerRepeatMode.all,
    this.isVideoEnabled = false,
  });

  PlayerCubitState copyWith({
    SongModel? currentSong,
    PlayerState? playerState,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    List<SongModel>? queue,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    double? playbackSpeed,
    // LyricContent? lyrics,
    bool? lyricsLoading,
    bool? isShuffle,
    PlayerRepeatMode? repeatMode,
    bool? isVideoEnabled,
  }) {
    return PlayerCubitState(
      currentSong: currentSong ?? this.currentSong,
      playerState: playerState ?? this.playerState,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      queue: queue ?? this.queue,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      // lyrics: lyrics ?? this.lyrics,
      lyricsLoading: lyricsLoading ?? this.lyricsLoading,
      isShuffle: isShuffle ?? this.isShuffle,
      repeatMode: repeatMode ?? this.repeatMode,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
    );
  }

  @override
  List<Object?> get props => [
    currentSong,
    playerState,
    isPlaying,
    position,
    duration,
    queue,
    isLoading,
    errorMessage,
    playbackSpeed,
    isShuffle,
    repeatMode,
    isVideoEnabled,
  ];
}

// Cubit
class PlayerCubit extends Cubit<PlayerCubitState> {
  final AudioPlayerService _service = AudioPlayerService.instance;
  final HistoryService historyService;
  final HistoryCubit historyCubit;
  final List<StreamSubscription> _subscriptions = [];

  PlayerCubit(this.historyService, this.historyCubit)
    : super(const PlayerCubitState()) {
    _init();
  }

  void _init() {
    _subscriptions.addAll([
      _service.currentSongStream.distinct().listen((song) async {
        emit(state.copyWith(currentSong: song, queue: _service.queue));
        // Update history when a song with URL starts playing (indicating successful load)
        if (song != null && song.url != null) {
          await historyService.addSong(song);
          historyCubit.loadRecently();
          // Load lyrics for the song
          // Future.delayed(const Duration(seconds: 2), () {
          //   loadLyrics();
          // });
        }
      }),
      _service.playerStateStream.listen((playerState) {
        emit(state.copyWith(playerState: playerState));
      }),
      _service.isPlayingStream.listen((isPlaying) {
        emit(state.copyWith(isPlaying: isPlaying));
      }),
      _service.positionStream.listen((position) {
        emit(state.copyWith(position: position));
      }),
      _service.durationStream
          .where((duration) => duration != null)
          .cast<Duration>()
          .listen((duration) {
            emit(state.copyWith(duration: duration));
          }),
      _service.loadingStream.distinct().listen((isLoading) {
        emit(state.copyWith(isLoading: isLoading));
      }),
      _service.errorStream.distinct().listen((error) {
        if (error != null) {
          emit(state.copyWith(errorMessage: error));
        } else {
          emit(state.copyWith(clearError: true));
        }
      }),
      _service.speedStream.distinct().listen((speed) {
        emit(state.copyWith(playbackSpeed: speed));
      }),
    ]);
  }

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    return super.close();
  }

  Future<void> play(
    SongModel song, {
    bool playRelated = true,
    List<SongModel>? queue,
  }) async {
    await _service.loadAndPlay(song, playRelated: playRelated, queue: queue);
  }

  void togglePlay() {
    if (_service.isPlaying) {
      _service.pause();
    } else {
      _service.play();
    }
  }

  void seek(Duration position) => _service.seek(position);
  void playNext() => _service.playNext();
  void playPrevious() => _service.playPrevious();
  void clearError() => emit(state.copyWith(clearError: true));

  /// Toggle shuffle mode
  void toggleShuffle() {
    _service.toggleShuffle();
    emit(state.copyWith(isShuffle: _service.isShuffle));
  }

  /// Toggle repeat mode (OFF -> ALL -> ONE -> OFF)
  void toggleRepeatMode() {
    _service.toggleRepeatMode();
    emit(state.copyWith(repeatMode: _service.repeatMode));
  }

  /// Toggle video mode
  void toggleVideoEnabled() {
    final newVideoEnabled = !state.isVideoEnabled;
    emit(state.copyWith(isVideoEnabled: newVideoEnabled));
  }

  /// Load lyrics for current song
  // Future<void> loadLyrics() async {
  //   final song = state.currentSong;
  //   if (song == null) return;

  //   // Check if lyrics already loaded
  //   // if (song.lyrics != null) {
  //   //   emit(state.copyWith(lyrics: song.lyrics));
  //   //   return;
  //   // }

  //   emit(state.copyWith(lyricsLoading: true));

  //   try {
  //     // final lyricContent = await LyricsService.fetchLyrics(song);

  //     if (lyricContent != null) {
  //       // Update song with lyrics
  //       final updatedSong = song.copyWith(lyrics: lyricContent);
  //       emit(
  //         state.copyWith(
  //           currentSong: updatedSong,
  //           lyrics: lyricContent,
  //           lyricsLoading: false,
  //         ),
  //       );
  //     } else {
  //       emit(state.copyWith(lyricsLoading: false));
  //     }
  //   } catch (e) {
  //     print('Error loading lyrics: $e');
  //     emit(state.copyWith(lyricsLoading: false));
  //   }
  // }

  /// Change playback speed (0.5x to 2.0x)
  Future<void> setPlaybackSpeed(double speed) async {
    await _service.setSpeed(speed);
  }
}
