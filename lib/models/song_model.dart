class SongModel {
  final String? songId;
  final String? title;
  final String? channel;
  final String? thumb;
  final String? url;
  final int? duration;

  SongModel({
    this.songId,
    this.title,
    this.channel,
    this.thumb,
    this.url,
    this.duration,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    final String? videoId = json['video_id'] ?? json['id'];

    return SongModel(
      songId: videoId,
      title: json['name'] ?? json['title'],
      channel: json['channel'] ?? json['author'],
      thumb:
          // json['img'] ?? json['thumbnail'] ??
          _buildYoutubeThumbnail(videoId, json),
      url: json['url'],
      duration: json['duration'],
    );
  }

  /// Ưu tiên ảnh nét nhất.
  /// UI nên fallback dần nếu ảnh lỗi.
  static String? _buildYoutubeThumbnail(String? videoId, json) {
    if (videoId == null) return null;

    // mặc định trả về ảnh tốt nhất
    return "https://img.youtube.com/vi/$videoId/hqdefault.jpg";
  }

  /// Danh sách thumbnail fallback để UI thử lần lượt
  List<String> get thumbnailFallbacks {
    if (songId == null) return [];

    return [
      "https://img.youtube.com/vi/$songId/hqdefault.jpg",
      "https://img.youtube.com/vi/$songId/mqdefault.jpg",
      "https://img.youtube.com/vi/$songId/default.jpg",
    ];
  }

  SongModel copyWith({
    String? songId,
    String? title,
    String? channel,
    String? thumb,
    String? url,
    int? duration,
  }) {
    return SongModel(
      songId: songId ?? this.songId,
      title: title ?? this.title,
      channel: channel ?? this.channel,
      thumb: thumb ?? this.thumb,
      url: url ?? this.url,
      duration: duration ?? this.duration,
    );
  }

  Map<String, dynamic> toJson() => {
    'video_id': songId,
    'name': title,
    'channel': channel,
    'img': thumb,
    'url': url,
    'duration': duration,
  };
}
