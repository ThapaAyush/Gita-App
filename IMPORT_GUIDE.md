# Bhagavad Gita As It Is - Data Import & Content Management Guide

This document explains the flexible, offline JSON import architecture for **Bhagavad gita as it is**.

---

## 1. Overview

The application is built with an offline-first SQLite database architecture designed to support:
- All **18 Chapters**
- All **700 Verses** of the Bhagavad Gita

The application ships with a pre-validated authentic seed dataset (`assets/data/gita_seed.json`) containing famous transcendental verses (such as BG 1.1, BG 2.7, BG 2.13, BG 2.20, BG 2.47, BG 3.36, BG 4.7, BG 4.8, BG 7.7, BG 9.2, BG 9.22, BG 9.26, BG 10.8, BG 11.12, BG 12.2, BG 15.15, BG 18.65, BG 18.66, BG 18.78).

An authorized rights-holder or developer can bundle or import the complete 700-verse licensed collection without altering any code.

---

## 2. JSON Structure

Each verse in the import payload must follow this exact structure:

```json
[
  {
    "chapter": 3,
    "verse": 36,
    "sanskrit": "अर्जुन उवाच |\nअथ केन प्रयुक्तोऽयं पापं चरति पूरुषः |\nअनिच्छन्नपि वार्ष्णेय बलादिव नियोजितः || ३६ ||",
    "transliteration": "arjuna uvāca\natha kena prayukto 'yaṁ\npāpaṁ carati pūruṣaḥ\nanicchann api vārṣṇeya\nbalād iva niyojitaḥ",
    "synonyms": "arjunaḥ uvāca — Arjuna said; atha — then; kena — by what; prayuktaḥ — impelled; ayam — this; pāpam — sins; carati — practices; pūruṣaḥ — a man; anicchan — without desiring; api — although; vārṣṇeya — O descendant of Vṛṣṇi; balāt — by force; iva — as if; niyojitaḥ — engaged.",
    "translation": "Arjuna said: O descendant of Vṛṣṇi, by what is one impelled to sinful acts, even unwillingly, as if engaged by force?",
    "purport": "A living entity, as part and parcel of the Supreme, is originally spiritual, pure, and free from all material contaminations..."
  }
]
```

---

## 3. Strict Validation Rules (`ImportValidator`)

The built-in `ImportValidator` (`lib/data/importers/import_validator.dart`) enforces:

1. **Chapter Number Bounds**: Must be an integer between `1` and `18`.
2. **Verse Number Bounds**: Must be between `1` and the canonical verse limit for that chapter:
   - Chapter 1: 47 verses
   - Chapter 2: 72 verses
   - Chapter 3: 43 verses
   - Chapter 4: 42 verses
   - Chapter 5: 29 verses
   - Chapter 6: 47 verses
   - Chapter 7: 30 verses
   - Chapter 8: 28 verses
   - Chapter 9: 34 verses
   - Chapter 10: 42 verses
   - Chapter 11: 55 verses
   - Chapter 12: 20 verses
   - Chapter 13: 35 verses
   - Chapter 14: 27 verses
   - Chapter 15: 20 verses
   - Chapter 16: 24 verses
   - Chapter 17: 28 verses
   - Chapter 18: 78 verses
   - **Total**: 700 verses
3. **Uniqueness**: `chapter_number` + `verse_number` must be unique across the entire dataset.
4. **Unicode Devanagari Integrity**: Preserves genuine Sanskrit diacritics and Devanagari characters (`[\u0900-\u097F]`).
5. **Mandatory Fields**: `sanskrit`, `transliteration`, `synonyms`, and `translation` must not be null or empty.
6. **Purport Coverage**: Long-form purports are validated and verified against truncation.

---

## 4. Programmatic Import Usage

```dart
import 'package:bhagavad_gita_as_it_is/data/importers/gita_data_importer.dart';

final importer = GitaDataImporter();
final result = await importer.importFromJsonString(authorizedJsonPayload);

if (result.isValid) {
  print('Successfully imported ${result.totalCount} verses.');
  if (result.isCompleteCoverage) {
    print('Full 700 verses validated and ready for production!');
  }
} else {
  print('Validation failed:');
  for (final error in result.errors) {
    print(' - $error');
  }
}
```

