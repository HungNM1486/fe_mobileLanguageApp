import 'package:flutter/material.dart';
import 'package:language_app/models/post_model.dart';
import 'package:language_app/service/post_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LikesListPage extends StatefulWidget {
  final PostModel post;

  const LikesListPage({Key? key, required this.post}) : super(key: key);

  @override
  State<LikesListPage> createState() => _LikesListPageState();
}

class _LikesListPageState extends State<LikesListPage> {
  final PostService _postService = PostService();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> _users = [];
  Map<String, dynamic> _meta = {};
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  int _currentPage = 1;
  final int _limit = 20;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _scrollController.addListener(_scrollListener);
  }

  // Hủy bỏ cuộn
  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // Theo dõi cuộn để tải thêm dữ liệu
  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMoreUsers();
    }
  }

  // Tải danh sách người dùng đã thích
  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final result = await _postService.getPostLikes(
        widget.post.id!,
        page: 1,
        limit: _limit,
      );

      setState(() {
        _users = result['users'] ?? [];
        _meta = Map<String, dynamic>.from(result['meta'] ?? {});
        _isLoading = false;
        _currentPage = 1;

        // Kiểm tra nếu có thêm dữ liệu
        final totalItems = _meta['totalItems'] ?? 0;
        _hasMore = _users.length < totalItems;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  // Tải thêm người dùng
  Future<void> _loadMoreUsers() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final result = await _postService.getPostLikes(
        widget.post.id!,
        page: _currentPage + 1,
        limit: _limit,
      );

      final newUsers = result['users'] as List<dynamic>? ?? [];

      setState(() {
        _users.addAll(newUsers);
        _meta = Map<String, dynamic>.from(result['meta'] ?? {});
        _currentPage++;
        _isLoadingMore = false;

        // Kiểm tra nếu còn dữ liệu
        final totalItems = _meta['totalItems'] ?? 0;
        _hasMore = _users.length < totalItems;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Người đã thích',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Đã xảy ra lỗi khi tải danh sách'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUsers,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return const Center(
        child: Text('Chưa có ai thích bài viết này'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _users.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _users.length) {
            return _buildLoadMoreIndicator();
          }
          return _buildUserItem(_users[index]);
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildUserItem(dynamic user) {
    if (user is! Map<String, dynamic>) {
      return const ListTile(
        title: Text('Thông tin người dùng không hợp lệ'),
      );
    }

    final String firstName = user['firstName'] ?? '';
    final String lastName = user['lastName'] ?? '';
    final String fullName = "$firstName $lastName";
    final String? profileImage = user['profileImageUrl'];
    final String email = user['email'] ?? '';

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: profileImage != null && profileImage.isNotEmpty
            ? CachedNetworkImageProvider(profileImage)
            : null,
        child: profileImage == null || profileImage.isEmpty
            ? const Icon(Icons.person)
            : null,
      ),
      title: Text(
        fullName.trim().isNotEmpty ? fullName : 'Người dùng ẩn danh',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: email.isNotEmpty ? Text(email) : null,
    );
  }
}
