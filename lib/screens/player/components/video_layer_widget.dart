import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mini_music/models/song_model.dart';
import 'package:mini_music/services/player/audio_player_service.dart';
import 'package:mini_music/youtube/yt_video_resolver.dart';
import 'package:video_player/video_player.dart';

/// UI-only video rendering layer.
///
/// This widget must never control the audio engine lifecycle; it only seeks/plays
/// the video visuals to match the current audio position/state.
class VideoLayerWidget extends StatefulWidget {
  final SongModel song;

  const VideoLayerWidget({super.key, required this.song});

  @override
  State<VideoLayerWidget> createState() => _VideoLayerWidgetState();
}

class _VideoLayerWidgetState extends State<VideoLayerWidget> {
  static Future<void>? _videoResolverInitFuture;

  VideoPlayerController? _controller;

  late final StreamSubscription<bool> _playSub;
  late final StreamSubscription<Duration> _posSub;

  Duration _latestAudioPosition = Duration.zero;
  bool _audioIsPlaying = false;
  DateTime? _lastSeekAt;

  @override
  void initState() {
    super.initState();

    _startAudioSyncListeners();
    _initControllerForSong(widget.song);
  }

  void _startAudioSyncListeners() {
    final service = AudioPlayerService.instance;

    _playSub = service.playingStream.listen((playing) {
      _audioIsPlaying = playing;
      final controller = _controller;
      if (controller != null && controller.value.isInitialized) {
        // Keep visuals synced to audio state (no audio lifecycle coupling).
        if (playing) {
          controller.play();
        } else {
          controller.pause();
        }
      }

      // Overlay visibility depends on play state only (avoid position-triggered rebuilds).
      if (mounted) setState(() {});
    });

    _posSub = service.positionStream.listen((position) {
      _latestAudioPosition = position;
      final controller = _controller;
      if (controller == null || !controller.value.isInitialized) return;

      final current = controller.value.position;
      final driftMs = (current - position).inMilliseconds.abs();

      // Throttle seeks to avoid expensive rebuffering.
      final now = DateTime.now();
      final lastSeekElapsedMs = _lastSeekAt == null
          ? null
          : now.difference(_lastSeekAt!).inMilliseconds;

      final shouldSeek =
          (lastSeekElapsedMs == null || lastSeekElapsedMs > 1000) &&
          driftMs > 350;
      if (!shouldSeek) return;

      _lastSeekAt = now;
      controller.seekTo(position);
    });
  }

  Future<void> _ensureVideoResolverInit() {
    _videoResolverInitFuture ??= YtVideoResolver.init();
    return _videoResolverInitFuture!;
  }

  Future<void> _initControllerForSong(SongModel song) async {
    final songId = song.songId;
    if (songId == null) return;

    await _ensureVideoResolverInit();
    final videoUrl = await YtVideoResolver.getVideoUrl(songId);
    if (videoUrl == null) return;

    await _disposeController();

    final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    _controller = controller;

    try {
      await controller.initialize();
      await controller.setVolume(0.0);
      await controller.seekTo(_latestAudioPosition);

      if (_audioIsPlaying) {
        await controller.play();
      } else {
        await controller.pause();
      }

      if (mounted) setState(() {});
    } catch (_) {
      await controller.dispose();
      _controller = null;
      if (mounted) setState(() {});
    }
  }

  Future<void> _disposeController() async {
    final controller = _controller;
    _controller = null;

    if (controller == null) return;
    try {
      await controller.pause();
    } catch (_) {
      // Ignore (dispose will clean up).
    }
    await controller.dispose();
  }

  @override
  void didUpdateWidget(covariant VideoLayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.song.songId != widget.song.songId) {
      _initControllerForSong(widget.song);
    }
  }

  @override
  void dispose() {
    _posSub.cancel();
    _playSub.cancel();
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          color: Colors.black26,
          alignment: Alignment.center,
          child: widget.song.thumb != null
              ? CachedNetworkImage(
                  imageUrl: widget.song.thumb!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              : const Icon(Icons.music_note, size: 56, color: Colors.white38),
        ),
      );
    }

    final aspectRatio = controller.value.aspectRatio == 0
        ? (16 / 9)
        : controller.value.aspectRatio;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            VideoPlayer(controller),
            ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                return AnimatedOpacity(
                  opacity: _audioIsPlaying ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: child,
                );
              },
              child: Container(
                color: Colors.black26,
                child: const Center(
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 56,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
