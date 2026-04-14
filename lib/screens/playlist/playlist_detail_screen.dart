import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_music/models/playlist_model.dart';
import '../../blocs/player/player_cubit.dart';
import '../../blocs/playlist/playlist_cubit.dart';
import '../../blocs/playlist/playlist_state.dart';
import '../../core/theme.dart';
import '../../models/song_model.dart';
import '../../core/app_localizations.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final PlaylistModel playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    Future<void> confirmDelete(BuildContext context) async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            context.l10n.deletePlaylistTitle,
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            context.l10n.deletePlaylistMessage(playlist.name),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                context.l10n.cancelButton,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                context.l10n.deleteButton,
                style: TextStyle(
                  color: Colors.red.shade400,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
      if (ok != true) return;
      if (!context.mounted) return;
      await context.read<PlaylistCubit>().delete(playlist.id);
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        title: Text(context.l10n.playlistTitle),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => confirmDelete(context),
            icon: const Icon(Icons.delete_rounded),
          ),
        ],
        //   IconButton(
        //     onPressed: () async {
        //       final current = context.read<PlayerCubit>().state.currentSong;
        //       if (current == null) {
        //         ScaffoldMessenger.of(context).showSnackBar(
        //           const SnackBar(content: Text('Chưa có bài đang phát.')),
        //         );
        //         return;
        //       }
        //       await context.read<PlaylistCubit>().addSong(playlistId, current);
        //       if (!context.mounted) return;
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         const SnackBar(content: Text('Đã thêm vào playlist.')),
        //       );
        //     },
        //     icon: const Icon(Icons.add_rounded),
        //   ),
        //   IconButton(
        //     tooltip: 'Thêm bài vào playlist khác',
        //     onPressed: () async {
        //       final current = context.read<PlayerCubit>().state.currentSong;
        //       if (current == null) {
        //         ScaffoldMessenger.of(context).showSnackBar(
        //           const SnackBar(content: Text('Chưa có bài đang phát.')),
        //         );
        //         return;
        //       }
        //       await AddToPlaylistSheet.show(context, song: current);
        //     },
        //     icon: const Icon(Icons.playlist_add_rounded),
        //   ),
        // ],
      ),
      body: BlocBuilder<PlaylistCubit, PlaylistState>(
        builder: (context, state) {
          if (state is PlaylistLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            );
          }
          if (state is PlaylistError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
            );
          }

          // if (playlist == null) {
          //   return Center(
          //     child: Text(
          //       'Playlist không tồn tại.',
          //       style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          //     ),
          //   );
          // }

          if (playlist.songs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.playlist_add_rounded,
                      size: 56,
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.playlistEmptyMessage(playlist.name),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // ElevatedButton(
                    //   onPressed: () async {
                    //     final current = context
                    //         .read<PlayerCubit>()
                    //         .state
                    //         .currentSong;
                    //     if (current == null) {
                    //       ScaffoldMessenger.of(context).showSnackBar(
                    //         const SnackBar(
                    //           content: Text('Chưa có bài đang phát.'),
                    //         ),
                    //       );
                    //       return;
                    //     }
                    //     await context.read<PlaylistCubit>().addSong(
                    //       playlist.id,
                    //       current,
                    //     );
                    //     if (!context.mounted) return;
                    //     ScaffoldMessenger.of(context).showSnackBar(
                    //       const SnackBar(
                    //         content: Text('Đã thêm vào playlist.'),
                    //       ),
                    //     );
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: AppTheme.primaryColor,
                    //     foregroundColor: Colors.black,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(12),
                    //     ),
                    //   ),
                    //   child: const Text('Thêm bài'),
                    // ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: playlist.songs.length + 1,
            separatorBuilder: (_, dummy) => const Divider(
              color: Colors.white12,
              height: 1,
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          playlist.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        context.l10n.songsCount(playlist.songs.length),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final songIndex = index - 1;
              final song = playlist.songs[songIndex];

              return ListTile(
                onTap: () {
                  context.read<PlayerCubit>().play(
                    song,
                    playRelated: false,
                    queue: playlist.songs,
                  );
                },
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: song.thumb != null
                      ? CachedNetworkImage(
                          imageUrl: song.thumb!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppTheme.cardColor,
                            child: const Icon(
                              Icons.music_note_rounded,
                              color: Colors.white70,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppTheme.cardColor,
                            child: const Icon(
                              Icons.music_note_rounded,
                              color: Colors.white70,
                            ),
                          ),
                        )
                      : Icon(Icons.music_note_rounded, color: Colors.white70),
                ),
                title: Text(
                  song.title ?? song.songId ?? 'Unknown',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  song.channel ??
                      (song.songId != null ? 'YouTube' : (song.url ?? '')),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                ),
                trailing: PopupMenuButton<String>(
                  color: AppTheme.cardColor,
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                  onSelected: (value) async {
                    switch (value) {
                      case 'edit':
                        await _editSongDialog(context, songIndex, song);
                        break;
                      case 'delete':
                        await context.read<PlaylistCubit>().removeSongAt(
                          playlist.id,
                          songIndex,
                        );
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(
                        context.l10n.editLabel,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        context.l10n.deleteButton,
                        style: TextStyle(color: Colors.redAccent.shade100),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _editSongDialog(
    BuildContext context,
    int index,
    SongModel song,
  ) async {
    final titleController = TextEditingController(text: song.title ?? '');
    final channelController = TextEditingController(text: song.channel ?? '');

    final res = await showDialog<_EditSongResult>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          context.l10n.editSongTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: context.l10n.songTitleHint,
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: channelController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: context.l10n.songChannelHint,
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.l10n.cancelButton,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              _EditSongResult(
                title: titleController.text,
                channel: channelController.text,
              ),
            ),
            child: Text(
              context.l10n.saveButton,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (res == null) return;

    final updated = song.copyWith(
      title: res.title.trim().isEmpty ? null : res.title.trim(),
      channel: res.channel.trim().isEmpty ? null : res.channel.trim(),
    );

    if (!context.mounted) return;
    await context.read<PlaylistCubit>().updateSongAt(
      playlist.id,
      index,
      updated,
    );
  }
}

class _EditSongResult {
  final String title;
  final String channel;

  const _EditSongResult({required this.title, required this.channel});
}
