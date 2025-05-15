class TopicModel {
  String id;
  String topic;
  String imageUrl;
  int numbervocabulary;
  String level;
  String createAt;
  String updateAt;
  String languageId;
  bool isDone;

  TopicModel({
    required this.topic,
    required this.id,
    required this.numbervocabulary,
    required this.imageUrl,
    required this.level,
    required this.languageId,
    required this.createAt,
    required this.updateAt,
    this.isDone = false,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) => TopicModel(
        topic: json['topic'] ?? "",
        id: json['id'].toString() ?? "",
        numbervocabulary: json['totalVocabs'] ?? 0,
        imageUrl: json['imageUrl'] ?? "",
        level: json['level'].toString() ?? "",
        createAt: json['createAt'] ?? "",
        updateAt: json['updateAt'] ?? "",
        isDone: json['hasProgress'] ?? false,
        languageId: json['language']['id'].toString() ?? "",
      );
  Map<String, dynamic> toJson() => {
        'topic': topic,
        'id': id,
        'numbervocabulary': numbervocabulary,
        'imageUrl': imageUrl,
        'level': level,
        'createAt': createAt,
        'updateAt': updateAt,
      };
  String translevel() {
    switch (level) {
      case "1":
        return "Cơ bản";
      case "2":
        return "Trung cấp";
      case "3":
        return "Nâng cao";
      default:
        return "Cơ bản";
    }
  }

  @override
  String toString() {
    return 'TopicModel{id: $id, topic: $topic, imageUrl: $imageUrl, numbervocabulary: $numbervocabulary, level: $level, createAt: $createAt, updateAt: $updateAt, isDone: $isDone}';
  }
}
