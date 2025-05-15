class ProgressModel {
  String id;
  bool isActive;
  String createdAt;

  ProgressModel({
    required this.id,
    required this.isActive,
    required this.createdAt,
  });
  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      id: json['id'].toString() ?? "",
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }

  @override
  String toString() {
    return 'ProgressModel{id: $id, isActive: $isActive, createdAt: $createdAt}';
  }
}
