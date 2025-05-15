class ReportModel {
  String? id;
  String? postId;
  String? userId;
  String? reason;
  String? description;
  bool? isResolved;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? userName;
  String? userAvatar;
  String? postTitle;

  ReportModel({
    this.id,
    this.postId,
    this.userId,
    this.reason,
    this.description,
    this.isResolved,
    this.createdAt,
    this.updatedAt,
    this.userName,
    this.userAvatar,
    this.postTitle,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id']?.toString(),
      postId: json['postId']?.toString(),
      userId: json['userId']?.toString(),
      reason: json['reason'],
      description: json['description'],
      isResolved: json['isResolved'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      userName: json['userName'],
      userAvatar: json['userAvatar'],
      postTitle: json['postTitle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'reason': reason,
      'description': description,
      'isResolved': isResolved,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'userName': userName,
      'userAvatar': userAvatar,
      'postTitle': postTitle,
    };
  }
}
