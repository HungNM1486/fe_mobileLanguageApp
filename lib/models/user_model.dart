import 'package:language_app/models/progress_model.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String firstname;
  final String lastname;
  final String profile_image_url;
  final String role;
  final List<ProgressModel> progress;
  final String createAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstname,
    required this.lastname,
    required this.profile_image_url,
    required this.role,
    this.createAt = "",
    this.progress = const [],
  });
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString() ?? "",
      username: json['username'] ?? "",
      email: json['email'] ?? "",
      firstname: json['firstName'] ?? "",
      lastname: json['lastName'] ?? "",
      profile_image_url: json['profileImageUrl'] ?? "",
      role: json['role'],
      createAt: json['createdAt'] ?? "",
      progress: (json['progress'] as List<dynamic>? ?? [])
          .map((e) => ProgressModel.fromJson(e))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
      'profile_image_url': profile_image_url,
      'role': role,
      'createAt': createAt,
    };
  }

  @override
  String toString() {
    return 'UserModel{id: $id, username: $username, email: $email, firstname: $firstname, lastname: $lastname, profile_image_url: $profile_image_url, role: $role, progress: $progress, createAt: $createAt}';
  }
}
