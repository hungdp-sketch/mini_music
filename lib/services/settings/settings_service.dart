import 'package:shared_preferences/shared_preferences.dart';
import '../../models/settings_model.dart';

class SettingsService {
  static const String _languageKey = 'app_language';
  static const String _trendingKey = 'default_trending_category';
  static const String _notificationsKey = 'enable_notifications';
  static const String _highQualityKey = 'enable_high_quality';
  static const String _streamQualityKey = 'stream_quality';
  static const String _autoPlayNextKey = 'auto_play_next';
  static const String _darkModeKey = 'dark_mode';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<AppSettings> loadSettings() async {
    if (!_prefs.containsKey(_languageKey)) {
      await _saveDefaults();
    }

    return AppSettings(
      language: AppLanguage.fromCode(_prefs.getString(_languageKey) ?? 'vi'),
      defaultTrendingCategory: _getTrendingCategory(
        _prefs.getString(_trendingKey) ?? 'vietnam',
      ),
      enableNotifications: _prefs.getBool(_notificationsKey) ?? true,
      enableHighQuality: _prefs.getBool(_highQualityKey) ?? true,
      streamQuality: _prefs.getDouble(_streamQualityKey) ?? 0.8,
      autoPlayNext: _prefs.getBool(_autoPlayNextKey) ?? true,
      darkMode: _prefs.getBool(_darkModeKey) ?? true,
    );
  }

  Future<void> saveLanguage(AppLanguage language) async {
    await _prefs.setString(_languageKey, language.code);
  }

  Future<void> saveTrendingCategory(TrendingCategory category) async {
    await _prefs.setString(_trendingKey, category.id);
  }

  Future<void> saveNotifications(bool enabled) async {
    await _prefs.setBool(_notificationsKey, enabled);
  }

  Future<void> saveHighQuality(bool enabled) async {
    await _prefs.setBool(_highQualityKey, enabled);
  }

  Future<void> saveStreamQuality(double quality) async {
    await _prefs.setDouble(_streamQualityKey, quality.clamp(0.0, 1.0));
  }

  Future<void> saveAutoPlayNext(bool enabled) async {
    await _prefs.setBool(_autoPlayNextKey, enabled);
  }

  Future<void> saveDarkMode(bool enabled) async {
    await _prefs.setBool(_darkModeKey, enabled);
  }

  Future<void> clearAllSettings() async {
    await _prefs.clear();
    await _saveDefaults();
  }

  Future<void> _saveDefaults() async {
    await _prefs.setString(_languageKey, 'vi');
    await _prefs.setString(_trendingKey, 'vietnam');
    await _prefs.setBool(_notificationsKey, true);
    await _prefs.setBool(_highQualityKey, true);
    await _prefs.setDouble(_streamQualityKey, 0.8);
    await _prefs.setBool(_autoPlayNextKey, true);
    await _prefs.setBool(_darkModeKey, true);
  }

  String getTrendingCategoryCountryCode(TrendingCategory category) {
    return category.countryCode;
  }

  TrendingCategory _getTrendingCategory(String id) {
    return TrendingCategory.values.firstWhere(
      (cat) => cat.id == id,
      orElse: () => TrendingCategory.global,
    );
  }
}
