class AppConstants {
  static const int totalChapters = 18;
  static const int totalVerses = 700;
  
  // Verse counts per chapter for the complete standard Bhagavad Gita
  static const Map<int, int> chapterVerseCounts = {
    1: 47,
    2: 72,
    3: 43,
    4: 42,
    5: 29,
    6: 47,
    7: 30,
    8: 28,
    9: 34,
    10: 42,
    11: 55,
    12: 20,
    13: 35,
    14: 27,
    15: 20,
    16: 24,
    17: 28,
    18: 78,
  };

  // Asset paths
  static const String coverImage = 'assets/images/bhagavad_gita_cover.png';
  static const String appIconSource = 'assets/images/app_icon_source.png';
  static const String appLogo = 'assets/images/app_logo.png';
  static const String seedJsonPath = 'assets/data/gita_seed.json';
  static const String chaptersJsonPath = 'assets/data/chapters.json';
  
  // Storage Keys
  static const String prefFontSize = 'pref_font_size';
  static const String prefThemeMode = 'pref_theme_mode';
  static const String prefReadingBackground = 'pref_reading_background';
  static const String prefLastChapter = 'pref_last_chapter';
  static const String prefLastVerse = 'pref_last_verse';
  static const String prefDatabaseSeeded = 'pref_db_seeded_v1';

  /// Converts a (chapter, verse) coordinate into a 0-based global verse index (0 to 699)
  static int coordinateToGlobalIndex(int chapter, int verse) {
    int index = 0;
    for (int c = 1; c < chapter; c++) {
      index += chapterVerseCounts[c] ?? 0;
    }
    return index + (verse - 1);
  }

  /// Converts a 0-based global verse index (0 to 699) into (chapter, verse) coordinates
  static ({int chapter, int verse}) globalIndexToCoordinate(int index) {
    int accumulated = 0;
    for (int c = 1; c <= totalChapters; c++) {
      final count = chapterVerseCounts[c] ?? 0;
      if (index < accumulated + count) {
        return (chapter: c, verse: (index - accumulated) + 1);
      }
      accumulated += count;
    }
    return (chapter: 18, verse: 78);
  }
}

