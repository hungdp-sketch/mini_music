import 'package:equatable/equatable.dart';
import 'song_model.dart';

class PlaylistModel extends Equatable {
  final String id;
  final String name;
  final List<SongModel> songs;
  final int createdAtMs;
  final int updatedAtMs;

  const PlaylistModel({
    required this.id,
    required this.name,
    required this.songs,
    required this.createdAtMs,
    required this.updatedAtMs,
  });

  PlaylistModel copyWith({
    String? id,
    String? name,
    List<SongModel>? songs,
    int? createdAtMs,
    int? updatedAtMs,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      songs: songs ?? this.songs,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    final rawSongs = (json['songs'] as List<dynamic>? ?? const []);
    return PlaylistModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Playlist').toString(),
      songs: rawSongs
          .map((e) => SongModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
      updatedAtMs: (json['updatedAtMs'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'songs': songs.map((s) => s.toJson()).toList(),
    'createdAtMs': createdAtMs,
    'updatedAtMs': updatedAtMs,
  };

  @override
  List<Object?> get props => [id, name, songs, createdAtMs, updatedAtMs];
}

