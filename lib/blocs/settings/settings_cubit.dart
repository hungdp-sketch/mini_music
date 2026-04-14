import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/settings_model.dart';
import '../../services/settings/settings_service.dart';
import '../../services/player/audio_player_service.dart';
import '../../services/player/eq_service.dart';
import '../../youtube/yt_audio_resolver.dart';
import '../../youtube/yt_video_resolver.dart';
import '../search/search_cubit.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsService settingsService;
  final SearchCubit? searchCubit;

  SettingsCubit(this.settingsService, {this.searchCubit})
    : super(const SettingsInitial());

  Future<void> loadSettings() async {
    try {
      emit(const SettingsLoading());
      final settings = await settingsService.loadSettings();
      AudioPlayerService.instance.applySettings(settings);
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> changeLanguage(AppLanguage language) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      await settingsService.saveLanguage(language);
      emit(SettingsLoaded(currentState.settings.copyWith(language: language)));
    }
  }

  Future<void> changeTrendingCategory(TrendingCategory category) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      await settingsService.saveTrendingCategory(category);
      emit(
        SettingsLoaded(
          currentState.settings.copyWith(defaultTrendingCategory: category),
        ),
      );
      // Reload trending with new category across the entire app
      searchCubit?.loadTrending(category: category);
    }
  }

  Future<void> toggleNotifications(bool enabled) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      await settingsService.saveNotifications(enabled);
      emit(
        SettingsLoaded(
          currentState.settings.copyWith(enableNotifications: enabled),
        ),
      );
    }
  }

  Future<void> toggleHighQuality(bool enabled) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      await settingsService.saveHighQuality(enabled);
      final next = currentState.settings.copyWith(enableHighQuality: enabled);
      AudioPlayerService.instance.applySettings(next);
      emit(SettingsLoaded(next));
    }
  }

  void previewStreamQuality(double quality) {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final next = currentState.settings.copyWith(
        streamQuality: quality.clamp(0.0, 1.0),
      );
      AudioPlayerService.instance.applySettings(next);
      emit(SettingsLoaded(next));
    }
  }

  Future<void> setStreamQuality(double quality) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      await settingsService.saveStreamQuality(quality);
      final next = currentState.settings.copyWith(
        streamQuality: quality.clamp(0.0, 1.0),
      );
      AudioPlayerService.instance.applySettings(next);
      emit(SettingsLoaded(next));
    }
  }

  Future<void> toggleAutoPlayNext(bool enabled) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      await settingsService.saveAutoPlayNext(enabled);
      final next = currentState.settings.copyWith(autoPlayNext: enabled);
      AudioPlayerService.instance.applySettings(next);
      emit(SettingsLoaded(next));
    }
  }

  /// Full reset: clear app caches + revert settings to defaults.
  /// UI should also clear "recently" and reset any UI-scoped state.
  Future<void> resetAppEverything() async {
    try {
      emit(const SettingsLoading());

      // Clear persisted settings to defaults.
      await settingsService.clearAllSettings();

      // Clear URL caches (YouTube resolvers).
      await YtAudioResolver.clearUrlCache();
      await YtVideoResolver.init();
      await YtVideoResolver.clearUrlCache();

      // Reset EQ.
      await EqService.instance.enable(false);
      await EqService.instance.applyPreset(EqPreset.flat);

      // Reload + apply to audio engine.
      final settings = await settingsService.loadSettings();
      AudioPlayerService.instance.applySettings(settings);

      // Reset playback speed to default.
      await AudioPlayerService.instance.setSpeed(1.0);

      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> resetSettings() async {
    try {
      emit(const SettingsLoading());
      await settingsService.clearAllSettings();
      final settings = await settingsService.loadSettings();
      AudioPlayerService.instance.applySettings(settings);
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }
}
