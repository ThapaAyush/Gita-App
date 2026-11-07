import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../domain/scripture_search_engine.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<SearchMatchResult> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    final repo = ref.read(verseRepositoryProvider);
    final results = await repo.searchAdvanced(trimmed);

    if (mounted) {
      setState(() {
        _results = results;
        _isSearching = false;
      });
    }
  }

  Color _getBadgeColor(SearchMatchCategory category, bool isDark) {
    switch (category) {
      case SearchMatchCategory.verseReference:
        return isDark ? Colors.tealAccent.shade400 : Colors.teal.shade700;
      case SearchMatchCategory.sanskrit:
        return isDark ? const Color(0xFFFFB300) : const Color(0xFFB78103);
      case SearchMatchCategory.transliteration:
        return isDark ? Colors.lightBlueAccent.shade200 : Colors.blue.shade700;
      case SearchMatchCategory.translation:
        return isDark ? AppColors.darkAccentRed : AppColors.accentRed;
      case SearchMatchCategory.synonyms:
        return isDark ? Colors.purpleAccent.shade100 : Colors.purple.shade700;
      case SearchMatchCategory.purport:
        return isDark ? Colors.orangeAccent.shade200 : Colors.deepOrange.shade700;
    }
  }

  Widget _buildHighlightedText({
    required String text,
    required List<String> terms,
    required TextStyle baseStyle,
    required TextStyle highlightStyle,
    int maxLines = 3,
  }) {
    if (terms.isEmpty || text.isEmpty) {
      return Text(
        text,
        style: baseStyle,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    final validTerms = terms
        .map((t) => t.trim())
        .where((t) => t.length >= 2)
        .toList();

    if (validTerms.isEmpty) {
      return Text(
        text,
        style: baseStyle,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    // Sort terms by length descending to match longest matches first
    validTerms.sort((a, b) => b.length.compareTo(a.length));
    final pattern = validTerms.map((t) => RegExp.escape(t)).join('|');
    final regex = RegExp('($pattern)', caseSensitive: false);

    final spans = <TextSpan>[];
    int currentPos = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > currentPos) {
        spans.add(TextSpan(
          text: text.substring(currentPos, match.start),
          style: baseStyle,
        ));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: highlightStyle,
      ));
      currentPos = match.end;
    }

    if (currentPos < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentPos),
        style: baseStyle,
      ));
    }

    return RichText(
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: spans),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;
    final accentRedColor = isDark ? AppColors.darkAccentRed : AppColors.accentRed;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.search),
      ),
      body: Column(
        children: [
          // Search Input Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              autofocus: false,
              onSubmitted: _performSearch,
              onChanged: (val) {
                setState(() {});
                final trimmed = val.trim();
                if (trimmed.length >= 2) {
                  _performSearch(trimmed);
                } else if (trimmed.isEmpty) {
                  setState(() {
                    _results = [];
                    _hasSearched = false;
                  });
                }
              },
              decoration: InputDecoration(
                hintText: AppStrings.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.cardTheme.color,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.dividerTheme.color ?? Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.dividerTheme.color ?? Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: accentRedColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Search Results Counter Header
          if (_hasSearched && !_isSearching && _results.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Row(
                children: [
                  Text(
                    'FOUND ${_results.length} MATCHING ${_results.length == 1 ? 'VERSE' : 'VERSES'}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: secondaryTextColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Sorted by Scripture Relevance',
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 4),

          // Search Results List
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _hasSearched
                    ? _results.isEmpty
                        ? const EmptyStateView(
                            icon: Icons.search_off_rounded,
                            title: AppStrings.noSearchResults,
                            message:
                                'Try searching with a verse number (e.g. "4.7"), a Sanskrit word (e.g. "धर्मक्षेत्रे"), transliteration (e.g. "yada yada"), or philosophical topic (e.g. "duty", "soul").',
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                            itemCount: _results.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = _results[index];
                              final verse = item.verse;
                              final badgeColor = _getBadgeColor(item.category, isDark);

                              return Container(
                                decoration: BoxDecoration(
                                  color: theme.cardTheme.color,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.dividerTheme.color ?? Colors.grey.shade300,
                                    width: 0.8,
                                  ),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  enableFeedback: false,
                                  onTap: () {
                                    context.push(
                                      '/reader/${verse.chapterNumber}/${verse.verseNumber}',
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Header Row: Reference badge & Match Category Pill
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: accentRedColor.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                verse.reference,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  color: accentRedColor,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: badgeColor.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: badgeColor.withValues(alpha: 0.3),
                                                  width: 0.8,
                                                ),
                                              ),
                                              child: Text(
                                                item.categoryLabel,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: badgeColor,
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: 13,
                                              color: secondaryTextColor,
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 10),

                                        // Matched Context Snippet (Sanskrit / Transliteration / Purport / Translation)
                                        if (item.category == SearchMatchCategory.sanskrit) ...[
                                          // Display Sanskrit Sloka with highlight
                                          _buildHighlightedText(
                                            text: item.matchSnippet,
                                            terms: item.highlightTerms,
                                            baseStyle: TextStyle(
                                              fontSize: 14,
                                              height: 1.4,
                                              fontWeight: FontWeight.w500,
                                              color: primaryTextColor,
                                            ),
                                            highlightStyle: TextStyle(
                                              fontSize: 14,
                                              height: 1.4,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? const Color(0xFFFFD54F) : const Color(0xFFB78103),
                                              backgroundColor: isDark
                                                  ? const Color(0x33FFD54F)
                                                  : const Color(0x29FFC107),
                                            ),
                                            maxLines: 2,
                                          ),
                                          const SizedBox(height: 6),
                                          // Secondary Translation Preview
                                          Text(
                                            verse.translation,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: 'Georgia',
                                              fontSize: 13,
                                              height: 1.35,
                                              color: secondaryTextColor,
                                            ),
                                          ),
                                        ] else if (item.category == SearchMatchCategory.transliteration) ...[
                                          // Display Transliteration with highlight
                                          _buildHighlightedText(
                                            text: item.matchSnippet,
                                            terms: item.highlightTerms,
                                            baseStyle: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 14,
                                              height: 1.4,
                                              color: primaryTextColor,
                                            ),
                                            highlightStyle: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 14,
                                              height: 1.4,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? Colors.lightBlueAccent : Colors.blue.shade900,
                                              backgroundColor: isDark
                                                  ? Colors.lightBlueAccent.withValues(alpha: 0.2)
                                                  : Colors.blue.shade100,
                                            ),
                                            maxLines: 2,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            verse.translation,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: 'Georgia',
                                              fontSize: 13,
                                              height: 1.35,
                                              color: secondaryTextColor,
                                            ),
                                          ),
                                        ] else if (item.category == SearchMatchCategory.purport) ...[
                                          // Display Purport Excerpt
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(top: 2.0, right: 6.0),
                                                child: Icon(
                                                  Icons.format_quote_rounded,
                                                  size: 14,
                                                  color: badgeColor,
                                                ),
                                              ),
                                              Expanded(
                                                child: _buildHighlightedText(
                                                  text: item.matchSnippet,
                                                  terms: item.highlightTerms,
                                                  baseStyle: TextStyle(
                                                    fontFamily: 'Georgia',
                                                    fontSize: 13.5,
                                                    height: 1.4,
                                                    color: primaryTextColor,
                                                  ),
                                                  highlightStyle: TextStyle(
                                                    fontFamily: 'Georgia',
                                                    fontSize: 13.5,
                                                    height: 1.4,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDark ? Colors.orangeAccent : Colors.deepOrange.shade800,
                                                    backgroundColor: isDark
                                                        ? Colors.orangeAccent.withValues(alpha: 0.2)
                                                        : Colors.orange.shade100,
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Translation: ${verse.translation}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                              color: secondaryTextColor,
                                            ),
                                          ),
                                        ] else ...[
                                          // Default / Translation / Synonyms / Verse Reference
                                          if (verse.sanskrit.isNotEmpty) ...[
                                            Text(
                                              verse.sanskrit.split('\n').first,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: secondaryTextColor,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                          ],
                                          _buildHighlightedText(
                                            text: item.matchSnippet,
                                            terms: item.highlightTerms,
                                            baseStyle: TextStyle(
                                              fontFamily: 'Georgia',
                                              fontSize: 14,
                                              height: 1.4,
                                              color: primaryTextColor,
                                            ),
                                            highlightStyle: TextStyle(
                                              fontFamily: 'Georgia',
                                              fontSize: 14,
                                              height: 1.4,
                                              fontWeight: FontWeight.bold,
                                              color: accentRedColor,
                                              backgroundColor: accentRedColor.withValues(alpha: 0.12),
                                            ),
                                            maxLines: 3,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
