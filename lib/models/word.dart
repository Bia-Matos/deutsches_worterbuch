class Word {
  final String id;
  final String german;
  final String portuguese;
  final String? example;
  final String? imageUrl;
  final String? article; // "der", "die", "das"
  final String? gender;  // "m", "f", "n"

  Word({
    required this.id,
    required this.german,
    required this.portuguese,
    this.example,
    this.imageUrl,
    this.article,
    this.gender,
  });

  factory Word.fromMap(Map<String, dynamic> map, String id) {
    return Word(
      id: id,
      german: map['german'] ?? '',
      portuguese: map['portuguese'] ?? '',
      example: map['example'],
      imageUrl: map['imageUrl'],
      article: map['article'],
      gender: map['gender'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'german': german,
      'portuguese': portuguese,
      'example': example,
      'imageUrl': imageUrl,
      'article': article,
      'gender': gender,
    };
  }

  // Helper para verificar se é substantivo (tem artigo)
  bool get isNoun => article != null && article!.isNotEmpty;
} 