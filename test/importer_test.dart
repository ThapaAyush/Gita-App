import 'package:flutter_test/flutter_test.dart';
import 'package:bhagavad_gita_as_it_is/data/importers/import_validator.dart';

void main() {
  group('JSON Import Validation Tests', () {
    test('Validates authentic verse with proper Sanskrit Unicode and all fields', () {
      final validData = [
        {
          "chapter": 1,
          "verse": 1,
          "sanskrit": "धृतराष्ट्र उवाच |\nधर्मक्षेत्रे कुरुक्षेत्रे समवेता युयुत्सवः |",
          "transliteration": "dhṛtarāṣṭra uvāca\ndharma-kṣetre kuru-kṣetre",
          "synonyms": "dhṛtarāṣṭraḥ uvāca — King Dhṛtarāṣṭra said;",
          "translation": "Dhṛtarāṣṭra said: O Sañjaya, after my sons and the sons of Pāṇḍu assembled...",
          "purport": "Bhagavad-gītā is the widely read theistic science..."
        }
      ];

      final result = ImportValidator.validate(validData);
      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
      expect(result.totalCount, equals(1));
    });

    test('Rejects invalid chapter outside range 1-18', () {
      final invalidData = [
        {
          "chapter": 19,
          "verse": 1,
          "sanskrit": "श्लोक",
          "transliteration": "sloka",
          "synonyms": "synonyms",
          "translation": "translation",
          "purport": "purport"
        }
      ];

      final result = ImportValidator.validate(invalidData);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('outside the valid range 1-18')), isTrue);
    });

    test('Rejects verse number outside chapter canonical count', () {
      // Chapter 1 has 47 verses. Verse 48 is invalid.
      final invalidData = [
        {
          "chapter": 1,
          "verse": 48,
          "sanskrit": "श्लोक",
          "transliteration": "sloka",
          "synonyms": "synonyms",
          "translation": "translation",
          "purport": "purport"
        }
      ];

      final result = ImportValidator.validate(invalidData);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('outside canonical range 1-47')), isTrue);
    });

    test('Detects duplicate chapter and verse coordinates', () {
      final duplicateData = [
        {
          "chapter": 2,
          "verse": 47,
          "sanskrit": "कर्मण्येवाधिकारस्ते",
          "transliteration": "karmaṇy evādhikāras te",
          "synonyms": "karmaṇi — in prescribed duties;",
          "translation": "You have a right to perform your prescribed duty...",
          "purport": "Purport..."
        },
        {
          "chapter": 2,
          "verse": 47,
          "sanskrit": "कर्मण्येवाधिकारस्ते",
          "transliteration": "karmaṇy evādhikāras te",
          "synonyms": "karmaṇi — in prescribed duties;",
          "translation": "Duplicate translation",
          "purport": "Duplicate purport"
        }
      ];

      final result = ImportValidator.validate(duplicateData);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('Duplicate verse')), isTrue);
    });

    test('Flags missing required translation and Sanskrit fields', () {
      final incompleteData = [
        {
          "chapter": 3,
          "verse": 36,
          "sanskrit": "",
          "transliteration": "arjuna uvāca",
          "synonyms": "arjunaḥ uvāca — Arjuna said;",
          "translation": "",
          "purport": "Purport"
        }
      ];

      final result = ImportValidator.validate(incompleteData);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('Missing or empty "sanskrit"')), isTrue);
      expect(result.errors.any((e) => e.contains('Missing or empty "translation"')), isTrue);
    });
  });
}
