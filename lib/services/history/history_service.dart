import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../../models/song_model.dart';

class HistoryService {
  static const String _recentlyKey = 'recently_songs';
  static const int _maxRecentSongs = 50;

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<SongModel>> loadRecently() async {
    final jsonString = _prefs.getString(_recentlyKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final savedList = jsonDecode(jsonString) as List<dynamic>;
    return savedList
        .map((item) => SongModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> saveRecently(List<SongModel> songs) async {
    final payload = songs.map((song) => song.toJson()).toList();  
    await _prefs.setString(_recentlyKey, jsonEncode(payload));
  }

  Future<void> addSong(SongModel song) async {
    final current = await loadRecently();
    final updated = <SongModel>[];

    for (final item in current) {
      if (item.songId != song.songId) {
        updated.add(item);
      }
    }

    updated.insert(0, song);
    if (updated.length > _maxRecentSongs) {
      updated.removeRange(_maxRecentSongs, updated.length);
    }

    await saveRecently(updated);
  }

  Future<void> clearHistory() async {
    await _prefs.remove(_recentlyKey);
  }
}
