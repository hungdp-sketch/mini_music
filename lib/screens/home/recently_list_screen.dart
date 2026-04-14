import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_music/core/app_localizations.dart';
import '../../blocs/player/player_cubit.dart';
import '../../models/song_model.dart';
import '../../core/theme.dart';
import 'components/song_tile.dart';

class RecentlyListScreen extends StatelessWidget {
  final List<SongModel> songs;

  const RecentlyListScreen({super.key, required this.songs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(context.l10n.recentlyPlayedTitle),
        centerTitle: true,
      ),
      body: songs.isEmpty
          ? Center(
              child: Text(
                'No recently played songs',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: songs.length,
              separatorBuilder: (context, index) => const Divider(
                color: Colors.white12,
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final song = songs[index];
                return SongTile(
                  song: song,
                  onTap: () {
                    context.read<PlayerCubit>().play(
                      song,
                      playRelated: false,
                      queue: songs,
                    );
                  },
                );
              },
            ),
    );
  }
}
