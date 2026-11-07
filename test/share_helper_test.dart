import 'package:flutter_test/flutter_test.dart';
import 'package:bhagavad_gita_as_it_is/core/constants/app_strings.dart';
import 'package:bhagavad_gita_as_it_is/core/utils/share_helper.dart';
import 'package:bhagavad_gita_as_it_is/data/models/verse.dart';

void main() {
  group('ShareHelper Complete Page Content Tests', () {
    test('Formats everything on the verse page including Sanskrit, Transliteration, Synonyms, Translation, and Purport', () {
      const verse = Verse(
        id: 407,
        chapterNumber: 4,
        verseNumber: 7,
        sanskrit: 'यदा यदा हि धर्मस्य ग्लानिर्भवति भारत ।\nअभ्युत्थानमधर्मस्य तदात्मानं सृजाम्यहम् ॥ ७ ॥',
        transliteration: 'yadā yadā hi dharmasya glānir bhavati bhārata\nabhyutthānam adharmasya tadātmānaṁ sṛjāmy aham',
        synonyms: 'yadā yadā — whenever and wherever; hi — certainly; dharmasya — of religion;',
        translation: 'Whenever and wherever there is a decline in religious practice, O descendant of Bharata, and a predominant rise of irreligion — at that time I descend Myself.',
        purport: 'The word sṛjāmi is significant herein. Sṛjāmi cannot be used in the sense of creation, because according to the previous verse, there is no creation of the Lord’s form or body.',
      );

      final content = ShareHelper.formatFullVerseContent(verse);

      // Verify app title & reference
      expect(content, contains(AppStrings.appName));
      expect(content, contains('BG 4.7'));

      // Verify Sanskrit Sloka is included
      expect(content, contains('यदा यदा हि धर्मस्य'));

      // Verify Roman Transliteration is included
      expect(content, contains('yadā yadā hi dharmasya'));

      // Verify SYNONYMS heading & content are included
      expect(content, contains('SYNONYMS'));
      expect(content, contains('whenever and wherever'));

      // Verify TRANSLATION heading & content are included
      expect(content, contains('TRANSLATION'));
      expect(content, contains('Whenever and wherever there is a decline'));

      // Verify PURPORT heading & content are included
      expect(content, contains('PURPORT'));
      expect(content, contains('The word sṛjāmi is significant herein'));

      // Verify Srila Prabhupada author attribution
      expect(content, contains(AppStrings.authorAttribution));
    });
  });
}

