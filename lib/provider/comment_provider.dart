import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:language_app/models/comment_model.dart';
import 'package:language_app/utils/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommentProvider with ChangeNotifier {
  final String baseUrl = UrlUtils.getBaseUrl();
  List<CommentModel> _comments = [];
  CommentModel? _commentDetail;
  bool _isLoading = false;

  List<CommentModel> get comments => _comments;
  CommentModel? get commentDetail => _commentDetail;
  bool get isLoading => _isLoading;

  final Dio _dio = Dio()
    ..interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

  // Lấy tất cả bình luận
  Future<bool> fetchAllComments() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse("${baseUrl}post-comments");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> commentsData = data['data'];

        _comments = commentsData
            .map((e) {
              try {
                return CommentModel.fromJson(e);
              } catch (parseError) {
                debugPrint('Lỗi khi phân tích bình luận: $parseError');
                return null;
              }
            })
            .whereType<CommentModel>()
            .toList();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error fetching all comments: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Lấy bình luận theo bài viết
  Future<bool> fetchCommentsByPostId(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    _isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse("${baseUrl}post-comments/post/$postId");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token != null ? 'Bearer $token' : '',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> commentsData = data['data'];

        _comments = commentsData
            .map((e) {
              try {
                return CommentModel.fromJson(e);
              } catch (parseError) {
                debugPrint(
                    'Lỗi khi phân tích bình luận của bài viết: $parseError');
                return null;
              }
            })
            .whereType<CommentModel>()
            .toList();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error fetching comments by post ID: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Lấy chi tiết bình luận
  Future<bool> getCommentDetail(int commentId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    _isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse("${baseUrl}post-comments/$commentId");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token != null ? 'Bearer $token' : '',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _commentDetail = CommentModel.fromJson(data['data']);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error fetching comment detail: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Tạo bình luận mới
  Future<CommentModel?> createComment(int postId, String content) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return null;
    }

    try {
      final response = await _dio.post(
        '${baseUrl}post-comments',
        data: {
          'postId': postId,
          'content': content,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newCommentData = response.data['data'];
        if (newCommentData != null) {
          final newComment = CommentModel.fromJson(newCommentData);
          // Thêm comment mới vào danh sách
          _comments.add(newComment);
          notifyListeners();
          return newComment;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error creating comment: $e');
      return null;
    }
  }

  // Cập nhật bình luận
  Future<bool> updateComment(int commentId, String content) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }

    try {
      final response = await _dio.patch(
        '${baseUrl}post-comments/$commentId',
        data: {
          'content': content,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Cập nhật bình luận trong danh sách
        final updatedCommentData = response.data['data'];
        if (updatedCommentData != null) {
          final updatedComment = CommentModel.fromJson(updatedCommentData);
          final index =
              _comments.indexWhere((c) => c.id == commentId.toString());
          if (index != -1) {
            _comments[index] = updatedComment;
            notifyListeners();
          }

          // Cập nhật commentDetail nếu đang xem
          if (_commentDetail?.id == commentId.toString()) {
            _commentDetail = updatedComment;
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating comment: $e');
      return false;
    }
  }

  // Xóa bình luận
  Future<bool> deleteComment(int commentId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }

    try {
      final response = await _dio.delete(
        '${baseUrl}post-comments/$commentId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Xóa bình luận khỏi danh sách
        _comments.removeWhere((c) => c.id == commentId.toString());
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting comment: $e');
      return false;
    }
  }
}
