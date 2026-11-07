# Bhagavad gita as it is

A production-grade, offline-first cross-platform mobile application based on the authentic English edition of **Bhagavad Gita As It Is** by **His Divine Grace A.C. Bhaktivedanta Swami Srila Prabhupada**.

The application delivers a contemplative reading experience inspired by traditional Indian scripture bookmaking and the devotional design language of classic scripture readers.

---

## 1. Design & Aesthetic Philosophy

- **Traditional Spiritual Aesthetic**: Parchment / warm pale yellow reading background (`#E4E1B6`) paired with dark charcoal sacred typography (`#222117`), deep red spiritual accents (`#B51F2A`), and card backgrounds (`#F0EBCB`).
- **Devotional Layout**: Screen 4 faithfully reproduces the canonical Srimad Bhagavatam reading structure:
  1. **Sanskrit Verse** in proper Devanagari Unicode script.
  2. **Roman Transliteration** with accurate IAST diacritical marks.
  3. **Synonyms**: Word-for-word Sanskrit to English equivalents.
  4. **Translation**: Prominently presented sacred rendering.
  5. **Purport**: Long-form spiritual commentary by Srila Prabhupada without truncation.
- **Reading Comfort**: Support for 4 distinct background aesthetics:
  - *Parchment* (`#E4E1B6`)
  - *Warm Sepia* (`#F5ECCB`)
  - *Clean Paper* (`#FAF8F2`)
  - *Night Dark* (`#191813`)
- **Fluid Typography**: Dynamic font-size scaling from 13 pt to 28 pt with live preview.

---

## 2. Technology Stack & Architecture

- **Framework**: Flutter 3.47+ / Dart 3.13+ (Material 3)
- **Architecture**: Feature-First Clean Architecture
- **State Management**: Flutter Riverpod (`StateNotifierProvider`, `FutureProvider`, `Provider`)
- **Navigation**: GoRouter (deep-linking, path parameters, smooth transitions)
- **Local Database**: Embedded SQLite (`sqflite`, `path_provider`)
- **Local Preferences**: `shared_preferences`
- **Native Sharing**: `share_plus`
- **Target Platforms**: Android & iOS

```
lib/
  main.dart
  core/
    constants/
      app_constants.dart
      app_strings.dart
    routes/
      app_router.dart
    theme/
      app_colors.dart
      app_theme.dart
    utils/
      share_helper.dart
  data/
    database/
      app_database.dart
    importers/
      import_validator.dart
      gita_data_importer.dart
    models/
      chapter.dart
      verse.dart
      bookmark.dart
      reading_progress.dart
      user_settings.dart
    providers.dart
    repositories/
      chapter_repository.dart
      verse_repository.dart
      bookmark_repository.dart
      reading_progress_repository.dart
      settings_repository.dart
  features/
    splash/presentation/splash_screen.dart
    home/presentation/home_screen.dart
    chapters/presentation/chapter_detail_screen.dart
    reader/presentation/verse_reader_screen.dart
    bookmarks/presentation/bookmarks_screen.dart
    search/presentation/search_screen.dart
    settings/presentation/settings_screen.dart
    about/presentation/about_screen.dart
  shared/widgets/
    app_card.dart
    ornamental_divider.dart
    empty_state_view.dart
    error_view.dart
```

---

## 3. Database Architecture & Schema

The application operates **100% offline** without any network dependency.

### Tables
1. **`chapters`**:
   - `id INTEGER PRIMARY KEY`
   - `chapter_number INTEGER NOT NULL UNIQUE`
   - `title TEXT NOT NULL`
   - `introduction TEXT`
   - `verse_count INTEGER NOT NULL DEFAULT 0`
2. **`verses`**:
   - `id INTEGER PRIMARY KEY AUTOINCREMENT`
   - `chapter_number INTEGER NOT NULL`
   - `verse_number INTEGER NOT NULL`
   - `sanskrit TEXT NOT NULL`
   - `transliteration TEXT NOT NULL`
   - `synonyms TEXT NOT NULL`
   - `translation TEXT NOT NULL`
   - `purport TEXT NOT NULL`
   - `UNIQUE(chapter_number, verse_number)`
3. **`bookmarks`**:
   - `id INTEGER PRIMARY KEY AUTOINCREMENT`
   - `chapter_number INTEGER NOT NULL`
   - `verse_number INTEGER NOT NULL`
   - `created_at TEXT NOT NULL`
   - `UNIQUE(chapter_number, verse_number)`
4. **`reading_progress`**:
   - `id INTEGER PRIMARY KEY`
   - `last_chapter INTEGER NOT NULL`
   - `last_verse INTEGER NOT NULL`
   - `updated_at TEXT NOT NULL`
5. **`user_settings`**:
   - `id INTEGER PRIMARY KEY`
   - `font_size REAL NOT NULL DEFAULT 17.0`
   - `theme_mode TEXT NOT NULL DEFAULT 'light'`
   - `reading_background TEXT NOT NULL DEFAULT 'parchment'`

---

## 4. Chapter Boundary Navigation

The reader dynamically navigates forward and backward across chapter boundaries:
- At `BG 1.1`: Previous verse is disabled (`null`).
- At `BG 2.1`: Previous verse seamlessly navigates to `BG 1.47` (the last verse of Chapter 1).
- At `BG 1.47`: Next verse seamlessly navigates to `BG 2.1`.
- At `BG 18.78`: Next verse is disabled (`null`).

---

## 5. Offline Search

Search queries support:
- Chapter & Verse coordinates (e.g. `2.47`, `BG 2.47`, `18:66`)
- Chapter numbers (e.g. `2` returns Chapter 2 verses)
- Keyword search across translation, synonyms, transliteration, and purports (e.g. `duty`, `soul`, `surrender`, `bhakti`).

---

## 6. Testing & Quality Assurance

All unit and widget tests pass with **0 errors, 0 warnings**:
```bash
flutter test
```
Test suite includes:
- `test/importer_test.dart`: JSON schema validation, bounds checks (Chapters 1-18, verse counts), Devanagari Unicode preservation, duplicate detection.
- `test/verse_navigation_test.dart`: Chapter boundary transitions, start/end boundaries.
- `test/models_test.dart`: Model serialization and deserialization.
- `test/widget_test.dart`: Sanskrit and Translation widget rendering, card interactions, ornamental dividers.

---

## 7. Building for Android

Ensure Java 17 and Android SDK are configured:

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Android App Bundle (for Google Play)
flutter build appbundle --release
```

---

## 8. Building for iOS (macOS & Xcode)

To generate the iOS build on macOS:

1. Clone or copy the repository to a macOS machine with Xcode 15+ installed.
2. Install CocoaPods:
   ```bash
   sudo gem install cocoapods
   ```
3. Navigate to the project directory:
   ```bash
   cd "Bhagavad gita as it is"
   flutter pub get
   cd ios
   pod install
   cd ..
   ```
4. Build the release IPA or archive:
   ```bash
   # Build iOS release bundle
   flutter build ipa --release
   ```
5. Open the workspace in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
6. In Xcode:
   - Select the **Runner** project in the navigator.
   - Under **Signing & Capabilities**, select your Apple Developer Team.
   - Verify Display Name is set to `Bhagavad gita as it is`.
   - Choose **Product > Archive** to build and upload to TestFlight / App Store.

---

## 9. Artwork & Licensing

- **Book Cover Image**: Place official cover scan at `assets/images/bhagavad_gita_cover.png`.
- **App Icon Source**: Place official artwork at `assets/images/app_icon_source.png`.
- Refer to `COPYRIGHT_AND_LICENSING.md` and `IMPORT_GUIDE.md` for complete BBT licensing details.
