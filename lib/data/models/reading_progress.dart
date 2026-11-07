class ReadingProgress {
  final int? id;
  final int lastChapter;
  final int lastVerse;
  final DateTime updatedAt;

  const ReadingProgress({
    this.id,
    required this.lastChapter,
    required this.lastVerse,
    required this.updatedAt,
  });

  String get reference => 'BG $lastChapter.$lastVerse';

  factory ReadingProgress.fromMap(Map<String, dynamic> map) {
    return ReadingProgress(
      id: map['id'] as int?,
      lastChapter: map['last_chapter'] as int? ?? 1,
      lastVerse: map['last_verse'] as int? ?? 1,
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'last_chapter': lastChapter,
      'last_verse': lastVerse,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

