class LikeModel {
  String? id;
  String? userId;
  String? postId;

  LikeModel({
    this.id,
    this.userId,
    this.postId,
  });

  LikeModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? json['id'].toString() : "";
    userId = json['userId'] != null ? json['userId'].toString() : "";
    postId = json['postId'] != null ? json['postId'].toString() : "";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['post_id'] = postId;

    return data;
  }
}
