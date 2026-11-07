import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bhagavad_gita_as_it_is/core/constants/app_strings.dart';

import 'package:bhagavad_gita_as_it_is/shared/widgets/ornamental_divider.dart';
import 'package:bhagavad_gita_as_it_is/shared/widgets/app_card.dart';
import 'package:bhagavad_gita_as_it_is/features/reader/presentation/widgets/sanskrit_section.dart';
import 'package:bhagavad_gita_as_it_is/features/reader/presentation/widgets/translation_section.dart';

void main() {
  group('Widget & UI Component Tests', () {
    testWidgets('OrnamentalDivider renders with devotional icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OrnamentalDivider(),
          ),
        ),
      );

      expect(find.byType(OrnamentalDivider), findsOneWidget);
      expect(find.byIcon(Icons.brightness_7), findsOneWidget);
    });

    testWidgets('AppCard renders child and responds to tap', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard(
              onTap: () {
                tapped = true;
              },
              child: const Text('Devotional Card'),
            ),
          ),
        ),
      );

      expect(find.text('Devotional Card'), findsOneWidget);
      await tester.tap(find.text('Devotional Card'));
      expect(tapped, isTrue);
    });

    testWidgets('SanskritSection renders Devanagari text properly', (WidgetTester tester) async {
      const sanskritText = 'धर्मक्षेत्रे कुरुक्षेत्रे समवेता युयुत्सवः';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SanskritSection(
              sanskrit: sanskritText,
              fontSize: 17.0,
            ),
          ),
        ),
      );

      expect(find.text(sanskritText), findsOneWidget);
    });

    testWidgets('TranslationSection displays TRANSLATION heading and body', (WidgetTester tester) async {
      const translation = 'You have a right to perform your prescribed duty...';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TranslationSection(
              translation: translation,
              fontSize: 17.0,
            ),
          ),
        ),
      );

      expect(find.text(AppStrings.translationTitle.toUpperCase()), findsOneWidget);
      expect(find.text(translation), findsOneWidget);
    });
  });
}
