class AchievementModel {
  final int id;
  final String title;
  final String description;
  final String badgeImageUrl;
  final String triggerCondition;
  final int conditionValue;
  final DateTime? unlockedAt;
  final bool isUnlocked;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.badgeImageUrl,
    required this.triggerCondition,
    required this.conditionValue,
    this.unlockedAt,
    this.isUnlocked = false,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      badgeImageUrl: json['badgeImageUrl'] ?? '',
      triggerCondition: json['triggerCondition'] ?? '',
      conditionValue: json['conditionValue'] ?? 0,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
      isUnlocked: json['unlockedAt'] != null,
    );
  }
}
