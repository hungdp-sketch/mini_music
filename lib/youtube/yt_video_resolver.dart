import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class _UrlCacheEntry {
  final String url;
  final DateTime fetchedAt;
  _UrlCacheEntry({required this.url, required this.fetchedAt});

  Map<String, dynamic> toJson() => {
    'url': url,
    'fetchedAt': fetchedAt.toIso8601String(),
  };

  factory _UrlCacheEntry.fromJson(Map<String, dynamic> json) => _UrlCacheEntry(
    url: json['url'],
    fetchedAt: DateTime.parse(json['fetchedAt']),
  );
}

class YtVideoResolver {
  static final YoutubeExplode _yt = YoutubeExplode();
  static final Map<String, _UrlCacheEntry> _urlCache = {};
  static late SharedPreferences _prefs;
  static const String _cacheKey = 'yt_video_url_cache';

  // Cache TTL: 25 minutes (YouTube URLs valid ~6h, safe margin)
  static const int _cacheTtlMinutes = 25;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadPersistentCache();
  }

  static void _loadPersistentCache() {
    final cacheJson = _prefs.getString(_cacheKey);
    if (cacheJson != null) {
      try {
        final cache = Map<String, dynamic>.from(
          Map<String, dynamic>.from(jsonDecode(cacheJson)),
        );
        _urlCache.clear();
        cache.forEach((videoId, entryJson) {
          final entry = _UrlCacheEntry.fromJson(
            Map<String, dynamic>.from(entryJson),
          );
          // Check if still valid
          if (DateTime.now().difference(entry.fetchedAt).inMinutes <
              _cacheTtlMinutes) {
            _urlCache[videoId] = entry;
          }
        });
      } catch (e) {
        debugPrint('[YtVideoResolver] Error loading cache: $e');
      }
    }
  }

  static void _savePersistentCache() {
    final cacheJson = jsonEncode(
      _urlCache.map((key, value) => MapEntry(key, value.toJson())),
    );
    _prefs.setString(_cacheKey, cacheJson);
  }

  static Future<void> clearUrlCache() async {
    _urlCache.clear();
    await _prefs.remove(_cacheKey);
    debugPrint('[YtVideoResolver] Cleared video URL cache');
  }

  static Future<String?> getVideoUrl(String videoId) async {
    // Check cache first
    final cached = _urlCache[videoId];
    if (cached != null &&
        DateTime.now().difference(cached.fetchedAt).inMinutes <
            _cacheTtlMinutes) {
      debugPrint('[YtVideoResolver] Using cached video URL for $videoId');
      return cached.url;
    }

    try {
      debugPrint('[YtVideoResolver] Fetching video URL for $videoId');

      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      // Performance-first strategy:
      // Prefer 360p/480p muxed streams to reduce decode + network load.
      final muxed = manifest.muxed.toList();
      MuxedStreamInfo? chosen;
      for (final target in const ['360', '480']) {
        chosen = muxed.cast<MuxedStreamInfo?>().firstWhere(
          (s) => s != null && s.videoQuality.toString().contains(target),
          orElse: () => null,
        );
        if (chosen != null) break;
      }

      final streamInfo = chosen ?? manifest.muxed.first;

      final url = streamInfo.url.toString();
      // Cache the URL
      _urlCache[videoId] = _UrlCacheEntry(url: url, fetchedAt: DateTime.now());
      _savePersistentCache();
      debugPrint('[YtVideoResolver] Video URL fetched and cached');
      return url;
    } catch (e) {
      debugPrint('[YtVideoResolver] Error fetching video URL: $e');
    }

    return null;
  }

  static Future<void> dispose() async {
    _yt.close();
  }
}
