import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum AppLanguage {
  vietnamese('vi', 'Tiếng Việt'),
  english('en', 'English');

  final String code;
  final String displayName;

  const AppLanguage(this.code, this.displayName);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.vietnamese,
    );
  }

  Locale get locale {
    switch (this) {
      case AppLanguage.english:
        return const Locale('en', 'US');
      case AppLanguage.vietnamese:
        return const Locale('vi', 'VN');
    }
  }
}

enum TrendingCategory {
  global('global', '🌍 Toàn cầu', 'UK'),
  vietnam('vietnam', '🇻🇳 Việt Nam', 'VN'),
  asia('asia', '🌏 Châu Á', 'TH'),
  kpop('kpop', '🎤 K-Pop', 'KR'),
  western('western', '🎸 Phương Tây', 'US');

  final String id;
  final String displayName;
  final String countryCode;

  const TrendingCategory(this.id, this.displayName, this.countryCode);
}

class AppSettings extends Equatable {
  final AppLanguage language;
  final TrendingCategory defaultTrendingCategory;
  final bool enableNotifications;
  final bool enableHighQuality;
  final double streamQuality; // 0.0 to 1.0
  final bool autoPlayNext;
  final bool darkMode;
  final String appVersion;
  final String buildNumber;

  const AppSettings({
    this.language = AppLanguage.vietnamese,
    this.defaultTrendingCategory = TrendingCategory.global,
    this.enableNotifications = true,
    this.enableHighQuality = true,
    this.streamQuality = 0.8,
    this.autoPlayNext = true,
    this.darkMode = true,
    this.appVersion = '1.0.0',
    this.buildNumber = '1',
  });

  AppSettings copyWith({
    AppLanguage? language,
    TrendingCategory? defaultTrendingCategory,
    bool? enableNotifications,
    bool? enableHighQuality,
    double? streamQuality,
    bool? autoPlayNext,
    bool? darkMode,
    String? appVersion,
    String? buildNumber,
  }) {
    return AppSettings(
      language: language ?? this.language,
      defaultTrendingCategory:
          defaultTrendingCategory ?? this.defaultTrendingCategory,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableHighQuality: enableHighQuality ?? this.enableHighQuality,
      streamQuality: streamQuality ?? this.streamQuality,
      autoPlayNext: autoPlayNext ?? this.autoPlayNext,
      darkMode: darkMode ?? this.darkMode,
      appVersion: appVersion ?? this.appVersion,
      buildNumber: buildNumber ?? this.buildNumber,
    );
  }

  @override
  List<Object?> get props => [
    language,
    defaultTrendingCategory,
    enableNotifications,
    enableHighQuality,
    streamQuality,
    autoPlayNext,
    darkMode,
    appVersion,
    buildNumber,
  ];
}
