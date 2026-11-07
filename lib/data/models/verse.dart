class Verse {
  final int? id;
  final int chapterNumber;
  final int verseNumber;
  final String sanskrit;
  final String transliteration;
  final String synonyms;
  final String translation;
  final String purport;

  const Verse({
    this.id,
    required this.chapterNumber,
    required this.verseNumber,
    required this.sanskrit,
    required this.transliteration,
    required this.synonyms,
    required this.translation,
    required this.purport,
  });

  String get reference => 'BG $chapterNumber.$verseNumber';

  factory Verse.fromMap(Map<String, dynamic> map) {
    return Verse(
      id: map['id'] as int?,
      chapterNumber: map['chapter_number'] as int,
      verseNumber: map['verse_number'] as int,
      sanskrit: map['sanskrit'] as String? ?? '',
      transliteration: map['transliteration'] as String? ?? '',
      synonyms: map['synonyms'] as String? ?? '',
      translation: map['translation'] as String? ?? '',
      purport: map['purport'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'chapter_number': chapterNumber,
      'verse_number': verseNumber,
      'sanskrit': sanskrit,
      'transliteration': transliteration,
      'synonyms': synonyms,
      'translation': translation,
      'purport': purport,
    };
  }

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      chapterNumber: json['chapter'] as int? ?? json['chapter_number'] as int,
      verseNumber: json['verse'] as int? ?? json['verse_number'] as int,
      sanskrit: json['sanskrit'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? '',
      synonyms: json['synonyms'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      purport: json['purport'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapter': chapterNumber,
      'verse': verseNumber,
      'sanskrit': sanskrit,
      'transliteration': transliteration,
      'synonyms': synonyms,
      'translation': translation,
      'purport': purport,
    };
  }
}

