import '../../core/theme/app_theme.dart';

class UserSettings {
  final double fontSize;
  final String themeMode; // 'system', 'light', 'dark'
  final ReadingBackgroundMode readingBackground;

  const UserSettings({
    this.fontSize = 17.0,
    this.themeMode = 'light',
    this.readingBackground = ReadingBackgroundMode.parchment,
  });

  UserSettings copyWith({
    double? fontSize,
    String? themeMode,
    ReadingBackgroundMode? readingBackground,
  }) {
    return UserSettings(
      fontSize: fontSize ?? this.fontSize,
      themeMode: themeMode ?? this.themeMode,
      readingBackground: readingBackground ?? this.readingBackground,
    );
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      fontSize: (map['font_size'] as num?)?.toDouble() ?? 17.0,
      themeMode: map['theme_mode'] as String? ?? 'light',
      readingBackground: ReadingBackgroundMode.values.firstWhere(
        (e) => e.name == map['reading_background'],
        orElse: () => ReadingBackgroundMode.parchment,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'font_size': fontSize,
      'theme_mode': themeMode,
      'reading_background': readingBackground.name,
    };
  }
}

