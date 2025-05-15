import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:language_app/models/like_model.dart';
import 'package:language_app/models/post_model.dart';
import 'package:language_app/models/comment_model.dart';
import 'package:language_app/utils/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostProvider with ChangeNotifier {
  String baseUrl = UrlUtils.getBaseUrl();
  List<PostModel> _posts = [];
  PostModel? _postDetail;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<PostModel> get posts => _posts;
  PostModel? get postDetail => _postDetail;

  final Dio _dio = Dio()
    ..interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    )
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Sử dụng trực tiếp
          SharedPreferences.getInstance().then((prefs) {
            final token = prefs.getString("token");
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            handler.next(options);
          });
        },
      ),
    );

  String? _getAuthToken() {
    try {
      final prefs = SharedPreferences.getInstance().then((prefs) {
        return prefs.getString("token");
      });
      return prefs as String?;
    } catch (e) {
      print('Lỗi khi lấy token: $e');
      return null;
    }
  }

  Future<bool> createPost({
    required String title,
    required String content,
    required int languageId,
    List<String>? tags,
    List<File>? files,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }
    _isLoading = true;
    notifyListeners();

    try {
      // Tạo một Map để chứa dữ liệu
      final Map<String, dynamic> formDataMap = {
        'title': title,
        'content': content,
        'languageId': languageId,
      };

      // Thêm tags như một mảng nếu có
      if (tags != null && tags.isNotEmpty) {
        formDataMap['tags'] = tags; // Gửi trực tiếp là mảng
      }

      // Tạo FormData từ Map
      final formData = FormData.fromMap(formDataMap);

      // Add files if present
      if (files != null && files.isNotEmpty) {
        for (var i = 0; i < files.length; i++) {
          final file = files[i];
          final fileName = file.path.split('/').last;

          // Ensure correct file size
          final fileSize = await file.length();
          if (fileSize > 10 * 1024 * 1024) {
            // 10MB limit
            throw Exception(
                'File $fileName quá lớn (${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB). Vui lòng chọn file nhỏ hơn 10MB.');
          }

          formData.files.add(MapEntry(
            'files',
            await MultipartFile.fromFile(
              file.path,
              filename: fileName,
            ),
          ));
        }
      }

      final response = await _dio.post(
        '${baseUrl}posts',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Authorization': 'Bearer $token',
          },
          validateStatus: (status) {
            return status! < 500;
          },
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final postModel = PostModel.fromJson(data['data']);
        debugPrint('Bài viết đã tạo: $postModel');
        _posts.add(postModel);
        debugPrint('Danh sách bài viết sau khi thêm: $_posts');
        _isLoading = false;

        notifyListeners();
        return true;
      } else {
        _isLoading = false;

        // Get detailed error message from response
        var errorMessage = 'Lỗi không xác định';
        if (response.data != null && response.data is Map) {
          errorMessage = response.data['message'] ?? errorMessage;
        }

        debugPrint('Error creating post: $errorMessage');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;

      // Improved error handling
      String errorMessage = 'Đã xảy ra lỗi khi đăng bài viết';

      if (e is DioException) {
        if (e.response != null) {
          print('Response error data: ${e.response?.data}');
          errorMessage = 'Lỗi server: ${e.response?.statusCode}';

          if (e.response?.data is Map) {
            final errorData = e.response?.data as Map;
            if (errorData.containsKey('message')) {
              errorMessage = errorData['message'].toString();
            }
          }
        } else if (e.type == DioExceptionType.connectionTimeout) {
          errorMessage = 'Kết nối tới server quá lâu, vui lòng thử lại sau';
        } else if (e.type == DioExceptionType.sendTimeout) {
          errorMessage = 'Gửi dữ liệu quá lâu, vui lòng thử lại sau';
        }
      }

      debugPrint('Error creating post: $e');
      debugPrint('Error message: $errorMessage');
      notifyListeners();
      return false;
    }
  }

  Future<bool> fetchPosts({
    int? page,
    int? limit,
    int? languageId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      Map<String, String> queryParams = {};
      if (languageId != null) queryParams['languageId'] = languageId.toString();
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();

      // Xây dựng URL với query parameters
      final uri = Uri.parse("${baseUrl}posts").replace(
          queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        List<dynamic> postsData = data['data']['data'];

        List<PostModel> newPosts = postsData
            .map((e) {
              try {
                return PostModel.fromJson(e);
              } catch (parseError) {
                debugPrint('Lỗi khi phân tích bài đăng: $parseError');
                return null;
              }
            })
            .whereType<PostModel>()
            .toList();

        // Nếu đang tải trang > 1, thêm vào danh sách hiện tại
        if (page != null && page > 1) {
          _posts.addAll(newPosts);
        } else {
          // Nếu tải trang đầu tiên, thay thế danh sách cũ
          _posts = newPosts;
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Phương thức để thích bài viết và cập nhật UI
  Future<bool> likePost(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('Gửi yêu cầu thích bài viết ID: $postId');
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

      debugPrint('Kết quả thích bài viết: ${response.statusCode}');
      debugPrint('Dữ liệu phản hồi: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = response.data;
          LikeModel likeModel;

          if (data is Map<String, dynamic>) {
            // Trường hợp API trả về trực tiếp đối tượng like
            likeModel = LikeModel.fromJson(data);
          } else if (data['data'] != null) {
            // Trường hợp API trả về trong trường data
            likeModel = LikeModel.fromJson(data['data']);
          } else {
            // Tạo một like model mới nếu không có dữ liệu
            likeModel = LikeModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              postId: postId.toString(),
            );
          }

          // Cập nhật vào post detail nếu đang xem
          if (_postDetail != null && _postDetail!.id == postId.toString()) {
            if (_postDetail!.likes == null) {
              _postDetail!.likes = [];
            }
            _postDetail!.likes!.add(likeModel);
          }

          // Cập nhật vào danh sách posts
          for (var i = 0; i < _posts.length; i++) {
            if (_posts[i].id == postId.toString()) {
              if (_posts[i].likes == null) {
                _posts[i].likes = [];
              }
              _posts[i].likes!.add(likeModel);
              break;
            }
          }

          _isLoading = false;
          notifyListeners();
          return true;
        } catch (parseError) {
          debugPrint('Lỗi khi xử lý dữ liệu like: $parseError');
          _isLoading = false;
          notifyListeners();
          return true; // Vẫn trả về true vì API đã thành công
        }
      } else {
        _isLoading = false;
        notifyListeners();
        debugPrint('Error liking post: ${response.data}');
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error liking post: $e');
      return false;
    }
  }

  // Phương thức để thêm bình luận và cập nhật UI
  Future<bool> addComment(String postId, String content) async {
    try {
      print('Thêm bình luận cho bài viết $postId: $content');

      final response = await _dio.post('${baseUrl}post-comments',
          data: {'postId': int.parse(postId), 'content': content});

      print('Kết quả thêm bình luận: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Cập nhật lại chi tiết bài viết
        if (_postDetail != null) {
          await getPostDetail(int.parse(_postDetail!.id!));
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Lỗi khi thêm bình luận: $e');
      if (e is DioException) {
        print('DioError type: ${e.type}');
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
      return false;
    }
  }

  // Thêm bình luận tạm thời vào bài viết
  void addCommentToPost(int postId, CommentModel comment) {
    final index = _posts.indexWhere((post) => post.id == postId.toString());
    if (index != -1) {
      final updatedPosts = List<PostModel>.from(_posts);
      // Đảm bảo trường comments không null
      if (updatedPosts[index].comments == null) {
        updatedPosts[index].comments = [];
      }

      updatedPosts[index].comments!.add(comment);
      _posts = updatedPosts;
      notifyListeners();
    }
  }

  // Cập nhật bài viết trong danh sách
  void updatePostInList(PostModel updatedPost) {
    final index = _posts.indexWhere((post) => post.id == updatedPost.id);
    if (index != -1) {
      final updatedPosts = List<PostModel>.from(_posts);
      updatedPosts[index] = updatedPost;
      _posts = updatedPosts;
      notifyListeners();
    }
  }

  // Lấy chi tiết bài viết
  Future<bool> getPostDetail(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse("${baseUrl}posts/$postId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Chi tiết bài viết: ${data['data']}');
        final postModel = PostModel.fromJson(data['data']);
        print(
            'Chi tiết bài viết: ${postModel.toJson()}'); // In ra chi tiết bài viết
        _postDetail = postModel;
        _isLoading = false;
        notifyListeners();

        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error getting post detail: $e');
      return false;
    }
  }

  Future<bool> editPost({
    required String postId,
    required String title,
    required String content,
    List<String>? tags,
    List<String>? imagesToRemove,
    List<File>? newImages,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      print('Đang gửi yêu cầu editPost:');
      print('URL: ${baseUrl}posts/$postId');
      print('Dữ liệu: title=$title, content=$content');
      print('Tags: $tags');
      print('Hình ảnh cần xóa: $imagesToRemove');
      print('Số hình ảnh mới: ${newImages?.length ?? 0}');

      // Tạo FormData cho multipart/form-data
      final formData = FormData();

      // Thêm các trường dữ liệu cơ bản
      formData.fields.add(MapEntry('title', title));
      formData.fields.add(MapEntry('content', content));

      // Thêm tags nếu có (chuyển thành chuỗi ngăn cách bằng dấu phẩy)
      if (tags != null && tags.isNotEmpty) {
        formData.fields.add(MapEntry('tags', tags.join(',')));
      }

      // Thêm danh sách hình ảnh cần xóa nếu có
      if (imagesToRemove != null && imagesToRemove.isNotEmpty) {
        formData.fields
            .add(MapEntry('imagesToRemove', imagesToRemove.join(',')));
      }

      // Thêm các file hình ảnh mới nếu có
      if (newImages != null && newImages.isNotEmpty) {
        for (var i = 0; i < newImages.length; i++) {
          final file = newImages[i];
          final fileName = file.path.split('/').last;

          // Kiểm tra kích thước file
          final fileSize = await file.length();
          if (fileSize > 10 * 1024 * 1024) {
            // Giới hạn 10MB
            throw Exception(
                'File $fileName quá lớn (${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB). Vui lòng chọn file nhỏ hơn 10MB.');
          }

          formData.files.add(MapEntry(
            'files',
            await MultipartFile.fromFile(
              file.path,
              filename: fileName,
            ),
          ));
        }
      }

      // Sử dụng PATCH với multipart/form-data theo đúng API
      final response = await _dio.patch(
        '${baseUrl}posts/$postId',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
          validateStatus: (status) {
            return status! < 500; // Chấp nhận tất cả status code dưới 500
          },
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      print('Kết quả cập nhật: ${response.statusCode}');
      print('Dữ liệu phản hồi: ${response.data}');

      if (response.statusCode == 200) {
        try {
          if (response.data != null && response.data['data'] != null) {
            final updatedPost = PostModel.fromJson(response.data['data']);
            print(
                'Dữ liệu bài viết sau khi cập nhật: ${updatedPost.toString()}');

            // Cập nhật post trong danh sách
            final index = _posts.indexWhere((post) => post.id == postId);
            if (index != -1) {
              _posts[index] = updatedPost;
            }

            // Cập nhật post detail nếu đang xem
            if (_postDetail?.id == postId) {
              _postDetail = updatedPost;
            }
          } else {
            print('Dữ liệu phản hồi không có trường data');
          }
        } catch (parseError) {
          print('Lỗi khi xử lý dữ liệu phản hồi: $parseError');
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Chi tiết lỗi từ server
        var errorMessage = 'Lỗi không xác định';
        if (response.data != null && response.data is Map) {
          errorMessage = response.data['message'] ?? errorMessage;
        }
        print('Lỗi cập nhật bài viết: $errorMessage');

        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Lỗi chi tiết khi cập nhật bài viết: $e');
      if (e is DioException) {
        print('Response: ${e.response?.data}');
        print('Status code: ${e.response?.statusCode}');
        if (e.response?.data is Map) {
          print('Thông báo lỗi: ${e.response?.data['message']}');
        }
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePost(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Xóa tất cả likes liên quan đến bài viết trước
      final deleteLikesResponse = await _dio.delete(
        '${baseUrl}likes/post/$postId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // Tiếp tục xóa bài viết ngay cả khi việc xóa likes thất bại
      final response = await _dio.delete(
        '${baseUrl}posts/$postId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Xóa post khỏi danh sách
        _posts.removeWhere((post) => post.id == postId);

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Lỗi khi xóa bài viết: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Lấy bài viết phổ biến
  Future<bool> fetchPopularPosts({int limit = 10}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    _isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse("${baseUrl}posts/popular?limit=$limit");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token != null ? 'Bearer $token' : '',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Cập nhật đúng cấu trúc với dữ liệu trong data.data
        List<dynamic> postsData = data['data']['data'];

        _posts = postsData
            .map((e) {
              try {
                return PostModel.fromJson(e);
              } catch (parseError) {
                debugPrint('Lỗi khi phân tích bài đăng phổ biến: $parseError');
                return null;
              }
            })
            .whereType<PostModel>()
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
      debugPrint('Error fetching popular posts: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Lấy bài viết xu hướng
  Future<bool> fetchTrendingPosts({int days = 7, int limit = 10}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    _isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse("${baseUrl}posts/trending?days=$days&limit=$limit");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token != null ? 'Bearer $token' : '',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Cập nhật đúng cấu trúc với dữ liệu trong data.data
        List<dynamic> postsData = data['data']['data'];

        _posts = postsData
            .map((e) {
              try {
                return PostModel.fromJson(e);
              } catch (parseError) {
                debugPrint('Lỗi khi phân tích bài đăng xu hướng: $parseError');
                return null;
              }
            })
            .whereType<PostModel>()
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
      debugPrint('Error fetching trending posts: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Lấy bài viết của người dùng hiện tại
  Future<bool> fetchMyPosts({
    int page = 1,
    int limit = 10,
    String? title,
    String? tags,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (title != null) queryParams['title'] = title;
      if (tags != null) queryParams['tags'] = tags;

      final uri = Uri.parse("${baseUrl}posts/my-posts")
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> postsData = data['data']['data'];

        _posts = postsData
            .map((e) {
              try {
                return PostModel.fromJson(e);
              } catch (parseError) {
                debugPrint('Lỗi khi phân tích bài đăng cá nhân: $parseError');
                return null;
              }
            })
            .whereType<PostModel>()
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
      debugPrint('Error fetching my posts: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Xóa hình ảnh khỏi bài viết
  Future<bool> deletePostImage(String postId, String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return false;

    try {
      // Lấy tên file từ URL
      String encodedImageUrl = Uri.encodeComponent(imageUrl);

      final response = await _dio.delete(
        '${baseUrl}posts/$postId/images/$encodedImageUrl',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Cập nhật bài viết cục bộ nếu cần
        // Có thể gọi lại getPostDetail để cập nhật toàn bộ thông tin
        if (_postDetail != null && _postDetail!.id == postId) {
          getPostDetail(int.parse(postId));
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting post image: $e');
      return false;
    }
  }

  // Phương thức lấy tất cả bình luận
  Future<List<dynamic>> getAllComments() async {
    try {
      final response = await _dio.get('${baseUrl}post-comments');
      if (response.statusCode == 200) {
        return (response.data['data'] ?? []) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('Lỗi khi lấy tất cả bình luận: $e');
      return [];
    }
  }

  // Phương thức lấy bình luận theo bài viết
  Future<List<dynamic>> getCommentsByPost(String postId) async {
    try {
      final response = await _dio.get('${baseUrl}post-comments/post/$postId');
      if (response.statusCode == 200) {
        return (response.data['data'] ?? []) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('Lỗi khi lấy bình luận theo bài viết: $e');
      return [];
    }
  }

  // Phương thức lấy chi tiết bình luận
  Future<dynamic> getCommentDetail(String commentId) async {
    try {
      final response = await _dio.get('${baseUrl}post-comments/$commentId');
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy chi tiết bình luận: $e');
      return null;
    }
  }

  // Phương thức cập nhật bình luận
  Future<bool> updateComment(int commentId, String content) async {
    try {
      print('Cập nhật bình luận $commentId với nội dung: $content');

      final response = await _dio.patch(
        '${baseUrl}post-comments/$commentId',
        data: {'content': content},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Kết quả cập nhật bình luận: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Cập nhật lại chi tiết bài viết
        if (_postDetail != null) {
          await getPostDetail(int.parse(_postDetail!.id!));
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Lỗi khi cập nhật bình luận: $e');
      if (e is DioException) {
        print('DioError type: ${e.type}');
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
      return false;
    }
  }

  // Phương thức xóa bình luận
  Future<bool> deleteComment(int commentId) async {
    try {
      print('Xóa bình luận $commentId');

      final response = await _dio.delete(
        '${baseUrl}post-comments/$commentId',
      );

      print('Kết quả xóa bình luận: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Cập nhật lại chi tiết bài viết
        if (_postDetail != null) {
          await getPostDetail(int.parse(_postDetail!.id!));
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Lỗi khi xóa bình luận: $e');
      if (e is DioException) {
        print('DioError type: ${e.type}');
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
      return false;
    }
  }
}
