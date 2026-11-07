import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/about/presentation/about_screen.dart';
import '../../features/bookmarks/presentation/bookmarks_screen.dart';
import '../../features/chapters/presentation/chapter_detail_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/reader/presentation/verse_reader_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/chapters/:id',
      builder: (context, state) {
        final idStr = state.pathParameters['id'] ?? '1';
        final chNum = int.tryParse(idStr) ?? 1;
        return ChapterDetailScreen(chapterNumber: chNum);
      },
    ),
    GoRoute(
      path: '/reader/:chapter/:verse',
      builder: (context, state) {
        final chStr = state.pathParameters['chapter'] ?? '1';
        final vrStr = state.pathParameters['verse'] ?? '1';
        final chNum = int.tryParse(chStr) ?? 1;
        final vrNum = int.tryParse(vrStr) ?? 1;
        return VerseReaderScreen(
          chapterNumber: chNum,
          verseNumber: vrNum,
        );
      },
    ),
    GoRoute(
      path: '/bookmarks',
      builder: (context, state) => const BookmarksScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri}'),
    ),
  ),
);

