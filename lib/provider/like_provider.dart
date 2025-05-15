import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:language_app/models/like_model.dart';
import 'package:language_app/utils/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LikeProvider with ChangeNotifier {
  final String baseUrl = UrlUtils.getBaseUrl();
  List<LikeModel> _likes = [];
  LikeModel? _likeDetail;
  bool _isLoading = false;

  List<LikeModel> get likes => _likes;
  LikeModel? get likeDetail => _likeDetail;
  bool get isLoading => _isLoading;

  final Dio _dio = Dio()
    ..interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

  // Lấy tất cả lượt thích
  Future<bool> fetchAllLikes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse("${baseUrl}post-likes");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> likesData = data['data'];

        _likes = likesData
            .map((e) {
              try {
                return LikeModel.fromJson(e);
              } catch (parseError) {
                debugPrint('Lỗi khi phân tích lượt thích: $parseError');
                return null;
              }
            })
            .whereType<LikeModel>()
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
      debugPrint('Error fetching all likes: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Lấy chi tiết lượt thích
  Future<bool> getLikeDetail(int likeId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse("${baseUrl}post-likes/$likeId");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _likeDetail = LikeModel.fromJson(data['data']);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error fetching like detail: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Thích bài viết
  Future<LikeModel?> likePost(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return null;
    }

    try {
      final response = await _dio.post(
        '${baseUrl}post-likes',
        data: {
          'postId': postId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final likeModel = LikeModel.fromJson(response.data);
        _likes.add(likeModel);
        notifyListeners();
        return likeModel;
      }
      return null;
    } catch (e) {
      debugPrint('Error liking post: $e');
      return null;
    }
  }

  // Xóa lượt thích
  Future<bool> deleteLike(int likeId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }

    try {
      final response = await _dio.delete(
        '${baseUrl}post-likes/$likeId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Xóa lượt thích khỏi danh sách
        _likes.removeWhere((like) => like.id == likeId.toString());
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting like: $e');
      return false;
    }
  }

  // Tìm kiếm lượt thích của người dùng hiện tại cho một bài viết
  Future<LikeModel?> findUserLikeForPost(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return null;
    }

    // Đảm bảo đã tải danh sách lượt thích
    if (_likes.isEmpty) {
      await fetchAllLikes();
    }

    // Lấy userId từ token hoặc SharedPreferences
    final userId = prefs.getString("userId");
    if (userId == null) {
      return null;
    }

    // Tìm lượt thích phù hợp
    try {
      final userLike = _likes.firstWhere(
        (like) => like.postId == postId.toString() && like.userId == userId,
      );
      return userLike;
    } catch (e) {
      // Nếu không tìm thấy, trả về null
      return null;
    }
  }

  // Bỏ thích bài viết (tiện ích)
  Future<bool> unlikePost(int postId) async {
    // Tìm lượt thích hiện tại
    final currentLike = await findUserLikeForPost(postId);
    if (currentLike != null) {
      // Nếu tìm thấy, xóa lượt thích
      return await deleteLike(int.parse(currentLike.id!));
    }
    return false;
  }
}
