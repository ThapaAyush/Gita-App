import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../models/user_settings.dart';

abstract class SettingsRepository {
  Future<UserSettings> getSettings();
  Future<void> updateFontSize(double fontSize);
  Future<void> updateThemeMode(String themeMode);
  Future<void> updateReadingBackground(ReadingBackgroundMode mode);
  Future<void> resetSettings();
}

class SharedPreferencesSettingsRepository implements SettingsRepository {
  @override
  Future<UserSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final fontSize = prefs.getDouble(AppConstants.prefFontSize) ?? 17.0;
    final themeMode = prefs.getString(AppConstants.prefThemeMode) ?? 'light';
    final bgName = prefs.getString(AppConstants.prefReadingBackground) ?? 'parchment';
    
    final bgMode = ReadingBackgroundMode.values.firstWhere(
      (e) => e.name == bgName,
      orElse: () => ReadingBackgroundMode.parchment,
    );

    return UserSettings(
      fontSize: fontSize,
      themeMode: themeMode,
      readingBackground: bgMode,
    );
  }

  @override
  Future<void> updateFontSize(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.prefFontSize, fontSize);
  }

  @override
  Future<void> updateThemeMode(String themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefThemeMode, themeMode);
  }

  @override
  Future<void> updateReadingBackground(ReadingBackgroundMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefReadingBackground, mode.name);
  }

  @override
  Future<void> resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefFontSize);
    await prefs.remove(AppConstants.prefThemeMode);
    await prefs.remove(AppConstants.prefReadingBackground);
  }
}

