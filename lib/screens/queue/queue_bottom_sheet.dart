import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/player/player_cubit.dart';
import '../../core/theme.dart';
import '../home/components/song_tile.dart';

class QueueBottomSheet extends StatelessWidget {
  const QueueBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 24),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Play Queue',
            style: AppTheme.darkTheme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Flexible(
            child: BlocBuilder<PlayerCubit, PlayerCubitState>(
              builder: (context, state) {
                if (state.queue.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('Queue is empty')),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: state.queue.length,
                  itemExtent: 80,
                  itemBuilder: (context, index) {
                    final song = state.queue[index];
                    final isCurrent = state.currentSong?.songId == song.songId;
                    return Container(
                      color: isCurrent
                          ? AppTheme.primaryColor.withValues(alpha: 0.1)
                          : null,
                      child: SongTile(
                        song: song,
                        showMoreMenu: false,
                        onTap: () {
                          context.read<PlayerCubit>().play(song);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
