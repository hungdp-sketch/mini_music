import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../blocs/search/search_cubit.dart';
import '../../blocs/player/player_cubit.dart';
import '../../blocs/settings/settings_cubit.dart';
import '../../blocs/history/history_cubit.dart';
import '../../blocs/playlist/playlist_cubit.dart';
import '../../blocs/playlist/playlist_state.dart';
import '../../models/song_model.dart';
import '../player/mini_player_bar.dart';
import 'components/recently_item.dart';
import 'components/song_tile.dart';
import 'recently_list_screen.dart';
import '../playlist/playlist_list_screen.dart';
import '../playlist/playlist_detail_screen.dart';
import '../../core/app_localizations.dart';
import '../../core/theme.dart';
import '../../widgets/playlist_cover_stack.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Load settings first, then load trending with the selected category
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SettingsCubit>().loadSettings().then((_) {
          if (mounted) {
            final settingsState = context.read<SettingsCubit>().state;
            if (settingsState is SettingsLoaded) {
              context.read<SearchCubit>().loadTrending(
                category: settingsState.settings.defaultTrendingCategory,
              );
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _isSearching = value.trim().isNotEmpty;
    });

    // Cancel previous timer
    _debounceTimer?.cancel();

    if (value.trim().isEmpty) {
      // If empty, reset to trending
      context.read<SearchCubit>().reset();
      return;
    }

    // Debounce suggestions
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      context.read<SearchCubit>().searchSuggestions(value.trim());
    });
  }

  void _onSearchSubmit(String value) {
    context.read<SearchCubit>().search(value);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _isSearching = false);
    // Reload trending with current category from settings
    final settingsState = context.read<SettingsCubit>().state;
    if (settingsState is SettingsLoaded) {
      context.read<SearchCubit>().loadTrending(
        category: settingsState.settings.defaultTrendingCategory,
      );
    } else {
      context.read<SearchCubit>().loadTrending();
    }
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayerCubit, PlayerCubitState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          _showErrorDialog(context, state.errorMessage!);
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  _buildSearchBar(),
                  _buildSuggestions(),
                  _buildPlaylistSection(),
                  _buildRecentlySection(),
                  _buildContent(),
                ],
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: MiniPlayerBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.red.shade400,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.musicPlayerError,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<PlayerCubit>().clearError();
            },
            child: const Text(
              'OK',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: AppTheme.backgroundColor,
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.settings_rounded,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                gradient: AppTheme.accentGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.music_note_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Mini Music',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: false,
            autocorrect: false,
            onChanged: _onSearchChanged,
            onSubmitted: _onSearchSubmit,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              hintText: context.l10n.homeSearchHint,
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Colors.white54,
                size: 22,
              ),
              suffixIcon: _isSearching
                  ? IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white54,
                        size: 20,
                      ),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        if (state is SearchSuggestionsLoaded && state.suggestions.isNotEmpty) {
          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final suggestion = state.suggestions[index];
              return ListTile(
                leading: const Icon(Icons.search, color: Colors.white54),
                title: Text(
                  suggestion,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  _searchController.text = suggestion;
                  context.read<SearchCubit>().search(suggestion);
                  FocusScope.of(context).unfocus();
                },
              );
            }, childCount: state.suggestions.length),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildRecentlySection() {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, searchState) {
        // Hide recently section when there are search results
        if (searchState is SearchLoaded && searchState.songs.isNotEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverToBoxAdapter(
          child: BlocBuilder<HistoryCubit, HistoryState>(
            builder: (context, state) {
              // debugPrint(
              //   '[HomeScreen] History state: $state, songs count: ${(state is HistoryLoaded) ? state.songs.length : 0}',
              // );

              if (state is HistoryLoading) {
                return const SizedBox.shrink();
              }

              if (state is HistoryLoaded) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 15.w, 20, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.l10n.recentlyPlayedTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (state.songs.length > 5)
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        RecentlyListScreen(songs: state.songs),
                                  ),
                                );
                              },
                              child: Text(
                                context.l10n.seeAllLabel,
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: state.songs.length > 5
                            ? 5
                            : state.songs.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final song = state.songs[index];
                          return RecentlyItem(
                            song: song,
                            onTap: () {
                              context.read<PlayerCubit>().play(
                                song,
                                playRelated: false,
                                queue: state.songs,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  Widget _buildPlaylistSection() {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, searchState) {
        // Hide playlists when user is in search results mode (keep Home clean)
        if (_isSearching) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverToBoxAdapter(
          child: BlocBuilder<PlaylistCubit, PlaylistState>(
            builder: (context, state) {
              final playlists = state is PlaylistLoaded
                  ? state.playlists
                  : const [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 15.w, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.playlistsTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PlaylistListScreen(),
                              ),
                            );
                          },
                          child: Text(
                            context.l10n.seeAllLabel,
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 96,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: playlists.isEmpty ? 1 : (playlists.length),
                      separatorBuilder: (_, dummy) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        // "Create" card
                        if (playlists.isEmpty) {
                          return _PlaylistCard(
                            title: context.l10n.createNewLabel,
                            subtitle: context.l10n.playlistTitle,
                            leadingIcon: Icons.add_rounded,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PlaylistListScreen(),
                                ),
                              );
                            },
                          );
                        }

                        // if (playlists.isEmpty) {
                        //   return const SizedBox.shrink();
                        // }

                        final p = playlists[index];
                        return _PlaylistCard(
                          title: p.name,
                          subtitle: context.l10n.songsCount(p.songs.length),
                          coverSongs: p.songs,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PlaylistDetailScreen(playlist: p),
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
      },
    );
  }

  Widget _buildContent() {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        if (state is TrendingLoading) {
          return _buildShimmerList();
        }

        if (state is TrendingLoaded) {
          return _buildSongList(
            state.songs,
            headerText: '🔥 Trending',
            emptyMessage: context.l10n.homeSearchEmpty,
          );
        }

        if (state is SearchLoading) {
          return _buildShimmerList();
        }

        if (state is SearchLoaded) {
          return _buildSongList(
            state.songs,
            headerText: '🔍 ${context.l10n.homeSearchHint}',
            emptyMessage: context.l10n.searchNotFound,
          );
        }

        if (state is SearchError) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 80),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 56,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.homeSearchEmpty,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSongList(
    List<SongModel> songs, {
    required String headerText,
    required String emptyMessage,
  }) {
    if (songs.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Center(
            child: Text(
              emptyMessage,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
            ),
          ),
        ),
      );
    }

    return BlocSelector<PlayerCubit, PlayerCubitState, _SongSelectionState>(
      selector: (state) => _SongSelectionState(
        currentSongId: state.currentSong?.songId,
        currentLoadingSongId: state.isLoading
            ? state.currentSong?.songId
            : null,
      ),
      builder: (context, selection) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == 0) {
                // Section header
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Text(
                    headerText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                );
              }
              final song = songs[index - 1];
              final isPlaying = song.songId == selection.currentSongId;
              final isLoading =
                  isPlaying && song.songId == selection.currentLoadingSongId;

              return SongTile(
                song: song,
                isPlaying: isPlaying,
                isLoading: isLoading,
                onTap: () =>
                    context.read<PlayerCubit>().play(song, queue: songs),
              );
            },
            childCount: songs.length + 1, // +1 for header
          ),
        );
      },
    );
  }

  Widget _buildShimmerList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return Shimmer.fromColors(
          baseColor: AppTheme.surfaceColor,
          highlightColor: AppTheme.cardColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(height: 12, width: 120, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }, childCount: 8),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  /// Icon trên nền gradient (ví dụ “Tạo mới”). Nếu null thì dùng [coverSongs].
  final IconData? leadingIcon;
  final List<SongModel>? coverSongs;

  const _PlaylistCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.leadingIcon,
    this.coverSongs,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 160,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: Row(
            children: [
              if (leadingIcon != null)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(leadingIcon, color: Colors.white),
                )
              else
                PlaylistCoverStack(songs: coverSongs ?? const [], size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SongSelectionState {
  final String? currentSongId;
  final String? currentLoadingSongId;

  const _SongSelectionState({
    required this.currentSongId,
    required this.currentLoadingSongId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _SongSelectionState &&
        other.currentSongId == currentSongId &&
        other.currentLoadingSongId == currentLoadingSongId;
  }

  @override
  int get hashCode => Object.hash(currentSongId, currentLoadingSongId);
}
