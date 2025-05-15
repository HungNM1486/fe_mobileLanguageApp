import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NotificationModel {
  final int? id;
  final String title;
  final String content;
  final DateTime createdAt;
  final bool isRead;
  final String type;
  final Map<String, dynamic>? data;

  NotificationModel({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.isRead,
    required this.type,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Debug the input JSON
    debugPrint('Parsing notification: ${json['id']} - ${json['title']}');

    // Handle different date field names and formats
    DateTime parsedDate;
    try {
      if (json.containsKey('createdAt')) {
        parsedDate = DateTime.parse(json['createdAt']);
      } else {
        debugPrint(
            'No date field found in notification JSON, using current time');
        parsedDate = DateTime.now();
      }
    } catch (e) {
      debugPrint('Error parsing date: $e');
      parsedDate = DateTime.now();
    }

    return NotificationModel(
      id: json['id'],
      title: json['title'] ?? 'Thông báo',
      content: json['content'] ?? '',
      createdAt: parsedDate,
      isRead: json['isRead'] ?? false,
      type: json['type'] ?? 'system',
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'type': type,
      'data': data,
    };
  }

  // Return appropriate icon based on notification type
  IconData get icon {
    switch (type) {
      case 'comment':
        return Icons.comment;
      case 'achievement':
        return Icons.emoji_events;
      case 'reminder':
        return Icons.alarm;
      case 'system':
      default:
        return Icons.notifications;
    }
  }

  // Return appropriate color based on notification type
  Color get color {
    switch (type) {
      case 'comment':
        return Colors.green;
      case 'achievement':
        return Colors.amber;
      case 'reminder':
        return Colors.blue;
      case 'system':
      default:
        return Colors.purple;
    }
  }

  // Format the time display in a user-friendly way
  String get time {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  // Create a copy of this notification with some fields updated
  NotificationModel copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? createdAt,
    bool? isRead,
    String? type,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      data: data ?? this.data,
    );
  }
}
