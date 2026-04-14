import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../blocs/settings/settings_cubit.dart';
import '../../blocs/history/history_cubit.dart';
import '../../blocs/player/player_cubit.dart';
import '../../core/app_localizations.dart';
import '../../core/theme.dart';
import 'language_settings_screen.dart';
import 'trending_settings_screen.dart';
import 'privacy_terms_screen.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(context.l10n.settingsTitle),
        centerTitle: true,
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SettingsError) {
            return Center(child: Text('Lỗi: ${state.message}'));
          }

          if (state is! SettingsLoaded) {
            return const SizedBox.shrink();
          }

          final settings = state.settings;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // // Audio Settings Section
                // _buildSectionHeader(context.l10n.audioSettingsHeader),
                // _buildSettingsTile(
                //   icon: Icons.high_quality_rounded,
                //   title: context.l10n.soundQualityTitle,
                //   subtitle: context.l10n.soundQualitySubtitle,
                //   trailing: Switch(
                //     value: settings.enableHighQuality,
                //     onChanged: (value) {
                //       context.read<SettingsCubit>().toggleHighQuality(value);
                //     },
                //     activeThumbColor: AppTheme.primaryColor,
                //   ),
                // ),
                // _buildSettingsTile(
                //   icon: Icons.volume_up_rounded,
                //   title: 'Chất lượng stream',
                //   subtitle:
                //       'Độ phân giải: ${(settings.streamQuality * 100).toStringAsFixed(0)}%',
                //   trailing: SizedBox(
                //     width: 120,
                //     child: Slider(
                //       value: settings.streamQuality,
                //       onChanged: (value) {},
                //       onChangeEnd: (value) {
                //         context.read<SettingsCubit>().setStreamQuality(value);
                //       },
                //       activeColor: AppTheme.primaryColor,
                //       inactiveColor: Colors.white.withValues(alpha: 0.1),
                //     ),
                //   ),
                // ),
                // _buildSettingsTile(
                //   icon: Icons.skip_next_rounded,
                //   title: context.l10n.autoplayNextTitle,
                //   subtitle: context.l10n.autoplayNextSubtitle,
                //   trailing: Switch(
                //     value: settings.autoPlayNext,
                //     onChanged: (value) {
                //       context.read<SettingsCubit>().toggleAutoPlayNext(value);
                //     },
                //     activeThumbColor: AppTheme.primaryColor,
                //   ),
                // ),
                // const SizedBox(height: 20),

                // Personalization Section
                _buildSectionHeader(context.l10n.personalizationHeader),
                _buildNavigationTile(
                  icon: Icons.language_rounded,
                  title: context.l10n.languageTitle,
                  subtitle: settings.language.displayName,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LanguageSettingsScreen(),
                      ),
                    );
                  },
                ),
                _buildNavigationTile(
                  icon: Icons.trending_up_rounded,
                  title: context.l10n.trendingCategoryTitle,
                  subtitle: settings.defaultTrendingCategory.displayName,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TrendingSettingsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Notification Settings
                // _buildSectionHeader(context.l10n.notificationsHeader),
                // _buildSettingsTile(
                //   icon: Icons.notifications_active_rounded,
                //   title: context.l10n.enableNotificationsTitle,
                //   subtitle: context.l10n.enableNotificationsSubtitle,
                //   trailing: Switch(
                //     value: settings.enableNotifications,
                //     onChanged: (value) {
                //       context.read<SettingsCubit>().toggleNotifications(value);
                //     },
                //     activeThumbColor: AppTheme.primaryColor,
                //   ),
                // ),
                const SizedBox(height: 20),

                // App Store & Legal Section
                _buildSectionHeader(context.l10n.legalHeader),
                _buildNavigationTile(
                  icon: Icons.privacy_tip_rounded,
                  title: context.l10n.privacyPolicyTitle,
                  subtitle: context.l10n.privacyPolicySubtitle,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrivacyTermsScreen(
                          title: context.l10n.privacyPolicyTitle,
                          content: context.l10n.privacyPolicyContent,
                        ),
                      ),
                    );
                  },
                ),
                _buildNavigationTile(
                  icon: Icons.description_rounded,
                  title: context.l10n.termsOfServiceTitle,
                  subtitle: context.l10n.termsOfServiceSubtitle,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrivacyTermsScreen(
                          title: context.l10n.termsOfServiceTitle,
                          content: context.l10n.termsOfServiceContent,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // About Section
                _buildSectionHeader(context.l10n.aboutAppTitle),
                _buildNavigationTile(
                  icon: Icons.info_rounded,
                  title: context.l10n.aboutAppTitle,
                  subtitle: context.l10n.aboutAppSubtitle,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Danger Zone
                _buildSectionHeader(context.l10n.dangerHeader),
                _buildActionTile(
                  icon: Icons.refresh_rounded,
                  title: context.l10n.resetSettingsTitle,
                  subtitle: context.l10n.resetSettingsSubtitle,
                  color: Colors.orange,
                  onTap: () {
                    _showResetDialog(context);
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppTheme.secondaryTextColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withValues(alpha: 0.3),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: color),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(context.l10n.resetDialogTitle),
        content: Text(context.l10n.resetDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancelButton),
          ),
          TextButton(
            onPressed: () {
              _resetEverything(context);
            },
            child: Text(
              context.l10n.resetButton,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resetEverything(BuildContext context) async {
    // Close dialog first to avoid context issues.
    Navigator.pop(context);

    final settingsCubit = context.read<SettingsCubit>();
    final historyCubit = context.read<HistoryCubit>();
    final playerCubit = context.read<PlayerCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final snackBarText = context.l10n.resetSnackBar;

    // 1) Reset settings + URL caches + EQ + speed (handled inside SettingsCubit).
    await settingsCubit.resetAppEverything();

    // 2) Clear Recently (history).
    await historyCubit.clearRecently();

    // 3) Reset player position (keep audio engine stable; this doesn't reinit player).
    playerCubit.seek(Duration.zero);

    // 4) Clear Flutter image caches + disk cache used by cached_network_image.
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    await DefaultCacheManager().emptyCache();

    messenger.showSnackBar(
      SnackBar(content: Text(snackBarText)),
    );
  }
}
