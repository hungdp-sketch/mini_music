import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';

enum EqPreset { flat, bassBoost, trebleBoost, rock, pop }

extension EqPresetName on EqPreset {
  String get displayName {
    switch (this) {
      case EqPreset.flat:        return 'Flat';
      case EqPreset.bassBoost:   return 'Bass Boost';
      case EqPreset.trebleBoost: return 'Treble';
      case EqPreset.rock:        return 'Rock';
      case EqPreset.pop:         return 'Pop';
    }
  }
}

class EqService {
  static final EqService instance = EqService._init();
  EqService._init();

  AndroidEqualizer? _androidEqualizer;
  static const _channel = MethodChannel('mini_music/eq');

  bool _isEnabled = false;
  EqPreset _currentPreset = EqPreset.flat;

  bool get isEnabled => _isEnabled;
  EqPreset get currentPreset => _currentPreset;

  // 5-band gains: 60Hz, 230Hz, 910Hz, 3.6kHz, 14kHz
  static const Map<EqPreset, List<double>> _presets = {
    EqPreset.flat:        [0.0,  0.0,  0.0,  0.0,  0.0],
    EqPreset.bassBoost:   [6.0,  4.0,  0.0,  0.0,  0.0],
    EqPreset.trebleBoost: [0.0,  0.0,  0.0,  4.0,  6.0],
    EqPreset.rock:        [4.0,  2.0, -1.0,  2.0,  4.0],
    EqPreset.pop:         [-1.0, 3.0,  4.0,  3.0, -1.0],
  };

  /// Provides AudioPipeline for player initialization (Android only)
  AudioPipeline? get audioPipeline {
    if (defaultTargetPlatform == TargetPlatform.android) {
      _androidEqualizer = AndroidEqualizer();
      return AudioPipeline(androidAudioEffects: [_androidEqualizer!]);
    }
    return null;
  }

  Future<void> enable(bool enable) async {
    _isEnabled = enable;
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _androidEqualizer?.setEnabled(enable);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _channel.invokeMethod('enable', {'enabled': enable});
    }
    debugPrint('[EqService] EQ ${enable ? "enabled" : "disabled"}');
  }

  Future<void> setBandGain(int bandIndex, double gain) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final parameters = await _androidEqualizer?.parameters;
      if (parameters != null && bandIndex < parameters.bands.length) {
        parameters.bands[bandIndex].setGain(gain);
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _channel.invokeMethod('setBandGain', {
        'band': bandIndex,
        'gain': gain,
      });
    }
  }

  /// Get current band gains from Android EQ (or from preset cache on iOS)
  Future<List<double>> getBandGains() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final parameters = await _androidEqualizer?.parameters;
      if (parameters != null) {
        return parameters.bands.map((b) => b.gain).toList();
      }
    }
    // iOS or fallback: return preset values
    return List<double>.from(_presets[_currentPreset] ?? _presets[EqPreset.flat]!);
  }

  /// Apply a full preset (sets all 5 bands)
  Future<void> applyPreset(EqPreset preset) async {
    _currentPreset = preset;
    final gains = _presets[preset] ?? _presets[EqPreset.flat]!;
    debugPrint('[EqService] Applying preset: ${preset.displayName} → $gains');
    for (int i = 0; i < gains.length; i++) {
      await setBandGain(i, gains[i]);
    }
  }

  /// Get the number of EQ bands available
  Future<int> getBandCount() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final parameters = await _androidEqualizer?.parameters;
      return parameters?.bands.length ?? 5;
    }
    return 5;
  }

  /// Band frequency labels
  static const List<String> bandLabels = [
    '60Hz', '230Hz', '910Hz', '3.6kHz', '14kHz'
  ];
}
