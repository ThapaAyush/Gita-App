class Chapter {
  final int id;
  final int chapterNumber;
  final String title;
  final String? introduction;
  final int verseCount;

  const Chapter({
    required this.id,
    required this.chapterNumber,
    required this.title,
    this.introduction,
    required this.verseCount,
  });

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      id: map['id'] as int? ?? map['chapter_number'] as int,
      chapterNumber: map['chapter_number'] as int,
      title: map['title'] as String,
      introduction: map['introduction'] as String?,
      verseCount: map['verse_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chapter_number': chapterNumber,
      'title': title,
      'introduction': introduction,
      'verse_count': verseCount,
    };
  }

  factory Chapter.fromJson(Map<String, dynamic> json) {
    final chNum = json['chapter_number'] as int;
    return Chapter(
      id: chNum,
      chapterNumber: chNum,
      title: json['title'] as String,
      introduction: json['introduction'] as String?,
      verseCount: json['verse_count'] as int? ?? 0,
    );
  }
}

