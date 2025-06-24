class Word {
  final String id;
  final String german;
  final String portuguese;
  final String? example;

  Word({
    required this.id,
    required this.german,
    required this.portuguese,
    this.example,
  });

  factory Word.fromMap(Map<String, dynamic> map, String id) {
    return Word(
      id: id,
      german: map['german'] ?? '',
      portuguese: map['portuguese'] ?? '',
      example: map['example'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'german': german,
      'portuguese': portuguese,
      'example': example,
    };
  }
} 