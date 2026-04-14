import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/playlist_model.dart';
import '../../models/song_model.dart';
import '../../services/playlist/playlist_service.dart';
import 'playlist_state.dart';

class PlaylistCubit extends Cubit<PlaylistState> {
  final PlaylistService service;

  PlaylistCubit(this.service) : super(const PlaylistInitial()) {
    load();
  }

  Future<void> load() async {
    try {
      emit(const PlaylistInitial());
      final playlists = await service.loadPlaylists();
      emit(PlaylistLoaded(playlists));
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  PlaylistModel? getById(String id) {
    final s = state;
    if (s is! PlaylistLoaded) return null;
    try {
      return s.playlists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> create(String name) async {
    try {
      await service.createPlaylist(name);
      await load();
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  Future<String?> createAndAddSong(String name, SongModel song) async {
    try {
      final playlist = await service.createPlaylist(name);
      await service.addSong(playlist.id, song);
      await load();
      return playlist.id;
    } catch (e) {
      emit(PlaylistError(e.toString()));
      return null;
    }
  }

  Future<void> rename(String playlistId, String newName) async {
    try {
      await service.renamePlaylist(playlistId, newName);
      await load();
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  Future<void> delete(String playlistId) async {
    try {
      await service.deletePlaylist(playlistId);
      await load();
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  Future<void> addSong(String playlistId, SongModel song) async {
    try {
      await service.addSong(playlistId, song);
      await load();
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  Future<void> removeSongAt(String playlistId, int index) async {
    try {
      await service.removeSongAt(playlistId, index);
      await load();
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  Future<void> updateSongAt(
    String playlistId,
    int index,
    SongModel song,
  ) async {
    try {
      await service.updateSongAt(playlistId, index, song);
      await load();
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }
}
