import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/playlist/playlist_cubit.dart';
import '../../blocs/playlist/playlist_state.dart';
import '../../core/theme.dart';
import '../../models/playlist_model.dart';
import '../../widgets/playlist_cover_stack.dart';
import 'playlist_detail_screen.dart';
import '../../core/app_localizations.dart';

class PlaylistListScreen extends StatelessWidget {
  const PlaylistListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        title: Text(context.l10n.playlistsTitle),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showCreateDialog(context),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
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
          final playlists = state is PlaylistLoaded
              ? state.playlists
              : const [];
          if (playlists.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.queue_music_rounded,
                      size: 56,
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.noPlaylistsMessage,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _showCreateDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(context.l10n.createPlaylistTitle),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: playlists.length,
            separatorBuilder: (_, dummy) => const Divider(
              color: Colors.white12,
              height: 1,
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final p = playlists[index];
              return _PlaylistRow(
                playlist: p,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlaylistDetailScreen(playlist: p),
                    ),
                  );
                },
                onRename: () => _showRenameDialog(context, p),
                onDelete: () => _confirmDelete(context, p),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          context.l10n.createPlaylistTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: context.l10n.playlistNameHint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancelButton, style: const TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(
              context.l10n.createButton,
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (name == null) return;
    if (!context.mounted) return;
    await context.read<PlaylistCubit>().create(name);
  }

  Future<void> _showRenameDialog(
    BuildContext context,
    PlaylistModel playlist,
  ) async {
    final controller = TextEditingController(text: playlist.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          context.l10n.editPlaylistTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: context.l10n.newNameHint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancelButton, style: const TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(
              context.l10n.saveButton,
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (newName == null) return;
    if (!context.mounted) return;
    await context.read<PlaylistCubit>().rename(playlist.id, newName);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    PlaylistModel playlist,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              context.l10n.deleteButton,
              style: TextStyle(
                color: Colors.red.shade300,
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
}

class _PlaylistRow extends StatelessWidget {
  final PlaylistModel playlist;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _PlaylistRow({
    required this.playlist,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: PlaylistCoverStack(songs: playlist.songs, size: 44),
      title: Text(
        playlist.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        context.l10n.songsCount(playlist.songs.length),
        style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
      ),
      trailing: PopupMenuButton<String>(
        color: AppTheme.cardColor,
        icon: Icon(
          Icons.more_vert_rounded,
          color: Colors.white.withValues(alpha: 0.75),
        ),
        onSelected: (value) {
          switch (value) {
            case 'rename':
              onRename();
              break;
            case 'delete':
              onDelete();
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'rename',
            child: Text(context.l10n.renameLabel, style: const TextStyle(color: Colors.white)),
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
  }
}
