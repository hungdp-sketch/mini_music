import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mini_music/screens/player/full_player_screen.dart';
import '../../blocs/player/player_cubit.dart';
import '../../core/theme.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: BlocBuilder<PlayerCubit, PlayerCubitState>(
        buildWhen: (previous, current) {
          return previous.currentSong != current.currentSong ||
              previous.position != current.position ||
              previous.duration != current.duration ||
              previous.isLoading != current.isLoading ||
              previous.playerState?.playing != current.playerState?.playing;
        },
        builder: (context, state) {
          if (state.currentSong == null) return const SizedBox.shrink();
          Future<dynamic> func() => Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const FullPlayerScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: child,
                    );
                  },
            ),
          );

          // Progress ratio 0.0 – 1.0
          final double progress = state.duration.inMilliseconds > 0
              ? (state.position.inMilliseconds / state.duration.inMilliseconds)
                    .clamp(0.0, 1.0)
              : 0.0;
          // if (state.playerState?.playing == true) {
          //   func();
          // }

          return GestureDetector(
            onTap: () => func(),
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor.withValues(alpha: 1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress bar at top
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 2,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        // Artwork
                        _buildArtwork(state),
                        const SizedBox(width: 12),
                        // Song info
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.currentSong!.title ?? 'Unknown',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              // final name =
                              //     (state.currentSong!.channel ?? '').trim();
                              // if (name.isEmpty) return;
                              // Navigator.of(context).push(
                              //   MaterialPageRoute(
                              //     builder: (_) =>
                              //         ArtistDetailScreen(artistName: name),
                              //   ),
                              // );
                              Text(
                                state.currentSong!.channel ?? 'Unknown',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.9,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Play/Pause or Loading
                        _buildPlayButton(context, state),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildArtwork(PlayerCubitState state) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageUrl: state.currentSong!.thumb ?? '',
        width: 46,
        height: 46,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 46,
          height: 46,
          color: AppTheme.cardColor,
          child: const Icon(Icons.music_note, size: 20, color: Colors.white38),
        ),
        errorWidget: (context, url, error) => Container(
          width: 46,
          height: 46,
          color: AppTheme.cardColor,
          child: const Icon(Icons.music_note, size: 20, color: Colors.white38),
        ),
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context, PlayerCubitState state) {
    if (state.isLoading) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
      );
    }

    return IconButton(
      onPressed: () => context.read<PlayerCubit>().togglePlay(),
      icon: Icon(
        state.isPlaying == true
            ? Icons.pause_rounded
            : Icons.play_arrow_rounded,
        color: AppTheme.primaryColor,
        size: 32,
      ),
    );
  }
}
