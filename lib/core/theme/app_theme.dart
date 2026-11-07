import 'package:flutter/material.dart';
import 'app_colors.dart';

enum ReadingBackgroundMode {
  parchment,
  sepia,
  paper,
  dark,
}

class AppTheme {
  static const String fontSerif = 'Georgia';

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.parchmentBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accentRed,
        onPrimary: Colors.white,
        surface: AppColors.parchmentCard,
        onSurface: AppColors.primaryTextLight,
        secondary: AppColors.secondaryTextLight,
        error: Colors.redAccent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.parchmentBackground,
        foregroundColor: AppColors.primaryTextLight,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.accentRed),
        titleTextStyle: TextStyle(
          fontFamily: fontSerif,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryTextLight,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.parchmentCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.dividerColorLight, width: 0.8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerColorLight,
        thickness: 1,
        space: 24,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: fontSerif,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryTextLight,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontSerif,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryTextLight,
        ),
        titleLarge: TextStyle(
          fontFamily: fontSerif,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryTextLight,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontSerif,
          fontSize: 17,
          height: 1.6,
          color: AppColors.primaryTextLight,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontSerif,
          fontSize: 15,
          height: 1.5,
          color: AppColors.secondaryTextLight,
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.accentRed,
      ),
      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(
          enableFeedback: false,
        ),
      ),
      textButtonTheme: const TextButtonThemeData(
        style: ButtonStyle(
          enableFeedback: false,
        ),
      ),
      elevatedButtonTheme: const ElevatedButtonThemeData(
        style: ButtonStyle(
          enableFeedback: false,
        ),
      ),
      outlinedButtonTheme: const OutlinedButtonThemeData(
        style: ButtonStyle(
          enableFeedback: false,
        ),
      ),
      filledButtonTheme: const FilledButtonThemeData(
        style: ButtonStyle(
          enableFeedback: false,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        enableFeedback: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        enableFeedback: false,
      ),
      popupMenuTheme: const PopupMenuThemeData(
        enableFeedback: false,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkAccentRed,
        onPrimary: Colors.white,
        surface: AppColors.darkCard,
        onSurface: AppColors.primaryTextDark,
        secondary: AppColors.secondaryTextDark,
        error: Colors.redAccent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.primaryTextDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.darkAccentRed),
        titleTextStyle: TextStyle(
          fontFamily: fontSerif,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryTextDark,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.darkDivider, width: 0.8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 24,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: fontSerif,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryTextDark,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontSerif,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryTextDark,
        ),
        titleLarge: TextStyle(
          fontFamily: fontSerif,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryTextDark,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontSerif,
          fontSize: 17,
          height: 1.6,
          color: AppColors.primaryTextDark,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontSerif,
          fontSize: 15,
          height: 1.5,
          color: AppColors.secondaryTextDark,
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.darkAccentRed,
      ),
      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(
          enableFeedback: false,
        ),
      ),
      textButtonTheme: const TextButtonThemeData(
        style: ButtonStyle(
          enableFeedback: false,
        ),
      ),
      elevatedButtonTheme: const ElevatedButtonThemeData(
        style: ButtonStyle(
          enableFeedback: false,
        ),
      ),
      outlinedButtonTheme: const OutlinedButtonThemeData(
        style: ButtonStyle(
          enableFeedback: false,
        ),
      ),
      filledButtonTheme: const FilledButtonThemeData(
        style: ButtonStyle(
          enableFeedback: false,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        enableFeedback: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        enableFeedback: false,
      ),
      popupMenuTheme: const PopupMenuThemeData(
        enableFeedback: false,
      ),
    );
  }

  static Color getBackgroundColor(ReadingBackgroundMode mode, bool isDark) {
    if (mode == ReadingBackgroundMode.dark || isDark) return AppColors.bgDark;
    switch (mode) {
      case ReadingBackgroundMode.parchment:
        return AppColors.bgParchment;
      case ReadingBackgroundMode.sepia:
        return AppColors.bgSepia;
      case ReadingBackgroundMode.paper:
        return AppColors.bgPaper;
      case ReadingBackgroundMode.dark:
        return AppColors.bgDark;
    }
  }

  static Color getCardColor(ReadingBackgroundMode mode, bool isDark) {
    if (mode == ReadingBackgroundMode.dark || isDark) return AppColors.darkCard;
    switch (mode) {
      case ReadingBackgroundMode.parchment:
        return AppColors.parchmentCard;
      case ReadingBackgroundMode.sepia:
        return const Color(0xFFEFE4C2);
      case ReadingBackgroundMode.paper:
        return const Color(0xFFF1EFEA);
      case ReadingBackgroundMode.dark:
        return AppColors.darkCard;
    }
  }

  static Color getPrimaryTextColor(ReadingBackgroundMode mode, bool isDark) {
    if (mode == ReadingBackgroundMode.dark || isDark) return AppColors.primaryTextDark;
    switch (mode) {
      case ReadingBackgroundMode.parchment:
        return AppColors.primaryTextLight;
      case ReadingBackgroundMode.sepia:
        return const Color(0xFF2E2419);
      case ReadingBackgroundMode.paper:
        return const Color(0xFF1E1E1E);
      case ReadingBackgroundMode.dark:
        return AppColors.primaryTextDark;
    }
  }

  static Color getSecondaryTextColor(ReadingBackgroundMode mode, bool isDark) {
    if (mode == ReadingBackgroundMode.dark || isDark) return AppColors.secondaryTextDark;
    switch (mode) {
      case ReadingBackgroundMode.parchment:
        return AppColors.secondaryTextLight;
      case ReadingBackgroundMode.sepia:
        return const Color(0xFF6B5F4D);
      case ReadingBackgroundMode.paper:
        return const Color(0xFF5A5852);
      case ReadingBackgroundMode.dark:
        return AppColors.secondaryTextDark;
    }
  }

  static Color getAccentColor(ReadingBackgroundMode mode, bool isDark) {
    if (mode == ReadingBackgroundMode.dark || isDark) return AppColors.darkAccentRed;
    return AppColors.accentRed;
  }

  static Color getSanskritColor(ReadingBackgroundMode mode, bool isDark) {
    if (mode == ReadingBackgroundMode.dark || isDark) return AppColors.sanskritGoldDark;
    return AppColors.sanskritGold;
  }
}
