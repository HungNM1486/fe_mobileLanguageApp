import 'package:flutter/material.dart';
import 'package:language_app/models/post_model.dart';
import 'package:language_app/service/post_service.dart';
import 'package:language_app/utils/toast_helper.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'likes_list_page.dart';
import 'gallery_viewer.dart';
import 'widgets/forum_post_card.dart';

class TopicPage extends StatefulWidget {
  final String topic;

  const TopicPage({Key? key, required this.topic}) : super(key: key);

  @override
  State<TopicPage> createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage> {
  final PostService _postService = PostService();
  final ScrollController _scrollController = ScrollController();
  List<PostModel> _posts = [];
  Map<String, dynamic> _meta = {};
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  int _currentPage = 1;
  final int _limit = 10;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    // Khởi tạo locale tiếng Việt cho timeago
    timeago.setLocaleMessages('vi', timeago.ViMessages());

    // Tải bài viết khi khởi tạo
    _loadPosts();

    // Thêm listener để tải thêm khi cuộn đến cuối
    _scrollController.addListener(_scrollListener);
  }

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
      _loadMorePosts();
    }
  }

  // Tải bài viết theo hashtag
  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final result = await _postService.getPostsByTag(widget.topic,
          page: 1, limit: _limit);

      setState(() {
        _posts = result['posts'];
        _meta = result['meta'];
        _isLoading = false;
        _currentPage = 1;

        // Kiểm tra nếu có thêm dữ liệu
        final totalItems = _meta['totalItems'] ?? 0;
        _hasMore = _posts.length < totalItems;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  // Tải thêm bài viết
  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final result = await _postService.getPostsByTag(widget.topic,
          page: _currentPage + 1, limit: _limit);

      final newPosts = result['posts'] as List<PostModel>;

      setState(() {
        _posts.addAll(newPosts);
        _meta = result['meta'];
        _currentPage++;
        _isLoadingMore = false;

        // Kiểm tra nếu còn dữ liệu
        final totalItems = _meta['totalItems'] ?? 0;
        _hasMore = _posts.length < totalItems;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  // Làm mới dữ liệu
  Future<void> _refreshData() async {
    await _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '#${widget.topic}',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _hasError
              ? _buildErrorState()
              : _posts.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _refreshData,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                Text(
                                  '${_meta['totalItems'] ?? 0} bài viết',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: _posts.length + (_hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _posts.length) {
                                  return _buildLoadMoreIndicator();
                                }
                                return _buildPostCard(_posts[index]);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  // Widget hiển thị một bài viết
  Widget _buildPostCard(PostModel post) {
    return ForumPostCard(
      post: post,
      expandable: true,
      onPostDeleted: () {
        _refreshData(); // Làm mới dữ liệu khi xóa bài
      },
      onImageTap: (imageUrls, initialIndex) {
        _openGallery(imageUrls, initialIndex);
      },
      onLikesViewTap: (post) {
        if ((post.likes?.length ?? 0) > 0) {
          ToastHelper.showInfo(
              context, 'Xem ${post.likes?.length} người đã thích bài viết');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LikesListPage(post: post),
            ),
          );
        }
      },
    );
  }

  // Mở gallery xem ảnh
  void _openGallery(List<String> imageUrls, int initialIndex) {
    // Hiển thị thông báo hướng dẫn
    ToastHelper.showInfo(
        context, 'Vuốt để xem ảnh khác, chạm để đóng/mở điều khiển');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModernGallery(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  // Widget hiển thị trạng thái đang tải ban đầu
  Widget _buildLoadingState() {
    return Center(
      child: SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  // Widget hiển thị khi có lỗi
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 40, color: Colors.red[300]),
          const SizedBox(height: 12),
          const Text(
            'Đã xảy ra lỗi khi tải dữ liệu',
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _loadPosts,
            icon: Icon(Icons.refresh, size: 16),
            label: Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị khi không có bài viết
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Không tìm thấy bài viết nào với hashtag #${widget.topic}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị chỉ báo đang tải thêm
  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
