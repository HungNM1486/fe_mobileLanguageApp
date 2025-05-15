class VocabularyModel {
  final String id;
  final String word;
  final String definition;
  final String example;
  final String exampleTranslation;
  final String topicId;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  VocabularyModel({
    required this.id,
    required this.word,
    required this.definition,
    required this.example,
    required this.exampleTranslation,
    required this.topicId,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VocabularyModel.fromJson(Map<String, dynamic> json) {
    return VocabularyModel(
      id: json['id'].toString() ?? "",
      word: json['word'],
      definition: json['definition'] ?? "",
      example: json['example'],
      exampleTranslation: json['exampleTranslation'],
      topicId: json['vocabTopicId'].toString() ?? "",
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "word": word,
      "definition": definition,
      "example": example,
      "exampleTranslation": exampleTranslation,
      "topicId": topicId,
      "imageUrl": imageUrl,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'VocabularyModel{id: $id, word: $word, definition: $definition, example: $example, exampleTranslation: $exampleTranslation,  topicId: $topicId, imageUrl: $imageUrl, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
