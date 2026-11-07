class Bookmark {
  final int? id;
  final int chapterNumber;
  final int verseNumber;
  final DateTime createdAt;
  final String? translationPreview;

  const Bookmark({
    this.id,
    required this.chapterNumber,
    required this.verseNumber,
    required this.createdAt,
    this.translationPreview,
  });

  String get reference => 'BG $chapterNumber.$verseNumber';

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id'] as int?,
      chapterNumber: map['chapter_number'] as int,
      verseNumber: map['verse_number'] as int,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      translationPreview: map['translation'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'chapter_number': chapterNumber,
      'verse_number': verseNumber,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

