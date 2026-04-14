import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/song_model.dart';

/// Hiển thị 1–3 ảnh thumb từ các bài đầu playlist, xếp chồng lệch & xoay nhẹ.
class PlaylistCoverStack extends StatelessWidget {
  final List<SongModel> songs;
  final double size;
  final BorderRadius? borderRadius;

  const PlaylistCoverStack({
    super.key,
    required this.songs,
    this.size = 48,
    this.borderRadius,
  });

  List<String> get _thumbUrls {
    final out = <String>[];
    for (final s in songs) {
      final t = s.thumb;
      if (t != null && t.isNotEmpty) {
        out.add(t);
        if (out.length >= 3) break;
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final thumbs = _thumbUrls;
    final r = borderRadius ?? BorderRadius.circular(size * 0.26);

    if (thumbs.isEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppTheme.accentGradient,
            borderRadius: r,
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Icon(
            Icons.queue_music_rounded,
            color: Colors.white.withValues(alpha: 0.9),
            size: size * 0.45,
          ),
        ),
      );
    }

    final thumbSize = size * 0.68;
    final layers = _layerConfigs(thumbs.length);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: List.generate(thumbs.length, (i) {
          final cfg = layers[i];
          return Align(
            alignment: cfg.alignment,
            child: Transform.rotate(
              angle: cfg.angle,
              child: _CoverThumb(
                url: thumbs[i],
                width: thumbSize,
                height: thumbSize,
                radius: BorderRadius.circular(thumbSize * 0.22),
              ),
            ),
          );
        }),
      ),
    );
  }

  static List<_CoverLayer> _layerConfigs(int count) {
    if (count == 1) {
      return const [
        _CoverLayer(alignment: Alignment.center, angle: -0.06),
      ];
    }
    if (count == 2) {
      return const [
        _CoverLayer(alignment: Alignment(-0.58, -0.52), angle: -0.14),
        _CoverLayer(alignment: Alignment(0.5, 0.48), angle: 0.1),
      ];
    }
    return const [
      _CoverLayer(alignment: Alignment(-0.62, -0.55), angle: -0.13),
      _CoverLayer(alignment: Alignment(0.05, 0.02), angle: 0.09),
      _CoverLayer(alignment: Alignment(0.62, 0.58), angle: -0.07),
    ];
  }
}

class _CoverLayer {
  final Alignment alignment;
  final double angle;

  const _CoverLayer({required this.alignment, required this.angle});
}

class _CoverThumb extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final BorderRadius radius;

  const _CoverThumb({
    required this.url,
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width * 0.20),
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: AppTheme.cardColor),
          errorWidget: (context, url, error) => Container(
            color: AppTheme.cardColor,
            child: Icon(
              Icons.music_note_rounded,
              color: Colors.white.withValues(alpha: 0.35),
              size: width * 0.4,
            ),
          ),
        ),
      ),
    );
  }
}
