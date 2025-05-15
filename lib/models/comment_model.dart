class CommentModel {
  final int id;
  final int postId;
  final int userId;
  final String content;
  final String createdAt;
  final String updatedAt;
  final String? userDisplayName;
  final String? userAvatar;
  final List<CommentModel> replies;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.userDisplayName,
    this.userAvatar,
    this.replies = const [],
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] as Map<String, dynamic>?;

    // Xử lý tên hiển thị người dùng
    String? displayName;
    if (userMap != null) {
      // Kiểm tra các trường hợp khác nhau của tên người dùng
      if (userMap.containsKey('displayName') &&
          userMap['displayName'] != null) {
        displayName = userMap['displayName'];
      } else if (userMap.containsKey('firstName') ||
          userMap.containsKey('lastName')) {
        String firstName = userMap['firstName'] ?? '';
        String lastName = userMap['lastName'] ?? '';
        displayName = '$firstName $lastName'.trim();
      } else if (userMap.containsKey('name')) {
        displayName = userMap['name'];
      } else if (userMap.containsKey('username')) {
        displayName = userMap['username'];
      }
    }

    // Xử lý avatar của người dùng
    String? avatarUrl;
    if (userMap != null) {
      // Kiểm tra các trường hợp khác nhau của avatar
      if (userMap.containsKey('avatar') && userMap['avatar'] != null) {
        avatarUrl = userMap['avatar'];
      } else if (userMap.containsKey('profileImageUrl')) {
        avatarUrl = userMap['profileImageUrl'];
      } else if (userMap.containsKey('profileImage')) {
        avatarUrl = userMap['profileImage'];
      } else if (userMap.containsKey('imageUrl')) {
        avatarUrl = userMap['imageUrl'];
      }
    }

    // Đảm bảo các trường bắt buộc có giá trị mặc định nếu null
    int id = 0;
    int postId = 0;
    int userId = 0;
    String content = '';
    String createdAt = '';
    String updatedAt = '';

    try {
      id = json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0;
      postId = json['postId'] is int
          ? json['postId']
          : int.tryParse(json['postId']?.toString() ?? '0') ?? 0;
      userId = json['userId'] is int
          ? json['userId']
          : int.tryParse(json['userId']?.toString() ?? '0') ?? 0;
      content = json['content']?.toString() ?? '';
      createdAt = json['createdAt']?.toString() ?? '';
      updatedAt = json['updatedAt']?.toString() ?? '';
    } catch (e) {
      print('Lỗi khi parse dữ liệu comment: $e');
    }

    List<CommentModel> replies = [];
    if (json['replies'] != null && json['replies'] is List) {
      try {
        replies = List<CommentModel>.from(
            json['replies'].map((x) => CommentModel.fromJson(x)));
      } catch (e) {
        print('Lỗi khi parse replies: $e');
      }
    }

    return CommentModel(
      id: id,
      postId: postId,
      userId: userId,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      userDisplayName: displayName,
      userAvatar: avatarUrl,
      replies: replies,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'user': {
        'displayName': userDisplayName,
        'avatar': userAvatar,
      },
      'replies': replies.map((reply) => reply.toJson()).toList(),
    };
  }
}
