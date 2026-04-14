import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/song_model.dart';

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

class YtAudioResolver {
  static final YoutubeExplode _yt = YoutubeExplode();
  static final Map<String, _UrlCacheEntry> _urlCache = {};
  static late SharedPreferences _prefs;
  static const String _cacheKey = 'yt_url_cache';

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
        debugPrint('[YtResolver] Loaded ${_urlCache.length} cached URLs');
      } catch (e) {
        debugPrint('[YtResolver] Failed to load persistent cache: $e');
      }
    }
  }

  static void _savePersistentCache() {
    try {
      final cacheJson = jsonEncode(
        _urlCache.map((k, v) => MapEntry(k, v.toJson())),
      );
      _prefs.setString(_cacheKey, cacheJson);
    } catch (e) {
      debugPrint('[YtResolver] Failed to save persistent cache: $e');
    }
  }

  /// Returns cached URL if still valid, null otherwise.
  static String? _getCached(String videoId) {
    final entry = _urlCache[videoId];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.fetchedAt).inMinutes >=
        _cacheTtlMinutes) {
      _urlCache.remove(videoId);
      return null;
    }
    return entry.url;
  }

  static void _setCache(String videoId, String url) {
    _urlCache[videoId] = _UrlCacheEntry(url: url, fetchedAt: DateTime.now());
    _savePersistentCache();
  }

  static Future<void> clearUrlCache() async {
    _urlCache.clear();
    await _prefs.remove(_cacheKey);
    debugPrint('[YtResolver] Cleared audio URL cache');
  }

  /// Extracts the best audio stream URL for a given video ID.
  /// Prefers m4a/aac audioOnly (smaller, iOS-friendly, less throttled).
  /// Retries up to 3 times with exponential backoff.
  static Future<String?> getAudioUrl(
    String videoId, {
    bool preferHighQuality = true,
    double streamQuality = 0.8, // 0.0..1.0
  }) async {
    // 1. Return from cache if valid
    final cached = _getCached(videoId);
    if (cached != null) {
      debugPrint('[YtResolver] Cache hit for $videoId');
      return cached;
    }

    // 2. Fetch with retry
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        debugPrint('[YtResolver] Attempt ${attempt + 1} for $videoId');

        final manifest = await _yt.videos.streamsClient.getManifest(
          videoId,
          ytClients: [YoutubeApiClient.androidVr, YoutubeApiClient.safari],
        );

        String? url;

        // UpBeat Strategy:
        // - Prefer muxed streams for stability (less 403), but allow quality tuning.
        // - `streamQuality` selects a target resolution bucket.
        if (manifest.muxed.isNotEmpty) {
          final muxed = manifest.muxed.toList();

          final q = streamQuality.clamp(0.0, 1.0);
          final target = q < 0.4 ? '360' : (q < 0.75 ? '480' : '720');
          MuxedStreamInfo? chosen;
          chosen = muxed.cast<MuxedStreamInfo?>().firstWhere(
            (s) => s != null && s.videoQuality.toString().contains(target),
            orElse: () => null,
          );

          final streamInfo = preferHighQuality
              ? (chosen ?? manifest.muxed.withHighestBitrate())
              : (chosen ?? manifest.muxed.first);

          url = streamInfo.url.toString();
          debugPrint(
            '[YtResolver] Using muxed stream (target=$target, HQ=$preferHighQuality)',
          );
        } else if (manifest.audioOnly.isNotEmpty) {
          url = manifest.audioOnly.withHighestBitrate().url.toString();
          debugPrint('[YtResolver] Fallback: audioOnly stream');
        } else if (manifest.muxed.isNotEmpty) {
          // Last resort: muxed (video+audio, larger but more available)
          url = manifest.muxed.withHighestBitrate().url.toString();
          debugPrint('[YtResolver] Using muxed stream (fallback)');
        }

        if (url != null) {
          _setCache(videoId, url);
          return url;
        }

        debugPrint('[YtResolver] No suitable stream found for $videoId');
        return null;
      } catch (e) {
        debugPrint(
          '[YtResolver] Attempt ${attempt + 1} failed for $videoId: $e',
        );
        if (attempt < 2) {
          final delay = Duration(
            seconds: attempt + 2,
          ); // Increased delay: 2s, 3s
          debugPrint('[YtResolver] Retrying in ${delay.inSeconds}s...');
          await Future.delayed(delay);
        } else {
          // If all attempts failed due to rate limiting, clear cache to force refresh next time
          if (e.toString().contains('RequestLimitExceededException')) {
            debugPrint(
              '[YtResolver] Rate limited, clearing cache for $videoId',
            );
            _urlCache.remove(videoId);
            _savePersistentCache();
          }
        }
      }
    }

    debugPrint('[YtResolver] All attempts failed for $videoId');
    return null;
  }

  /// Searches YouTube and returns a list of SongModels.
  static Future<List<SongModel>> searchSongs(String query) async {
    try {
      final searchList = await _yt.search.search(query);
      return searchList.map((video) {
        String? thumb;
        if (video.thumbnails.highResUrl.isNotEmpty) {
          thumb = video.thumbnails.highResUrl;
        } else if (video.thumbnails.mediumResUrl.isNotEmpty) {
          thumb = video.thumbnails.mediumResUrl;
        } else {
          thumb = video.thumbnails.lowResUrl;
        }

        return SongModel(
          songId: video.id.value,
          title: video.title,
          channel: video.author,
          thumb: thumb,
          duration: video.duration?.inSeconds,
        );
      }).toList();
    } catch (e) {
      if (e.toString().contains('RequestLimitExceededException')) {
        debugPrint('[YtResolver] Rate limited during search for "$query"');
        throw Exception(
          'YouTube rate limit exceeded. Please wait a few minutes and try again.',
        );
      }
      debugPrint('[YtResolver] Search failed for "$query": $e');
      return [];
    }
  }

  /// Gets related songs for the currently playing video.
  static Future<List<SongModel>> getRelatedSongs({
    required String videoId,
    String? title,
  }) async {
    // try {
    //   final query = await _yt.search.searchRaw(
    //     'https://www.youtube.com/watch?v=$videoId',
    //   );
    //   final related = query.relatedVideos.whereType<SearchVideo>().map((video) {
    //     final thumb = video.thumbnails.isNotEmpty
    //         ? video.thumbnails.last.url.toString()
    //         : null;
    //     return SongModel(
    //       songId: video.id.value,
    //       title: video.title,
    //       channel: video.author,
    //       thumb: thumb,
    //       duration: _parseDuration(video.duration),
    //     );
    //   }).toList();

    //   if (related.isNotEmpty) {
    //     return related;
    //   }

    //   if (title != null && title.isNotEmpty) {
    //     return searchSongs(title);
    //   }
    //   return [];
    // } catch (e) {
    //   debugPrint('[YtResolver] Related search failed for "$videoId": $e');
    //   if (title != null && title.isNotEmpty) {
    //     return searchSongs(title);
    //   }
    return [];
    // }
  }

  // static int? _parseDuration(String durationText) {
  //   if (durationText.isEmpty) {
  //     return null;
  //   }

  //   final parts = durationText.split(':').map(int.tryParse).toList();
  //   if (parts.any((part) => part == null)) {
  //     return null;
  //   }

  //   if (parts.length == 1) {
  //     return parts[0];
  //   }
  //   if (parts.length == 2) {
  //     return parts[0]! * 60 + parts[1]!;
  //   }
  //   if (parts.length == 3) {
  //     return parts[0]! * 3600 + parts[1]! * 60 + parts[2]!;
  //   }
  //   return null;
  // }

  /// Preloads URLs for recently played songs to improve playback speed.
  static Future<void> preloadRecentlySongs(List<SongModel> songs) async {
    final songsToPreload = songs.take(10); // Preload first 10 recently songs
    for (final song in songsToPreload) {
      if (song.songId != null && _getCached(song.songId!) == null) {
        // Don't await, preload in background
        getAudioUrl(song.songId!);
      }
    }
  }

  /// Preloads URLs for search results to improve playback speed.
  /// DISABLED - Only preload recently songs for better rate limit management
  // static Future<void> preloadSearchResults(List<SongModel> songs) async {
  //   final songsToPreload = songs.take(5); // Preload first 5 search results
  //   for (final song in songsToPreload) {
  //     if (song.songId != null && _getCached(song.songId!) == null) {
  //       // Don't await, preload in background
  //       getAudioUrl(song.songId!);
  //     }
  //   }
  // }

  /// Disposes of the YouTubeExplode client.
  static void dispose() => _yt.close();
}
