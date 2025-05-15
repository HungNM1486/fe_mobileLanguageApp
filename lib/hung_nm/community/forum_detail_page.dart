import 'package:flutter/services.dart';
import 'package:language_app/models/post_model.dart';
import 'package:language_app/phu_nv/widget/network_img.dart';
import 'package:language_app/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:language_app/provider/post_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shimmer/shimmer.dart';
import 'topic_page.dart';
import 'package:flutter/material.dart';
import 'widgets/comment_section.dart';
import 'likes_list_page.dart';

class ForumDetailPage extends StatefulWidget {
  final PostModel post;

  const ForumDetailPage({Key? key, required this.post}) : super(key: key);

  @override
  State<ForumDetailPage> createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  bool _isLiking = false;
  int _currentImageIndex = 0;
  bool _isDeleting = false;
  final commentSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Khởi tạo locale tiếng Việt cho timeago
    timeago.setLocaleMessages('vi', timeago.ViMessages());

    // Khởi tạo animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Load chi tiết bài viết
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      postProvider.getPostDetail(int.parse(widget.post.id!));

      // Thiết lập status bar
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ));
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Like bài viết
  Future<void> _likePost() async {
    if (_isLiking) return;

    setState(() {
      _isLiking = true;
    });

    try {
      final userId = Provider.of<UserProvider>(context, listen: false).user?.id;
      if (widget.post.likes!.any((like) => like.userId == userId)) {
        _showSnackBar('Bạn đã thích bài viết này');
        setState(() {
          _isLiking = false;
        });
        return;
      }

      // Phát hiệu ứng haptic feedback
      HapticFeedback.lightImpact();

      // Animation cho nút like
      _animationController.reset();
      _animationController.forward();

      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final success = await postProvider.likePost(int.parse(widget.post.id!));

      if (success) {
        setState(() {
          _isLiking = false;
        });
        _showSnackBar('Đã thích bài viết');
      } else {
        _showSnackBar('Không thể thích bài viết', isError: true);
        setState(() {
          _isLiking = false;
        });
      }
    } catch (e) {
      _showSnackBar('Lỗi: ${e.toString()}', isError: true);
      setState(() {
        _isLiking = false;
      });
    }
  }

  // Chuyển hướng đến trang chủ đề
  void _navigateToTopic(String topic) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TopicPage(topic: topic)),
    );
  }

  // Hiển thị SnackBar được thiết kế lại
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        elevation: 4,
      ),
    );
  }

  // Phương thức xóa ảnh trong bài viết
  void _deletePostImage(String imageUrl) async {
    // Hiển thị hộp thoại xác nhận
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa ảnh này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        setState(() {
          _isDeleting = true;
        });

        final postProvider = Provider.of<PostProvider>(context, listen: false);
        final success =
            await postProvider.deletePostImage(widget.post.id!, imageUrl);

        if (success) {
          // Cập nhật lại thông tin bài viết
          await postProvider.getPostDetail(int.parse(widget.post.id!));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã xóa ảnh thành công')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể xóa ảnh, vui lòng thử lại sau')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isDeleting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Lắng nghe sự thay đổi từ PostProvider
    return Consumer<PostProvider>(
      builder: (context, postProvider, child) {
        if (postProvider.isLoading) {
          return Scaffold(
            body: _buildLoadingShimmer(isDarkMode),
          );
        }

        final post = postProvider.postDetail;
        if (post == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Chi tiết bài viết'),
              elevation: 0,
            ),
            body: const Center(
              child: Text('Không thể tải bài viết. Vui lòng thử lại sau.'),
            ),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 0,
                    floating: false,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: Colors.white,
                    centerTitle: true,
                    title: Text(
                      "Chi tiết bài viết",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'BeVietnamPro',
                      ),
                    ),
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [],
                  ),
                ];
              },
              body: RefreshIndicator(
                onRefresh: () async {
                  await postProvider.getPostDetail(int.parse(post.id!));
                  // Làm mới CommentSection nếu widget đã được tạo
                  if (commentSectionKey.currentState != null) {
                    // Sử dụng dynamic để tránh lỗi kiểu dữ liệu
                    final state = commentSectionKey.currentState;
                    if (state != null) {
                      (state as dynamic).refreshComments();
                    }
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card chứa thông tin tác giả và nội dung
                      Card(
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        color: isDarkMode ? Colors.grey[900] : Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thông tin tác giả
                            _buildAuthorInfo(post, pix, isDarkMode),

                            // Tiêu đề bài viết
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Text(
                                post.title ?? "Chi tiết bài viết",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                  fontFamily: 'BeVietnamPro',
                                ),
                              ),
                            ),

                            // Nội dung bài viết
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Text(
                                post.content ?? "",
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                  fontFamily: 'BeVietnamPro',
                                ),
                              ),
                            ),

                            // Danh sách hình ảnh
                            _buildImageGallery(post, isDarkMode),

                            // Chủ đề
                            _buildTopicChips(post, isDarkMode),

                            // Tương tác (likes, comments)
                            _buildInteractionBar(post, isDarkMode),
                          ],
                        ),
                      ),

                      // Khoảng cách giữa card và phần bình luận
                      const SizedBox(height: 8),

                      // Phần bình luận
                      CommentSection(
                        key: commentSectionKey,
                        postId: widget.post.id ?? '0',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget hiển thị loading với hiệu ứng shimmer
  Widget _buildLoadingShimmer(bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AppBar skeleton
            Container(
              height: 200,
              color: Colors.white,
            ),

            // Author info skeleton
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and timestamp
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 80,
                        height: 12,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                    5,
                    (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            width: double.infinity,
                            height: 14,
                            color: Colors.white,
                          ),
                        )),
              ),
            ),

            // Image gallery skeleton
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Container(
                    width: 150,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Comments section skeleton
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: 100,
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),

                  // Comments
                  ...List.generate(
                      3,
                      (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Comment content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        width: double.infinity,
                                        height: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        width: 70,
                                        height: 12,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị thông tin tác giả
  Widget _buildAuthorInfo(PostModel post, double pix, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar
          ClipOval(
            child: Container(
              width: 50 * pix,
              height: 50 * pix,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[300]!, Colors.blue[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: (post.userAvatar != null && post.userAvatar != "")
                  ? NetworkImageWidget(
                      url: post.userAvatar!,
                      width: 50 * pix,
                      height: 50 * pix,
                    )
                  : NetworkImageWidget(
                      url:
                          "https://static.vecteezy.com/system/resources/thumbnails/009/734/564/small_2x/default-avatar-profile-icon-of-social-media-user-vector.jpg",
                      width: 50 * pix,
                      height: 50 * pix,
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Tên người dùng và thời gian
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.userName ?? 'Người dùng ẩn danh',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontFamily: 'BeVietnamPro',
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      post.createdAt != null
                          ? timeago.format(post.createdAt ?? DateTime.now(),
                              locale: 'vi')
                          : 'Thời gian không xác định',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontFamily: 'BeVietnamPro',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị gallery hình ảnh
  Widget _buildImageGallery(PostModel post, bool isDarkMode) {
    if (post.imageUrls == null || post.imageUrls!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Chỉ hiển thị nút xóa khi bài viết thuộc về người dùng hiện tại
    final userId = Provider.of<UserProvider>(context, listen: false).user?.id;
    final isOwner = post.userId == userId;

    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: post.imageUrls!.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  // Ảnh có thể nhấn để xem toàn màn hình
                  GestureDetector(
                    onTap: () => _openGallery(post.imageUrls!, index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(post.imageUrls![index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // Nút xóa ảnh (chỉ hiển thị cho người sở hữu bài viết)
                  if (isOwner)
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: _isDeleting
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(Icons.delete, color: Colors.white),
                          onPressed: _isDeleting
                              ? null
                              : () => _deletePostImage(post.imageUrls![index]),
                          iconSize: 20,
                          padding: EdgeInsets.all(8),
                          constraints: BoxConstraints(),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Mở gallery xem ảnh toàn màn hình
  void _openGallery(List<String> imageUrls, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenGallery(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  // Widget hiển thị các topics (chủ đề)
  Widget _buildTopicChips(PostModel post, bool isDarkMode) {
    if (post.tags == null || post.tags!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: post.tags!
            .map((topic) => GestureDetector(
                  onTap: () => _navigateToTopic(topic),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.blueAccent.withOpacity(0.15)
                          : Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.blueAccent.withOpacity(0.5)
                            : Colors.blue[200]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tag,
                          size: 16,
                          color:
                              isDarkMode ? Colors.blue[300] : Colors.blue[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          topic,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode
                                ? Colors.blue[300]
                                : Colors.blue[700],
                            fontFamily: 'BeVietnamPro',
                          ),
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  // Widget hiển thị thanh tương tác (like, comment)
  Widget _buildInteractionBar(PostModel post, bool isDarkMode) {
    final userId = Provider.of<UserProvider>(context, listen: false).user?.id;
    final isLiked =
        post.likes != null && post.likes!.any((like) => like.userId == userId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Like button
          GestureDetector(
            onTap: _likePost,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isLiked
                    ? (isDarkMode
                        ? Colors.pink.withOpacity(0.2)
                        : Colors.pink[50] ?? Colors.pink.withOpacity(0.1))
                    : (isDarkMode
                        ? Colors.grey.withOpacity(0.2)
                        : Colors.grey[100] ?? Colors.grey.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 1.5).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.elasticOut,
                      ),
                    ),
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked
                          ? Colors.pink
                          : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      // Chỉ mở danh sách khi có người thích
                      if ((post.likes?.length ?? 0) > 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LikesListPage(post: post),
                          ),
                        );
                      }
                    },
                    child: Text(
                      '${post.likes?.length ?? 0}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isLiked
                            ? Colors.pink
                            : (isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600]),
                        fontFamily: 'BeVietnamPro',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Comment button
          GestureDetector(
            onTap: () {
              // Cuộn đến phần bình luận
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.grey.withOpacity(0.2)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${post.comments?.length ?? 0}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontFamily: 'BeVietnamPro',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Lớp hiển thị gallery toàn màn hình
class FullScreenGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenGallery({
    Key? key,
    required this.imageUrls,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Gallery chính
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(widget.imageUrls[index]),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 2,
                heroAttributes: PhotoViewHeroAttributes(tag: 'image_$index'),
              );
            },
            itemCount: widget.imageUrls.length,
            loadingBuilder: (context, event) => Center(
              child: Container(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  value: event == null
                      ? 0
                      : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            pageController: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}
