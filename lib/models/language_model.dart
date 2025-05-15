class LanguageModel {
  final String id;
  final String name;
  final String code;
  final String imageUrl;
  final String description;
  final String createdAt;
  final String updatedAt;

  LanguageModel({
    required this.id,
    required this.name,
    required this.code,
    required this.imageUrl,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id'].toString() ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      imageUrl: json['flagUrl'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['createdAt'] ?? json['createAt'] ?? '',
      updatedAt: json['updatedAt'] ?? json['updateAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'imageUrl': imageUrl,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  String toString() {
    return 'LanguageModel{id: $id, name: $name, code: $code, imageUrl: $imageUrl, description: $description, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
