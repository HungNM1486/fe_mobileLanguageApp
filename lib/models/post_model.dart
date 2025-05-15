import 'package:language_app/models/comment_model.dart';
import 'package:language_app/models/like_model.dart';

class PostModel {
  String? id;
  String? title;
  String? content;
  String? userId;
  String? userName;
  String? userAvatar;
  String? languageId;
  List<String>? tags;
  List<String>? imageUrls;
  List<LikeModel>? likes;
  List<CommentModel>? comments;
  DateTime? createdAt;
  DateTime? updatedAt;

  PostModel({
    this.id,
    this.title,
    this.content,
    this.userId,
    this.userName,
    this.languageId,
    this.tags,
    this.imageUrls,
    this.likes,
    this.comments,
    this.createdAt,
    this.updatedAt,
    this.userAvatar,
  });

  PostModel.fromJson(Map<String, dynamic> json) {
    // Debug log để kiểm tra dữ liệu JSON
    // print('PostModel.fromJson: ${json.toString()}');

    id = json['id'] != null ? json['id'].toString() : "";
    title = json['title'] ?? "";
    content = json['content'] ?? "";
    userId = json['userId'] != null ? json['userId'].toString() : "";
    languageId =
        json['languageId'] != null ? json['languageId'].toString() : "";

    // Xử lý dữ liệu người dùng đúng cách
    if (json['user'] != null) {
      userName =
          "${json['user']['firstName'] ?? ''} ${json['user']['lastName'] ?? ''}"
              .trim();
      userAvatar = json['user']['profileImageUrl'];
    } else {
      userName = "";
      userAvatar = "";
    }

    // Xử lý các mảng
    imageUrls =
        json['imageUrls'] != null ? List<String>.from(json['imageUrls']) : [];
    tags = json['tags'] != null ? List<String>.from(json['tags']) : [];

    // Xử lý comments và likes
    if (json['comments'] != null && json['comments'] is List) {
      try {
        comments = List<CommentModel>.from(
            json['comments'].map((x) => CommentModel.fromJson(x)));
      } catch (e) {
        print('Lỗi khi parse comments: $e');
        comments = [];
      }
    } else {
      comments = [];
    }

    if (json['likes'] != null && json['likes'] is List) {
      try {
        likes = List<LikeModel>.from(
            json['likes'].map((x) => LikeModel.fromJson(x)));
      } catch (e) {
        print('Lỗi khi parse likes: $e');
        likes = [];
      }
    } else {
      likes = [];
    }

    // Xử lý ngày tháng
    try {
      createdAt =
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
    } catch (e) {
      print('Lỗi khi parse createdAt: $e');
      createdAt = null;
    }

    try {
      updatedAt =
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null;
    } catch (e) {
      print('Lỗi khi parse updatedAt: $e');
      updatedAt = null;
    }
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'userId': userId,
      'languageId': languageId,
      'userName': userName,
      'tags': tags,
      'imageUrls': imageUrls,
      'likes': likes?.map((e) => e.toJson()).toList(),
      'comments': comments?.map((e) => e.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'PostModel{id: $id, title: $title, content: $content, userId: $userId, userName: $userName, languageId: $languageId, tags: $tags, imageUrls: $imageUrls, likes: $likes, comments: $comments, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
