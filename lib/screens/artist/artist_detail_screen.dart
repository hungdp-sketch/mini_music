import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_music/blocs/player/player_cubit.dart';
import 'package:mini_music/core/theme.dart';
import 'package:mini_music/models/song_model.dart';
import 'package:mini_music/screens/home/components/song_tile.dart';
import 'package:mini_music/youtube/yt_audio_resolver.dart';

class ArtistDetailScreen extends StatefulWidget {
  final String artistName;

  const ArtistDetailScreen({super.key, required this.artistName});

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  late Future<List<SongModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadSongs();
  }

  Future<List<SongModel>> _loadSongs() async {
    final results = await YtAudioResolver.searchSongs(widget.artistName);
    final exact = results
        .where(
          (s) =>
              (s.channel ?? '').trim().toLowerCase() ==
              widget.artistName.trim().toLowerCase(),
        )
        .toList();
    // Prefer exact channel matches; fallback to general search results.
    return exact.isNotEmpty ? exact : results;
  }

  @override
  Widget build(BuildContext context) {
    final artistName = widget.artistName;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        title: Text(
          artistName,
          style: const TextStyle(color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<SongModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Không thể tải danh sách bài hát của artist.\n${snapshot.error}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final songs = snapshot.data ?? const <SongModel>[];
          if (songs.isEmpty) {
            return Center(
              child: Text(
                'Không tìm thấy bài hát.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  'Bài hát',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: BlocSelector<PlayerCubit, PlayerCubitState, String?>(
                  selector: (state) => state.currentSong?.songId,
                  builder: (context, currentSongId) {
                    return ListView.builder(
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        final isPlaying = song.songId == currentSongId;
                        return SongTile(
                          song: song,
                          isPlaying: isPlaying,
                          onTap: () => context.read<PlayerCubit>().play(
                            song,
                            queue: songs,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
