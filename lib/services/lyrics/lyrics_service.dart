// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../../models/song_model.dart';

// // Simple lyrics model
// class LyricLine {
//   final Duration timestamp;
//   final String text;

//   const LyricLine(this.timestamp, this.text);
// }

// class LyricContent {
//   final List<LyricLine> lines;

//   const LyricContent(this.lines);
// }

// class LyricsService {
//   static const String _lyricsOvhBaseUrl = 'https://api.lyrics.ovh/v1';

//   // Cache for lyrics
//   static final Map<String, LyricContent> _lyricsCache = {};

//   /// Fetch lyrics for a song
//   static Future<LyricContent?> fetchLyrics(SongModel song) async {
//     final cacheKey = '${song.title}_${song.channel}';

//     // Check cache first
//     if (_lyricsCache.containsKey(cacheKey)) {
//       return _lyricsCache[cacheKey];
//     }
//     print('[Lyrics] Fetching: $cacheKey');

//     LyricContent? lyricContent;

//     try {
//       // Try Lyrics.ovh API
//       lyricContent = await _fetchFromLyricsOvh(song);

//       if (lyricContent != null && lyricContent.lines.isNotEmpty) {
//         _lyricsCache[cacheKey] = lyricContent;
//         print('[Lyrics] ✓ Found ${lyricContent.lines.length} lines');
//         return lyricContent;
//       }
//     } catch (e) {
//       print('[Lyrics] Error: $e');
//     }

//     print('[Lyrics] ✗ Not found for: ${song.title}');
//     return null;
//   }

//   /// Fetch from Lyrics.ovh API
//   static Future<LyricContent?> _fetchFromLyricsOvh(SongModel song) async {
//     try {
//       final artist = _extractArtist(song.channel ?? '');
//       final title = _cleanTitle(song.title ?? '');

//       final url = Uri.parse('$_lyricsOvhBaseUrl/$artist/$title');
//       final response = await http.get(url).timeout(const Duration(seconds: 5));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final lyricsText = data['lyrics'] as String?;

//         if (lyricsText != null && lyricsText.isNotEmpty) {
//           return _convertToLyricContent(lyricsText);
//         }
//       }
//     } catch (e) {
//       print('[Lyrics.ovh] Error: $e');
//     }
//     return null;
//   }

//   /// Extract artist name from channel
//   static String _extractArtist(String channel) {
//     return channel
//         .replaceAll(' - Topic', '')
//         .replaceAll('VEVO', '')
//         .replaceAll('Official', '')
//         .replaceAll('Official Channel', '')
//         .trim();
//   }

//   /// Clean song title for API
//   static String _cleanTitle(String title) {
//     return title
//         .replaceAll(RegExp(r'\(.*?\)'), '')
//         .replaceAll(RegExp(r'\[.*?\]'), '')
//         .replaceAll(RegExp(r'official.*?video', caseSensitive: false), '')
//         .replaceAll(RegExp(r'lyrics?', caseSensitive: false), '')
//         .trim();
//   }

//   /// Parse LRC format lyrics or convert plain text with smart sync
//   static LyricContent _convertToLyricContent(String plainLyrics) {
//     final lines = plainLyrics.split('\n');

//     // Check if it's LRC format
//     if (lines.isNotEmpty && _isLrcFormat(lines[0])) {
//       print('[Lyrics] Detected LRC format');
//       return _parseLrcFormat(plainLyrics);
//     }

//     // Plain text: use smart sync based on estimated song duration
//     print('[Lyrics] Plain text - using smart sync');
//     return _convertPlainTextWithSmartSync(lines);
//   }

//   /// Check if first line is LRC format [MM:SS.xx]
//   static bool _isLrcFormat(String line) {
//     return RegExp(r'^\[\d{1,2}:\d{2}(\.\d{2,3})?\]').hasMatch(line);
//   }

//   /// Parse LRC format: [MM:SS.xx]text
//   static LyricContent _parseLrcFormat(String lrcContent) {
//     final lines = lrcContent.split('\n');
//     final lyricLines = <LyricLine>[];

//     for (final line in lines) {
//       final match = RegExp(
//         r'^\[(\d{1,2}):(\d{2})(?:\.(\d{2,3}))?\](.*)$',
//       ).firstMatch(line);
//       if (match != null) {
//         final minutes = int.parse(match.group(1)!);
//         final seconds = int.parse(match.group(2)!);
//         final milliseconds = match.group(3) != null
//             ? int.parse(match.group(3)!.padRight(3, '0'))
//             : 0;
//         final text = match.group(4)!.trim();

//         if (text.isNotEmpty) {
//           final timestamp = Duration(
//             minutes: minutes,
//             seconds: seconds,
//             milliseconds: milliseconds,
//           );
//           lyricLines.add(LyricLine(timestamp, text));
//         }
//       }
//     }

//     print('[Lyrics] LRC parsed: ${lyricLines.length} lines');
//     return LyricContent(lyricLines);
//   }

//   /// Convert plain text with smart sync - distribute lines based on average duration
//   static LyricContent _convertPlainTextWithSmartSync(List<String> lines) {
//     // Filter out empty lines
//     final nonEmptyLines = lines.where((l) => l.trim().isNotEmpty).toList();

//     if (nonEmptyLines.isEmpty) {
//       return LyricContent([]);
//     }

//     // Estimate: typical song is 3-5 minutes, most lyrics have 20-40 lines
//     // Use average of 5-7 seconds per line for better sync
//     const avgSecondsPerLine = 6.0;
//     final lyricLines = <LyricLine>[];

//     for (int i = 0; i < nonEmptyLines.length; i++) {
//       final line = nonEmptyLines[i].trim();
//       final timestamp = Duration(seconds: (i * avgSecondsPerLine).toInt());
//       lyricLines.add(LyricLine(timestamp, line));
//     }

//     print(
//       '[Lyrics] Smart sync: ${lyricLines.length} lines, ~${avgSecondsPerLine}s per line',
//     );
//     return LyricContent(lyricLines);
//   }

//   /// Clear cache
//   static void clearCache() {
//     _lyricsCache.clear();
//   }
// }
