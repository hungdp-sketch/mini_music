import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/song_model.dart';
import '../../../core/theme.dart';
import '../../playlist/add_to_playlist_sheet.dart';

class SongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;
  final bool isPlaying;
  final bool isLoading;
  /// Hiện nút `...` với hành động thêm vào playlist (tắt ở màn không cần).
  final bool showMoreMenu;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.isPlaying = false,
    this.isLoading = false,
    this.showMoreMenu = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          FocusScope.of(context).unfocus();
          onTap();
        },
        splashColor: AppTheme.primaryColor.withValues(alpha: 0.1),
        highlightColor: Colors.white.withValues(alpha: 0.03),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Artwork
              _buildArtwork(),
              const SizedBox(width: 14),
              // Song info
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title ?? 'Unknown',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isPlaying ? AppTheme.primaryColor : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      song.channel ?? 'Unknown',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              _buildTrailingWidget(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArtwork() {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: song.thumb ?? '',
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            color: isPlaying ? Colors.black45 : null,
            colorBlendMode: isPlaying ? BlendMode.darken : null,
            placeholder: (context, url) => Container(
              width: 56,
              height: 56,
              color: AppTheme.cardColor,
              child: const Icon(
                Icons.music_note_rounded,
                size: 24,
                color: Colors.white30,
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: 56,
              height: 56,
              color: AppTheme.cardColor,
              child: const Icon(
                Icons.music_note_rounded,
                size: 24,
                color: Colors.white30,
              ),
            ),
          ),
        ),
        if (isLoading)
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          )
        else if (isPlaying)
          const _PlayingBarsIndicator(),
      ],
    );
  }

  Widget _buildTrailingWidget(BuildContext context) {
    final durationChild = _durationText();

    if (!showMoreMenu) {
      return durationChild ?? const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (durationChild != null) ...[
          durationChild,
          const SizedBox(width: 4),
        ],
        Material(
          color: Colors.transparent,
          child: PopupMenuButton<String>(
            color: AppTheme.cardColor,
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.more_vert_rounded,
              color: Colors.white.withValues(alpha: 0.55),
              size: 22,
            ),
            onSelected: (value) {
              if (value == 'playlist') {
                AddToPlaylistSheet.show(context, song: song);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'playlist',
                child: Text(
                  'Thêm vào playlist',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget? _durationText() {
    if (song.duration == null) return null;
    final d = Duration(seconds: song.duration!);
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return Text(
      '$minutes:$seconds',
      style: TextStyle(
        fontSize: 12,
        color: Colors.white.withValues(alpha: 0.35),
      ),
    );
  }
}

/// Animated "playing" bars indicator (3 bars pulsing)
class _PlayingBarsIndicator extends StatefulWidget {
  const _PlayingBarsIndicator();

  @override
  State<_PlayingBarsIndicator> createState() => _PlayingBarsIndicatorState();
}

class _PlayingBarsIndicatorState extends State<_PlayingBarsIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + i * 100),
      )..repeat(reverse: true),
    );
    _animations = _controllers.map((c) {
      return Tween<double>(
        begin: 4,
        end: 16,
      ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut));
    }).toList();
    // Offset start times
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 120), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (context, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Container(
                width: 3,
                height: _animations[i].value,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
