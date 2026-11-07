import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_settings.dart';
import '../../../data/providers.dart';
import '../../../shared/widgets/app_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(userSettingsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // Typography / Font Size Card
          AppCard(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.format_size,
                      color: isDark ? AppColors.darkAccentRed : AppColors.accentRed,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Reading Font Size (${settings.fontSize.toInt()} pt)',
                      style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('A', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Slider(
                        value: settings.fontSize,
                        min: 13,
                        max: 28,
                        divisions: 15,
                        activeColor: isDark ? AppColors.darkAccentRed : AppColors.accentRed,
                        label: '${settings.fontSize.toInt()} pt',
                        onChanged: (val) {
                          ref.read(userSettingsProvider.notifier).setFontSize(val);
                        },
                      ),
                    ),
                    const Text('A', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                // Live Preview Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.getCardColor(settings.readingBackground, isDark),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.dividerTheme.color ?? Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    'यदा यदा हि धर्मस्य ग्लानिर्भवति भारत |\nअभ्युत्थानमधर्मस्य तदात्मानं सृजाम्यहम् ||\n\nWhenever and wherever there is a decline in religious practice, O descendant of Bharata, and a predominant rise of irreligion — at that time I descend Myself.',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: settings.fontSize,
                      height: 1.5,
                      color: isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Theme Mode Card
          AppCard(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.palette_outlined,
                      color: isDark ? AppColors.darkAccentRed : AppColors.accentRed,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Application Theme',
                      style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'light',
                      icon: Icon(Icons.wb_sunny_outlined),
                      label: Text('Light'),
                    ),
                    ButtonSegment(
                      value: 'dark',
                      icon: Icon(Icons.nightlight_outlined),
                      label: Text('Dark'),
                    ),
                    ButtonSegment(
                      value: 'system',
                      icon: Icon(Icons.settings_suggest_outlined),
                      label: Text('System'),
                    ),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (Set<String> newSelection) {
                    ref.read(userSettingsProvider.notifier).setThemeMode(newSelection.first);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Reading Background Preference Card
          AppCard(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      color: isDark ? AppColors.darkAccentRed : AppColors.accentRed,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Reader Background Aesthetic',
                      style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _bgOption(ref, 'Parchment', AppColors.bgParchment, ReadingBackgroundMode.parchment, settings),
                    _bgOption(ref, 'Sepia', AppColors.bgSepia, ReadingBackgroundMode.sepia, settings),
                    _bgOption(ref, 'Paper', AppColors.bgPaper, ReadingBackgroundMode.paper, settings),
                    _bgOption(ref, 'Dark', AppColors.bgDark, ReadingBackgroundMode.dark, settings),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Navigation Links & Reset
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About Bhagavad Gita As It Is'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/about'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restart_alt, color: Colors.orange),
                  title: const Text('Reset Reading Preferences'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Reset Preferences?'),
                        content: const Text('This will reset font size and background color to default values.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.read(userSettingsProvider.notifier).reset();
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Preferences reset to default')),
                              );
                            },
                            child: const Text('Reset', style: TextStyle(color: Colors.redAccent)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _bgOption(
    WidgetRef ref,
    String title,
    Color color,
    ReadingBackgroundMode mode,
    UserSettings settings,
  ) {
    final isSelected = settings.readingBackground == mode;
    return GestureDetector(
      onTap: () {
        ref.read(userSettingsProvider.notifier).setReadingBackground(mode);
      },
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.accentRed : Colors.grey.shade400,
                width: isSelected ? 3.0 : 1.0,
              ),
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    size: 22,
                    color: mode == ReadingBackgroundMode.dark ? Colors.white : AppColors.accentRed,
                  )
                : null,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

