import 'package:share_plus/share_plus.dart';
import '../../data/models/verse.dart';
import '../constants/app_strings.dart';

class ShareHelper {
  /// Formats everything on the verse page into a complete devotional scripture message.
  static String formatFullVerseContent(Verse verse) {
    final buffer = StringBuffer();
    buffer.writeln(AppStrings.appName);
    buffer.writeln('${verse.reference}\n');

    if (verse.sanskrit.trim().isNotEmpty) {
      buffer.writeln(verse.sanskrit.trim());
      buffer.writeln();
    }

    if (verse.transliteration.trim().isNotEmpty) {
      buffer.writeln(verse.transliteration.trim());
      buffer.writeln();
    }

    if (verse.synonyms.trim().isNotEmpty) {
      buffer.writeln('SYNONYMS');
      buffer.writeln(verse.synonyms.trim());
      buffer.writeln();
    }

    if (verse.translation.trim().isNotEmpty) {
      buffer.writeln('TRANSLATION');
      buffer.writeln(verse.translation.trim());
      buffer.writeln();
    }

    if (verse.purport.trim().isNotEmpty) {
      buffer.writeln('PURPORT');
      buffer.writeln(verse.purport.trim());
      buffer.writeln();
    }

    buffer.writeln('— ${AppStrings.authorAttribution}');
    return buffer.toString().trim();
  }

  /// Shares the complete content of the verse page via the system share sheet.
  static Future<void> shareVerse(Verse verse) async {
    final fullText = formatFullVerseContent(verse);
    await Share.share(
      fullText,
      subject: '${AppStrings.appName} - ${verse.reference}',
    );
  }
}
