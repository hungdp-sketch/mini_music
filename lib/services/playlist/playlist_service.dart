import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../../models/playlist_model.dart';
import '../../models/song_model.dart';

class PlaylistService {
  static const String _playlistsKey = 'user_playlists_v1';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<PlaylistModel>> loadPlaylists() async {
    final jsonString = _prefs.getString(_playlistsKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    final raw = jsonDecode(jsonString) as List<dynamic>;
    final playlists = raw
        .map((e) => PlaylistModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    playlists.sort((a, b) => b.updatedAtMs.compareTo(a.updatedAtMs));
    return playlists;
  }

  Future<void> savePlaylists(List<PlaylistModel> playlists) async {
    final payload = playlists.map((p) => p.toJson()).toList();
    await _prefs.setString(_playlistsKey, jsonEncode(payload));
  }

  Future<PlaylistModel> createPlaylist(String name) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final playlists = await loadPlaylists();
    final playlist = PlaylistModel(
      id: _newId(),
      name: name.trim().isEmpty ? 'Playlist' : name.trim(),
      songs: const [],
      createdAtMs: now,
      updatedAtMs: now,
    );
    await savePlaylists([playlist, ...playlists]);
    return playlist;
  }

  Future<void> renamePlaylist(String playlistId, String newName) async {
    final playlists = await loadPlaylists();
    final idx = playlists.indexWhere((p) => p.id == playlistId);
    if (idx == -1) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    playlists[idx] = playlists[idx].copyWith(
      name: newName.trim().isEmpty ? playlists[idx].name : newName.trim(),
      updatedAtMs: now,
    );
    await savePlaylists(playlists);
  }

  Future<void> deletePlaylist(String playlistId) async {
    final playlists = await loadPlaylists();
    playlists.removeWhere((p) => p.id == playlistId);
    await savePlaylists(playlists);
  }

  Future<void> addSong(String playlistId, SongModel song) async {
    final playlists = await loadPlaylists();
    final idx = playlists.indexWhere((p) => p.id == playlistId);
    if (idx == -1) return;

    final existing = playlists[idx];
    final updatedSongs = <SongModel>[
      ...existing.songs.where((s) => s.songId != song.songId),
    ];
    updatedSongs.insert(0, song);

    final now = DateTime.now().millisecondsSinceEpoch;
    playlists[idx] = existing.copyWith(songs: updatedSongs, updatedAtMs: now);
    await savePlaylists(playlists);
  }

  Future<void> removeSongAt(String playlistId, int index) async {
    final playlists = await loadPlaylists();
    final idx = playlists.indexWhere((p) => p.id == playlistId);
    if (idx == -1) return;

    final existing = playlists[idx];
    final updatedSongs = [...existing.songs];
    if (index < 0 || index >= updatedSongs.length) return;
    updatedSongs.removeAt(index);

    final now = DateTime.now().millisecondsSinceEpoch;
    playlists[idx] = existing.copyWith(songs: updatedSongs, updatedAtMs: now);
    await savePlaylists(playlists);
  }

  Future<void> updateSongAt(
    String playlistId,
    int index,
    SongModel song,
  ) async {
    final playlists = await loadPlaylists();
    final idx = playlists.indexWhere((p) => p.id == playlistId);
    if (idx == -1) return;

    final existing = playlists[idx];
    final updatedSongs = [...existing.songs];
    if (index < 0 || index >= updatedSongs.length) return;
    updatedSongs[index] = song;

    final now = DateTime.now().millisecondsSinceEpoch;
    playlists[idx] = existing.copyWith(songs: updatedSongs, updatedAtMs: now);
    await savePlaylists(playlists);
  }

  String _newId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    return 'pl_$now';
  }
}

