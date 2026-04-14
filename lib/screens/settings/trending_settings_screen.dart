import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/app_localizations.dart';
import '../../core/theme.dart';
import '../../models/settings_model.dart';
import '../../blocs/settings/settings_cubit.dart';

class TrendingSettingsScreen extends StatelessWidget {
  const TrendingSettingsScreen({super.key});

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
        title: Text(context.l10n.trendingCategoryTitle),
        centerTitle: true,
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state is! SettingsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentCategory = state.settings.defaultTrendingCategory;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: TrendingCategory.values.length,
            itemBuilder: (context, index) {
              final category = TrendingCategory.values[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: currentCategory == category
                        ? AppTheme.primaryColor
                        : Colors.white.withValues(alpha: 0.1),
                    width: currentCategory == category ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  onTap: () {
                    context.read<SettingsCubit>().changeTrendingCategory(
                      category,
                    );
                    Navigator.pop(context);
                  },
                  title: Text(category.displayName),
                  trailing: currentCategory == category
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.primaryColor,
                        )
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
