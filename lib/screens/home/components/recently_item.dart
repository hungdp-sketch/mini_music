import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../models/song_model.dart';
import '../../../core/theme.dart';
import '../../playlist/add_to_playlist_sheet.dart';

class RecentlyItem extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;
  final bool showMoreMenu;

  const RecentlyItem({
    super.key,
    required this.song,
    required this.onTap,
    this.showMoreMenu = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: onTap,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: song.thumb ?? '',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppTheme.cardColor,
                            child: const Icon(
                              Icons.music_note_rounded,
                              color: Colors.white30,
                              size: 24,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppTheme.cardColor,
                            child: const Icon(
                              Icons.music_note_rounded,
                              color: Colors.white30,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (showMoreMenu)
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () =>
                            AddToPlaylistSheet.show(context, song: song),
                        customBorder: const CircleBorder(),
                        child: const Padding(
                          padding: EdgeInsets.all(1),
                          child: Icon(
                            Icons.more_vert_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            song.title ?? 'Unknown',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
