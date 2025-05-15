import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:language_app/models/comment_model.dart';
import 'package:language_app/utils/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommentService {
  final String baseUrl = UrlUtils.getBaseUrl();

  // Get the authorization token from shared preferences
  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        debugPrint('Không tìm thấy token');
      }
      return token;
    } catch (e) {
      debugPrint('Lỗi khi lấy token: $e');
      return null;
    }
  }

  // Get headers with authorization token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }

  // Handle API response
  dynamic _handleResponse(http.Response response) {
    debugPrint(
        'API Response Status: ${response.statusCode}, Body length: ${response.body.length}');

    if (response.body.isEmpty && response.statusCode != 204) {
      debugPrint('Phản hồi rỗng');
      throw Exception('Phản hồi rỗng từ server');
    }

    // Nếu là 204 No Content (thành công nhưng không có nội dung)
    if (response.statusCode == 204) {
      return {'success': true, 'data': null};
    }

    try {
      final responseData = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        final errorMessage = responseData['message'] ?? 'Lỗi không xác định';
        debugPrint('API Error: $errorMessage');
        throw Exception('API Error: $errorMessage');
      }
    } catch (e) {
      debugPrint('Lỗi khi xử lý phản hồi: $e');
      // Nếu status code là thành công, trả về một đối tượng đơn giản
      // thay vì throw exception, để luồng xử lý tiếp tục
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('Status thành công, nhưng có lỗi parse: $e');
        return {'success': true, 'data': null};
      }
      throw Exception('Không thể xử lý phản hồi: $e');
    }
  }

  // Lấy tất cả bình luận của một bài viết
  Future<List<CommentModel>> getCommentsByPostId(int postId) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${baseUrl}post-comments/post/$postId');

      debugPrint('Đang lấy bình luận cho bài viết từ: $uri');
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 204) {
        debugPrint('Không có bình luận nào (204)');
        return [];
      }

      try {
        final data = _handleResponse(response);

        List<CommentModel> comments = [];
        if (data['data'] != null && data['data'] is List) {
          comments = (data['data'] as List)
              .map((commentData) => CommentModel.fromJson(commentData))
              .toList();
          debugPrint('Đã tìm thấy ${comments.length} bình luận');
        }

        return comments;
      } catch (parseError) {
        debugPrint('Lỗi khi parse dữ liệu bình luận: ${parseError.toString()}');
        debugPrint('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy bình luận: $e');
      return [];
    }
  }

  // Tạo bình luận mới
  Future<CommentModel?> createComment(int postId, String content) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${baseUrl}post-comments');

      final body = jsonEncode({
        'postId': postId,
        'content': content,
      });

      debugPrint('Đang tạo bình luận mới tại: $uri');
      final response = await http.post(uri, headers: headers, body: body);

      debugPrint(
          'API Response Status: ${response.statusCode}, Body length: ${response.body.length}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          debugPrint('Bình luận đã được tạo thành công');
          final data = _handleResponse(response);

          // Kiểm tra xem data có chứa thông tin bình luận không
          if (data != null && data['data'] != null) {
            return CommentModel.fromJson(data['data']);
          } else {
            debugPrint(
                'Bình luận đã tạo thành công nhưng không nhận được data');
            // Tạo một đối tượng comment giả tạm thời
            return CommentModel(
              id: 0, // Sẽ được thay thế khi làm mới
              postId: postId,
              userId: 0, // Sẽ được thay thế khi làm mới
              content: content,
              createdAt: DateTime.now().toIso8601String(),
              updatedAt: DateTime.now().toIso8601String(),
            );
          }
        } catch (parseError) {
          debugPrint(
              'Lỗi khi parse dữ liệu bình luận: ${parseError.toString()}');
          debugPrint('Response body: ${response.body}');

          // Vẫn trả về một đối tượng comment tạm thời
          if (response.statusCode == 201) {
            return CommentModel(
              id: 0,
              postId: postId,
              userId: 0,
              content: content,
              createdAt: DateTime.now().toIso8601String(),
              updatedAt: DateTime.now().toIso8601String(),
            );
          }
          return null;
        }
      } else {
        debugPrint(
            'Không thể tạo bình luận: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Lỗi khi tạo bình luận: ${e.toString()}');
      return null;
    }
  }

  // Cập nhật bình luận
  Future<CommentModel?> updateComment(int commentId, String content) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${baseUrl}post-comments/$commentId');

      final body = jsonEncode({
        'content': content,
      });

      debugPrint('Đang cập nhật bình luận ID $commentId tại: $uri');
      final response = await http.patch(uri, headers: headers, body: body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          debugPrint('Bình luận đã được cập nhật thành công');
          final data = _handleResponse(response);

          if (data != null && data['data'] != null) {
            return CommentModel.fromJson(data['data']);
          } else {
            debugPrint(
                'Bình luận đã cập nhật thành công nhưng không nhận được data');
            // Tạo một đối tượng comment giả tạm thời với nội dung đã cập nhật
            return CommentModel(
              id: commentId,
              postId: 0, // Sẽ được thay thế khi làm mới
              userId: 0, // Sẽ được thay thế khi làm mới
              content: content,
              createdAt: DateTime.now().toIso8601String(),
              updatedAt: DateTime.now().toIso8601String(),
            );
          }
        } catch (parseError) {
          debugPrint(
              'Lỗi khi parse dữ liệu bình luận: ${parseError.toString()}');
          debugPrint('Response body: ${response.body}');

          // Vẫn trả về một đối tượng comment tạm thời với nội dung đã cập nhật
          if (response.statusCode >= 200 && response.statusCode < 300) {
            return CommentModel(
              id: commentId,
              postId: 0,
              userId: 0,
              content: content,
              createdAt: DateTime.now().toIso8601String(),
              updatedAt: DateTime.now().toIso8601String(),
            );
          }
          return null;
        }
      } else {
        debugPrint(
            'Không thể cập nhật bình luận: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Lỗi khi cập nhật bình luận: ${e.toString()}');
      return null;
    }
  }

  // Xóa bình luận
  Future<bool> deleteComment(int commentId) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${baseUrl}post-comments/$commentId');

      debugPrint('Đang xóa bình luận ID $commentId tại: $uri');
      final response = await http.delete(uri, headers: headers);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('Bình luận đã được xóa thành công');
        return true;
      } else {
        debugPrint(
            'Không thể xóa bình luận: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Lỗi khi xóa bình luận: ${e.toString()}');
      return false;
    }
  }
}
