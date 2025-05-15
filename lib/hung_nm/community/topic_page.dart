import 'package:flutter/material.dart';
import 'package:language_app/models/post_model.dart';
import 'package:language_app/service/post_service.dart';
import 'forum_detail_page.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';

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
  bool _isFollowing = false;

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ForumDetailPage(post: post)),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phần header với avatar và tên người dùng
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey[200],
                    backgroundImage:
                        post.userAvatar != null && post.userAvatar!.isNotEmpty
                            ? NetworkImage(post.userAvatar!)
                            : null,
                    child: post.userAvatar == null || post.userAvatar!.isEmpty
                        ? Text(
                            (post.userName ?? 'U')
                                .substring(0, 1)
                                .toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.userName ?? 'Người dùng ẩn danh',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          post.createdAt != null
                              ? timeago.format(post.createdAt!, locale: 'vi')
                              : '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Tiêu đề bài viết
              Text(
                post.title ?? 'Không có tiêu đề',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 6),

              // Nội dung bài viết
              Text(
                post.content ?? 'Không có nội dung',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Hình ảnh bài viết (nếu có)
              if (post.imageUrls != null && post.imageUrls!.isNotEmpty) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: post.imageUrls!.first,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      height: 140,
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      height: 140,
                      child: Icon(Icons.error, color: Colors.grey[500]),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 10),

              // Footer với thông tin like, comment
              Row(
                children: [
                  Icon(Icons.favorite, color: Colors.pink, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${post.likes?.length ?? 0}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.comment, color: Colors.blue, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${post.comments?.length ?? 0}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
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
