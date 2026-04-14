import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marquee/marquee.dart';
import '../../blocs/player/player_cubit.dart';
import '../../models/song_model.dart';
import '../../core/theme.dart';
import '../../services/player/audio_player_service.dart';
import 'components/eq_panel.dart';
import 'components/video_layer_widget.dart';
import '../queue/queue_bottom_sheet.dart';
import '../artist/artist_detail_screen.dart';
import '../playlist/add_to_playlist_sheet.dart';

class FullPlayerScreen extends StatefulWidget {
  const FullPlayerScreen({super.key});

  @override
  State<FullPlayerScreen> createState() => _FullPlayerScreenState();
}

class _FullPlayerUiState extends Equatable {
  final SongModel? currentSong;
  final bool isPlaying;
  final bool isLoading;
  final bool isVideoEnabled;
  final double playbackSpeed;

  const _FullPlayerUiState({
    required this.currentSong,
    required this.isPlaying,
    required this.isLoading,
    required this.isVideoEnabled,
    required this.playbackSpeed,
  });

  @override
  List<Object?> get props => [
    currentSong?.songId,
    currentSong?.title,
    currentSong?.thumb,
    isPlaying,
    isLoading,
    isVideoEnabled,
    playbackSpeed,
  ];
}

class _FullPlayerScreenState extends State<FullPlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  void _syncRotation(bool isPlaying) {
    if (isPlaying) {
      _rotationController.repeat();
    } else {
      _rotationController.stop();
    }
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayerCubit, PlayerCubitState>(
      listenWhen: (previous, current) =>
          previous.isPlaying != current.isPlaying ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        _syncRotation(state.isPlaying);

        // Show error dialog
        if (state.errorMessage != null) {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => Dialog(
              backgroundColor: AppTheme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: Colors.red.shade400,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Lỗi phát nhạc',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.errorMessage!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.read<PlayerCubit>().clearError();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                        child: const Text(
                          'OK',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
      child: BlocSelector<PlayerCubit, PlayerCubitState, _FullPlayerUiState>(
        selector: (state) => _FullPlayerUiState(
          currentSong: state.currentSong,
          isPlaying: state.isPlaying,
          isLoading: state.isLoading,
          isVideoEnabled: state.isVideoEnabled,
          playbackSpeed: state.playbackSpeed,
        ),
        builder: (context, ui) {
          final song = ui.currentSong;

          if (song == null) {
            return const Scaffold(
              backgroundColor: AppTheme.backgroundColor,
              body: Center(child: Text('No song playing')),
            );
          }

          if (_isFullScreen && ui.isVideoEnabled) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: SafeArea(child: _buildVideoContent(song)),
            );
          }

          return Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: _buildBody(context, ui),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, _FullPlayerUiState ui) {
    final song = ui.currentSong;
    if (song == null) {
      return const Center(child: Text('No song playing'));
    }

    return Stack(
      children: [
        // Blurred background artwork
        if (song.thumb != null)
          Positioned.fill(
            child: CachedNetworkImage(imageUrl: song.thumb!, fit: BoxFit.cover),
          ),
        if (song.thumb != null)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.black.withValues(alpha: 0.55)),
            ),
          ),

        // Gradient overlay
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(gradient: AppTheme.playerGradient),
          ),
        ),

        // Main content
        SafeArea(
          child: Column(
            children: [
              _buildTopBar(context, song),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        ui.isVideoEnabled
                            ? _buildVideoContent(song)
                            : _buildArtwork(song, ui.isVideoEnabled),
                        const SizedBox(height: 28),
                        _buildSongInfo(song),
                        const SizedBox(height: 22),
                        _buildSeekBar(context),
                        const SizedBox(height: 18),
                        _buildControls(context, ui),
                        const SizedBox(height: 22),
                        _buildBottomActions(context, ui),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Loading overlay
        // if (ui.isLoading)
        //   Positioned.fill(
        //     child: Container(
        //       color: Colors.black38,
        //       child: Center(
        //         child: Column(
        //           mainAxisSize: MainAxisSize.min,
        //           children: [
        //             const CircularProgressIndicator(
        //               valueColor: AlwaysStoppedAnimation<Color>(
        //                 AppTheme.primaryColor,
        //               ),
        //               strokeWidth: 3,
        //             ),
        //             const SizedBox(height: 16),
        //             Text(
        //               'Đang tải bài hát...',
        //               style: TextStyle(
        //                 color: Colors.white.withValues(alpha: 0.8),
        //                 fontSize: 14,
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ),
        //   ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context, SongModel song) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Now Playing',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  song.title ?? 'Unknown',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Thêm vào playlist',
            icon: const Icon(Icons.playlist_add_rounded, color: Colors.white),
            onPressed: () async {
              final current = context.read<PlayerCubit>().state.currentSong;
              if (current == null) return;
              await AddToPlaylistSheet.show(context, song: current);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildArtwork(SongModel song, bool isVideoEnabled) {
    return Center(
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * 3.14159,
                child: child,
              );
            },
            child: Container(
              width: 220.h,
              height: 220.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.75),
                  ],
                  stops: const [0.0, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.55),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: ClipOval(
                child: song.thumb != null
                    ? CachedNetworkImage(
                        imageUrl: song.thumb!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppTheme.cardColor,
                          child: const Icon(
                            Icons.music_note,
                            size: 60,
                            color: Colors.white30,
                          ),
                        ),
                      )
                    : Container(
                        color: AppTheme.cardColor,
                        child: const Icon(
                          Icons.music_note,
                          size: 60,
                          color: Colors.white30,
                        ),
                      ),
              ),
            ),
          ),
          // Positioned(
          //   bottom: 0,
          //   right: 0,
          //   child: _buildSwapModeButton(isVideoEnabled),
          // ),
        ],
      ),
    );
  }

  Widget _buildVideoContent(SongModel song) {
    return SizedBox(
      width: double.infinity,
      height: _isFullScreen ? double.infinity : 220.h,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => context.read<PlayerCubit>().togglePlay(),
            onDoubleTapDown: (details) {
              final isForward =
                  details.localPosition.dx >
                  MediaQuery.of(context).size.width / 2;
              _onDoubleTapSeek(context, isForward);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              alignment: Alignment.center,
              child: VideoLayerWidget(song: song),
            ),
          ),
          // Positioned(bottom: 10, right: 10, child: _buildSwapModeButton(true)),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(
                  _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                ),
                onPressed: _toggleFullScreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onDoubleTapSeek(BuildContext context, bool forward) {
    final cubit = context.read<PlayerCubit>();
    final currentPosition = cubit.state.position;
    final seekAmount = const Duration(seconds: 10);
    final newPosition = forward
        ? currentPosition + seekAmount
        : currentPosition - seekAmount;
    cubit.seek(newPosition);
  }

  Widget _buildSongInfo(SongModel song) {
    return Column(
      children: [
        SizedBox(
          height: 28,
          child: song.title != null && song.title!.length > 25
              ? Marquee(
                  text: song.title!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  scrollAxis: Axis.horizontal,
                  blankSpace: 60,
                  velocity: 30,
                )
              : Text(
                  song.title ?? 'Unknown',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () {
            final name = (song.channel ?? '').trim();
            if (name.isEmpty) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ArtistDetailScreen(artistName: name),
              ),
            );
          },
          child: Text(
            song.channel ?? 'Unknown',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.primaryColor.withValues(alpha: 0.95),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeekBar(BuildContext context) {
    return const _PlayerSeekBar();
  }

  Widget _buildControls(BuildContext context, _FullPlayerUiState ui) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Shuffle
        BlocBuilder<PlayerCubit, PlayerCubitState>(
          buildWhen: (previous, current) =>
              previous.isShuffle != current.isShuffle,
          builder: (context, state) {
            return IconButton(
              iconSize: 22,
              icon: Icon(
                Icons.shuffle_rounded,
                color: state.isShuffle
                    ? AppTheme.primaryColor
                    : Colors.white.withValues(alpha: 0.5),
              ),
              onPressed: () => context.read<PlayerCubit>().toggleShuffle(),
            );
          },
        ),
        // Previous
        IconButton(
          iconSize: 36,
          icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
          onPressed: () => context.read<PlayerCubit>().playPrevious(),
        ),
        // Play/Pause — loading state aware
        _buildMainPlayButton(context, ui),
        // Next
        IconButton(
          iconSize: 36,
          icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
          onPressed: () => context.read<PlayerCubit>().playNext(),
        ),
        // Repeat
        BlocBuilder<PlayerCubit, PlayerCubitState>(
          buildWhen: (previous, current) =>
              previous.repeatMode != current.repeatMode,
          builder: (context, state) {
            final icon = state.repeatMode == PlayerRepeatMode.one
                ? Icons.repeat_one_rounded
                : Icons.repeat_rounded;
            return IconButton(
              iconSize: 22,
              icon: Icon(
                icon,
                color: state.repeatMode == PlayerRepeatMode.all
                    ? Colors.white.withValues(alpha: 0.5)
                    : AppTheme.primaryColor,
              ),
              onPressed: () => context.read<PlayerCubit>().toggleRepeatMode(),
            );
          },
        ),
        // Video mode
        // BlocBuilder<PlayerCubit, PlayerCubitState>(
        //   buildWhen: (previous, current) =>
        //       previous.isVideoMode != current.isVideoMode,
        //   builder: (context, state) {
        //     return IconButton(
        //       iconSize: 22,
        //       icon: Icon(
        //         Icons.video_camera_back_rounded,
        //         color: state.isVideoMode
        //             ? AppTheme.primaryColor
        //             : Colors.white.withValues(alpha: 0.5),
        //       ),
        //       onPressed: () => context.read<PlayerCubit>().toggleVideoMode(),
        //     );
        //   },
        // ),
      ],
    );
  }

  Widget _buildMainPlayButton(BuildContext context, _FullPlayerUiState ui) {
    final isPlaying = ui.isPlaying;
    final isLoading = ui.isLoading;

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primaryColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: IconButton(
        iconSize: 36,
        icon: isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              )
            : Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
              ),
        onPressed: isLoading
            ? null
            : () => context.read<PlayerCubit>().togglePlay(),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, _FullPlayerUiState ui) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        InkWell(
          onTap: () => _showSpeedSheet(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.speed, color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                Text(
                  '${ui.playbackSpeed.toStringAsFixed(2)}x',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (Platform.isAndroid)
          IconButton(
            icon: const Icon(Icons.equalizer, color: Colors.white70),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: AppTheme.cardColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => const EqPanel(),
              );
            },
          ),
        IconButton(
          icon: const Icon(Icons.queue_music, color: Colors.white70),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: AppTheme.cardColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => const QueueBottomSheet(),
            );
          },
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: _buildSwapModeButton(ui.isVideoEnabled),
        ),
      ],
    );
  }

  Widget _buildSwapModeButton(bool isVideoEnabled) {
    return GestureDetector(
      onTap: () => context.read<PlayerCubit>().toggleVideoEnabled(),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          isVideoEnabled
              ? Icons.audiotrack_rounded
              : Icons.video_library_rounded,
          color: isVideoEnabled ? AppTheme.primaryColor : Colors.white,
          size: 20,
        ),
      ),
    );
  }

  void _showSpeedSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tốc độ phát',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ...[0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${speed}x',
                    style: TextStyle(
                      color:
                          speed ==
                              context.read<PlayerCubit>().state.playbackSpeed
                          ? AppTheme.primaryColor
                          : Colors.white70,
                    ),
                  ),
                  trailing: speed == 1.0
                      ? Text(
                          'mặc định',
                          style: TextStyle(
                            color:
                                speed ==
                                    context
                                        .read<PlayerCubit>()
                                        .state
                                        .playbackSpeed
                                ? AppTheme.primaryColor
                                : Colors.white70,
                          ),
                        )
                      : null,
                  onTap: () {
                    context.read<PlayerCubit>().setPlaybackSpeed(speed);
                    Navigator.of(context).pop();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _PlayerSeekBar extends StatelessWidget {
  const _PlayerSeekBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerCubitState>(
      buildWhen: (previous, current) =>
          previous.position != current.position ||
          previous.duration != current.duration ||
          previous.playbackSpeed != current.playbackSpeed,
      builder: (context, state) {
        final position = state.position;
        final duration = state.duration;
        final durationSeconds = duration.inSeconds;
        final positionSeconds = position.inSeconds;

        final max = durationSeconds > 0 ? durationSeconds.toDouble() : 1.0;
        final value = positionSeconds.clamp(0, durationSeconds).toDouble();

        if (duration.inSeconds == 0) {
          return const SizedBox(); // hoặc disable slider
        }
        return Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: AppTheme.primaryColor,
                inactiveTrackColor: Colors.white24,
                thumbColor: AppTheme.primaryColor,
                overlayColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: value.toDouble(),
                min: 0,
                max: max,
                onChangeEnd: (value) {
                  context.read<PlayerCubit>().seek(
                    Duration(seconds: value.toInt()),
                  );
                },
                onChanged: (value) {
                  // chỉ update UI tạm
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    _formatDuration(position),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    _formatDuration(duration),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
