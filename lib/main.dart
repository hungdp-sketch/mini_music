import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'core/theme.dart';
import 'blocs/search/search_cubit.dart';
import 'blocs/player/player_cubit.dart';
import 'blocs/settings/settings_cubit.dart';
import 'blocs/history/history_cubit.dart';
import 'blocs/playlist/playlist_cubit.dart';
import 'screens/home/home_screen.dart';
import 'services/settings/settings_service.dart';
import 'services/history/history_service.dart';
import 'services/playlist/playlist_service.dart';
import 'youtube/yt_audio_resolver.dart';
// ignore: unused_import
import 'services/player/audio_player_service.dart';
// ignore: unused_import
import 'services/player/eq_service.dart';

Future<void> main() async {
  // Initialize background playback
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  // Initialize settings service
  final settingsService = SettingsService();
  await settingsService.init();

  // Initialize history service
  final historyService = HistoryService();
  await historyService.init();

  // Initialize playlist service
  final playlistService = PlaylistService();
  await playlistService.init();

  // Initialize YouTube resolver cache
  await YtAudioResolver.init();

  // EQ is self-initializing via audioPipeline getter
  // No explicit init needed

  runApp(
    MyApp(
      settingsService: settingsService,
      historyService: historyService,
      playlistService: playlistService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final SettingsService settingsService;
  final HistoryService historyService;
  final PlaylistService playlistService;

  const MyApp({
    super.key,
    required this.settingsService,
    required this.historyService,
    required this.playlistService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SearchCubit()..loadTrending()),
        BlocProvider(create: (_) => HistoryCubit(historyService)),
        BlocProvider(create: (_) => PlaylistCubit(playlistService)),
        BlocProvider(
          create: (context) =>
              PlayerCubit(historyService, context.read<HistoryCubit>()),
        ),
        BlocProvider(
          create: (context) => SettingsCubit(
            settingsService,
            searchCubit: context.read<SearchCubit>(),
          )..loadSettings(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812), // iPhone X design size
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Mini Music',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}

class PlaceholderHome extends StatelessWidget {
  const PlaceholderHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Mini Music',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
    );
  }
}
