import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/playlist/playlist_cubit.dart';
import '../../blocs/playlist/playlist_state.dart';
import '../../core/theme.dart';
import '../../models/song_model.dart';
import '../../core/app_localizations.dart';

class AddToPlaylistSheet {
  static Future<void> show(
    BuildContext context, {
    required SongModel song,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _AddToPlaylistSheetBody(song: song),
    );
  }
}

class _AddToPlaylistSheetBody extends StatelessWidget {
  final SongModel song;

  const _AddToPlaylistSheetBody({required this.song});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 12),
              Align(
              alignment: Alignment.centerLeft,
              child: Text(
                context.l10n.addToPlaylistTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                song.title ?? song.songId ?? 'Unknown',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.add_rounded, color: Colors.white70),
              title: Text(context.l10n.createNewPlaylistLabel, style: const TextStyle(color: Colors.white)),
              onTap: () async {
                final name = await _askPlaylistName(context);
                if (name == null) return;
                if (!context.mounted) return;
                final id = await context
                    .read<PlaylistCubit>()
                    .createAndAddSong(name, song);
                if (!context.mounted) return;
                if (id != null) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.addedToPlaylistSnackBar)),
                  );
                }
              },
            ),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 8),
            BlocBuilder<PlaylistCubit, PlaylistState>(
              builder: (context, state) {
                final playlists =
                    state is PlaylistLoaded ? state.playlists : const [];
                if (playlists.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        context.l10n.noPlaylistsMessage,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  );
                }

                return Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: playlists.length,
                    separatorBuilder: (_, dummy) =>
                        const Divider(color: Colors.white12, height: 1),
                    itemBuilder: (context, index) {
                      final p = playlists[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.queue_music_rounded,
                          color: Colors.white70,
                        ),
                        title: Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          context.l10n.songsCount(p.songs.length),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        onTap: () async {
                          await context
                              .read<PlaylistCubit>()
                              .addSong(p.id, song);
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.l10n.addedToPlaylistSnackBar)),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _askPlaylistName(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(context.l10n.createPlaylistTitle, style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: context.l10n.playlistNameHint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryColor),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancelButton, style: const TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(
              context.l10n.createButton,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (name == null) return null;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }
}
