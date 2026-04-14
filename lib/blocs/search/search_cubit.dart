import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/song_model.dart';
import '../../models/settings_model.dart';
import '../../network/music_api.dart';
import '../../youtube/yt_audio_resolver.dart';

// States
abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class TrendingLoading extends SearchState {}

class TrendingLoaded extends SearchState {
  final List<SongModel> songs;
  const TrendingLoaded(this.songs);
  @override
  List<Object?> get props => [songs];
}

class SearchLoaded extends SearchState {
  final List<SongModel> songs;
  final String query;
  const SearchLoaded(this.songs, {this.query = ''});
  @override
  List<Object?> get props => [songs, query];
}

class SearchSuggestionsLoaded extends SearchState {
  final List<String> suggestions;
  const SearchSuggestionsLoaded(this.suggestions);
  @override
  List<Object?> get props => [suggestions];
}

class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial());

  /// Load trending content for the Home screen with optional category
  Future<void> loadTrending({TrendingCategory? category}) async {
    emit(TrendingLoading());
    try {
      // Use category's country code if provided, default to VN
      final countryCode = category?.countryCode ?? 'VN';

      // Fallback: popular
      final popular = await MusicApi.getPopular(countryCode: countryCode);
      if (popular.isNotEmpty) {
        emit(TrendingLoaded(popular));
        return;
      }
      final songs = await MusicApi.getTrending(countryCode: countryCode);
      if (songs.isNotEmpty) {
        emit(TrendingLoaded(songs));
        return;
      }
      // Last fallback: YouTube search
      final ytSongs = await YtAudioResolver.searchSongs('trending music 2025');
      emit(TrendingLoaded(ytSongs));
      // Preload URLs for trending results in background - DISABLED
      // YtAudioResolver.preloadSearchResults(ytSongs);
    } catch (e) {
      // On error show empty trending (graceful degradation)
      emit(const TrendingLoaded([]));
    }
  }

  /// Search for songs by query
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      await loadTrending();
      return;
    }
    emit(SearchLoading());
    try {
      final songs = await YtAudioResolver.searchSongs(query.trim());
      emit(SearchLoaded(songs, query: query.trim()));
      // Preload URLs for search results in background - DISABLED
      // YtAudioResolver.preloadSearchResults(songs);
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  /// Get search suggestions based on query
  Future<void> searchSuggestions(String query) async {
    // if (query.trim().isEmpty) {
    //   emit(const SearchSuggestionsLoaded([]));
    //   return;
    // }
    // try {
    //   // For now, use a simple implementation: get trending titles that match
    //   // In a real app, you might use YouTube's suggestion API or a custom service
    //   final trending = await MusicApi.getTrending(countryCode: 'VN');
    //   final suggestions = trending
    //       .where(
    //         (song) =>
    //             song.title?.toLowerCase().contains(query.toLowerCase()) ??
    //             false,
    //       )
    //       .map((song) => song.title ?? '')
    //       .where((title) => title.isNotEmpty)
    //       .take(5)
    //       .toList();
    //   emit(SearchSuggestionsLoaded(suggestions));
    // } catch (e) {
    //   emit(const SearchSuggestionsLoaded([]));
    // }
  }

  /// Reset to initial/trending state
  void reset() {
    emit(SearchInitial());
  }
}
