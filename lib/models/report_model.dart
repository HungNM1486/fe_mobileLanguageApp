import 'package:flutter/foundation.dart';

class ReportModel {
  final String? id;
  final String? postId;
  final String? userId;
  final String reason;
  final String? description;
  bool isResolved;
  final String? userName;
  final String? userAvatar;
  final DateTime createdAt;

  ReportModel({
    this.id,
    required this.postId,
    required this.userId,
    required this.reason,
    this.description,
    this.isResolved = false,
    this.userName,
    this.userAvatar,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    try {
      return ReportModel(
        id: json['id']?.toString(),
        postId: json['postId']?.toString(),
        userId: json['userId']?.toString(),
        reason: json['reason'] ?? 'other',
        description: json['description'],
        isResolved: json['isResolved'] ?? false,
        userName: json['user'] != null
            ? json['user']['firstName'] + ' ' + json['user']['lastName']
            : null,
        userAvatar: json['user'] != null ? json['user']['avatar'] : null,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error parsing ReportModel: $e');
      // Fallback to a default model in case of parsing error
      return ReportModel(
        id: json['id']?.toString(),
        postId: json['postId']?.toString() ?? '0',
        userId: json['userId']?.toString() ?? '0',
        reason: 'other',
        isResolved: false,
        createdAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'reason': reason,
      'description': description,
      'isResolved': isResolved,
    };
  }
}
