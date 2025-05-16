import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:language_app/models/post_model.dart';
import 'package:language_app/phu_nv/widget/network_img.dart';
import 'package:language_app/provider/post_provider.dart';
import 'package:language_app/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../edit_post_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:language_app/utils/toast_helper.dart';
import 'package:language_app/provider/report_provider.dart';
import '../topic_page.dart';
import 'comment_section.dart';

class ForumPostCard extends StatefulWidget {
  const ForumPostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onPostDeleted,
    this.onImageTap,
    this.onLikesViewTap,
    this.expandable = false,
    this.showCommentsSection = false,
  });
  final PostModel post;
  final VoidCallback? onTap;
  final VoidCallback? onPostDeleted;
  final Function(List<String>, int)? onImageTap;
  final Function(PostModel)? onLikesViewTap;
  final bool expandable; // Có thể mở rộng để hiển thị comment section không
  final bool showCommentsSection; // Luôn hiển thị comment section không
  @override
  State<ForumPostCard> createState() => _ForumPostCardState();
}

class _ForumPostCardState extends State<ForumPostCard>
    with SingleTickerProviderStateMixin {
  bool _isLiking = false;
  bool _isExpanded = false; // Trạng thái mở rộng hiển thị comments
  final GlobalKey _commentSectionKey = GlobalKey();

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Thiết lập trạng thái hiển thị ban đầu
    _isExpanded = widget.showCommentsSection;

    // Thêm animation controller cho hiệu ứng tương tác
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _likePost() async {
    // Tránh double click
    if (_isLiking) return;

    // Phát hiệu ứng haptic
    HapticFeedback.mediumImpact();

    // Chạy animation scale trước khi thực hiện tác vụ
    _animController.forward().then((_) => _animController.reverse());

    setState(() {
      _isLiking = true;
    });

    try {
      final userId = Provider.of<UserProvider>(context, listen: false).user?.id;
      if (widget.post.likes!.any((like) => like.userId == userId)) {
        ToastHelper.showSuccess(context, 'Bạn đã thích bài viết này');
        setState(() {
          _isLiking = false;
        });
        return;
      }
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final success = await postProvider.likePost(int.parse(widget.post.id!));

      if (success) {
        setState(() {
          _isLiking = false;
        });

        ToastHelper.showSuccess(context, 'Đã thích bài viết');
      } else {
        ToastHelper.showError(context, 'Không thể thích bài viết');
        setState(() {
          _isLiking = false;
        });
      }
    } catch (e) {
      ToastHelper.showError(context, 'Lỗi: ${e.toString()}');
      setState(() {
        _isLiking = false;
      });
    }
  }

  void _editPost() {
    // Chuyển đến trang chỉnh sửa bài viết
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPostPage(post: widget.post),
      ),
    ).then((updated) {
      if (updated == true) {
        // Refresh post nếu cần
      }
    });
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc muốn xóa bài viết này không?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePost();
            },
            child: Text('Xóa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePost() async {
    // Hiển thị loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                ),
                SizedBox(height: 16),
                Text(
                  'Đang xóa bài viết...',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final success = await postProvider.deletePost(widget.post.id!);

      // Đóng loading overlay
      Navigator.pop(context);

      if (success) {
        // Hiển thị thông báo thành công
        ToastHelper.showSuccess(context, 'Đã xóa bài viết');

        // Notify parent widget
        if (widget.onPostDeleted != null) {
          widget.onPostDeleted!();
        }
      } else {
        ToastHelper.showError(context, 'Không thể xóa bài viết');
      }
    } catch (e) {
      // Đóng loading overlay
      Navigator.pop(context);
      ToastHelper.showError(context, 'Lỗi: ${e.toString()}');
    }
  }

  void _reportPost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[850]
              : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle indicator
              Container(
                margin: EdgeInsets.only(top: 12, bottom: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Báo cáo bài viết',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              _buildReportOption('spam', 'Nội dung không phù hợp', Icons.block),
              _buildReportOption(
                  'abuse', 'Spam hoặc quảng cáo', Icons.announcement),
              _buildReportOption(
                  'harassment', 'Thông tin sai lệch', Icons.error_outline),
              _buildReportOption('other', 'Lý do khác', Icons.more_horiz),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportOption(
      String reasonCode, String reasonText, IconData icon) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.redAccent),
      ),
      title: Text(reasonText, style: TextStyle(fontWeight: FontWeight.w500)),
      onTap: () async {
        Navigator.pop(context);

        // Hiển thị dialog nhập chi tiết báo cáo
        final description = await _showReportDescriptionDialog(reasonText);

        // Nếu người dùng đã nhập chi tiết hoặc hủy
        if (description != null) {
          // Hiển thị loading
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Đang gửi báo cáo...'),
                  ],
                ),
              ),
            ),
          );

          try {
            // Gọi API báo cáo bài viết
            final reportProvider =
                Provider.of<ReportProvider>(context, listen: false);
            final success = await reportProvider.createReport(
              postId: int.parse(widget.post.id!),
              reason: reasonCode,
              description: description,
            );

            // Đóng loading dialog
            Navigator.pop(context);

            if (success) {
              ToastHelper.showSuccess(context, 'Đã gửi báo cáo');
            } else {
              ToastHelper.showError(context, 'Không thể gửi báo cáo');
            }
          } catch (e) {
            // Đóng loading dialog
            Navigator.pop(context);
            ToastHelper.showError(context, 'Lỗi: ${e.toString()}');
          }
        }
      },
    );
  }

  Future<String?> _showReportDescriptionDialog(String reason) async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Báo cáo: $reason'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Mô tả chi tiết (tùy chọn)',
            hintText: 'Vui lòng nhập thêm chi tiết về vấn đề...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blueAccent, width: 2),
            ),
          ),
          maxLines: 3,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text('Gửi báo cáo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Màu chữ dựa trên dark mode
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    // Màu accent chính của app
    final accentColor =
        Color(0xFF5B6EF5); // Màu accent mới - xanh dương sinh động

    // Màu nhấn mạnh
    final emphasizeColor = Color(0xFFF86A6A); // Màu hồng/đỏ cho nhấn mạnh

    return Card(
      elevation: 4, // Tăng shadow cho hiệu ứng nổi
      margin: const EdgeInsets.only(bottom: 16, left: 12, right: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18), // Bo góc lớn hơn
      ),
      shadowColor: Colors.black.withOpacity(0.1), // Shadow mềm hơn
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: accentColor.withOpacity(0.1), // Màu splash khi nhấn
        highlightColor:
            accentColor.withOpacity(0.05), // Highlight khi nhấn và giữ
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            // Thêm gradient nhẹ cho card
            gradient: isDarkMode
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2A2D3E),
                      Color(0xFF252836),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Color(0xFFF8F9FF),
                    ],
                  ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author info and time
              Padding(
                padding: EdgeInsets.all(16 * pix), // Padding nhất quán
                child: Row(
                  children: [
                    // Avatar với border gradient
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [accentColor, Color(0xFF7D8EFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(2), // Border size
                      child: ClipOval(
                        child: (widget.post.userAvatar != null &&
                                widget.post.userAvatar!.isNotEmpty)
                            ? NetworkImageWidget(
                                url: widget.post.userAvatar!,
                                width: 46 * pix,
                                height: 46 * pix)
                            : NetworkImageWidget(
                                url:
                                    "https://static.vecteezy.com/system/resources/thumbnails/009/734/564/small_2x/default-avatar-profile-icon-of-social-media-user-vector.jpg",
                                width: 46 * pix,
                                height: 46 * pix),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Username với style hiện đại
                          Text(
                            widget.post.userName ?? 'Unknown',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: textColor,
                              letterSpacing:
                                  0.2, // Tăng letter spacing cho dễ đọc
                            ),
                          ),
                          const SizedBox(height: 3),
                          // Timestamp với icon
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded, // Icon rounded
                                size: 14,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                timeago.format(widget.post.createdAt!,
                                    locale: 'vi'),
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Menu với animation
                    Container(
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.grey[800]!.withOpacity(0.3)
                            : Colors.grey[100]!,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.more_vert),
                        splashRadius: 20,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                        onPressed: () {
                          // Phản hồi xúc giác
                          HapticFeedback.lightImpact();

                          // Lấy userId hiện tại để kiểm tra quyền
                          final currentUserId =
                              Provider.of<UserProvider>(context, listen: false)
                                  .user
                                  ?.id;
                          final isAuthor = widget.post.userId == currentUserId;

                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (context) => Container(
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.grey[850]
                                    : Colors.white,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset(0, -2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Handle
                                  Container(
                                    margin: EdgeInsets.only(top: 12, bottom: 8),
                                    height: 4,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),

                                  if (isAuthor) ...[
                                    // Nút sửa
                                    ListTile(
                                      leading: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: accentColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(Icons.edit,
                                            color: accentColor),
                                      ),
                                      title: Text(
                                        'Chỉnh sửa bài viết',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _editPost();
                                      },
                                    ),

                                    // Nút xóa
                                    ListTile(
                                      leading: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color:
                                              emphasizeColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(Icons.delete,
                                            color: emphasizeColor),
                                      ),
                                      title: Text(
                                        'Xóa bài viết',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          color: emphasizeColor,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _confirmDelete();
                                      },
                                    ),

                                    const Divider(indent: 16, endIndent: 16),
                                  ],

                                  // Nút báo cáo
                                  ListTile(
                                    leading: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.flag,
                                          color: Colors.orange),
                                    ),
                                    title: Text(
                                      'Báo cáo',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _reportPost();
                                    },
                                  ),

                                  SizedBox(height: 16),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Title with improved typography
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.post.title ?? 'No Title',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18, // Tăng font size
                    color: textColor,
                    height: 1.3, // Line height tốt hơn
                    letterSpacing: 0.2, // Tăng letter spacing
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Content preview with better readability
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  widget.post.content ?? 'No content available',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                    fontSize: 15,
                    height: 1.4, // Tăng line height
                    letterSpacing: 0.1,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Post image with improved presentation
              if (widget.post.imageUrls!.isNotEmpty)
                Container(
                  height: 200, // Tăng kích thước để nổi bật hình ảnh
                  width: double.infinity,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16), // Bo góc hình ảnh
                    child: widget.post.imageUrls?.length == 1
                        ? GestureDetector(
                            onTap: () {
                              if (widget.onImageTap != null) {
                                widget.onImageTap!(widget.post.imageUrls!, 0);
                              }
                            },
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Hiệu ứng shimmer khi loading
                                Shimmer.fromColors(
                                  baseColor: isDarkMode
                                      ? Colors.grey[800]!
                                      : Colors.grey[300]!,
                                  highlightColor: isDarkMode
                                      ? Colors.grey[700]!
                                      : Colors.grey[100]!,
                                  child: Container(
                                    color: Colors.white,
                                  ),
                                ),
                                // Hình ảnh chính
                                CachedNetworkImage(
                                  imageUrl: widget.post.imageUrls!.first,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      SizedBox.shrink(),
                                  errorWidget: (context, url, error) => Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.error,
                                            color: Colors.grey[400], size: 32),
                                        SizedBox(height: 8),
                                        Text(
                                          'Không thể tải hình ảnh',
                                          style: TextStyle(
                                              color: Colors.grey[500]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.post.imageUrls?.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 180, // Điều chỉnh chiều rộng
                                  margin: const EdgeInsets.only(right: 12),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (widget.onImageTap != null) {
                                        widget.onImageTap!(
                                            widget.post.imageUrls!, index);
                                      }
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          // Shimmer effect
                                          Shimmer.fromColors(
                                            baseColor: isDarkMode
                                                ? Colors.grey[800]!
                                                : Colors.grey[300]!,
                                            highlightColor: isDarkMode
                                                ? Colors.grey[700]!
                                                : Colors.grey[100]!,
                                            child: Container(
                                              color: Colors.white,
                                            ),
                                          ),
                                          // Actual image
                                          CachedNetworkImage(
                                            imageUrl:
                                                widget.post.imageUrls![index],
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                SizedBox.shrink(),
                                            errorWidget:
                                                (context, url, error) => Icon(
                                                    Icons.error,
                                                    color: Colors.grey[400]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ),

              // Topics/tags with improved style
              if (widget.post.tags!.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.post.tags!.map((topic) {
                      return InkWell(
                        onTap: () {
                          // Điều hướng đến TopicPage khi nhấn vào tag
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TopicPage(topic: topic),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            // Gradient cho hashtag
                            gradient: LinearGradient(
                              colors: [
                                accentColor.withOpacity(0.7),
                                accentColor,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withOpacity(0.2),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '#$topic',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // Interaction buttons with improved style
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Like button with animation
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        // Lấy user id để kiểm tra đã like chưa
                        final userId =
                            Provider.of<UserProvider>(context, listen: false)
                                .user
                                ?.id;
                        final isLiked = widget.post.likes!
                            .any((like) => like.userId == userId);

                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: TextButton.icon(
                            onPressed: _likePost,
                            icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 20,
                              color: isLiked
                                  ? emphasizeColor
                                  : isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[700],
                            ),
                            label: Text(
                              widget.post.likes!.length.toString(),
                              style: TextStyle(
                                color: isLiked
                                    ? emphasizeColor
                                    : isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              backgroundColor: isLiked
                                  ? emphasizeColor.withOpacity(0.1)
                                  : isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(width: 8),

                    // Comment button with improved style
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                        // Phát haptic feedback khi nhấn
                        HapticFeedback.mediumImpact();
                      },
                      icon: Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 18,
                        color: _isExpanded
                            ? accentColor
                            : (isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[700]),
                      ),
                      label: Text(
                        widget.post.comments!.length.toString(),
                        style: TextStyle(
                          color: _isExpanded
                              ? accentColor
                              : (isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[700]),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        backgroundColor: _isExpanded
                            ? accentColor.withOpacity(0.1)
                            : (isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[200]),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    // Nút xem người thích bài viết
                    if (widget.post.likes!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: TextButton.icon(
                          onPressed: () {
                            if (widget.onLikesViewTap != null) {
                              widget.onLikesViewTap!(widget.post);
                            }
                          },
                          icon: Icon(
                            Icons.people_outline_rounded,
                            size: 18,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[700],
                          ),
                          label: Text(
                            'Xem',
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            backgroundColor: isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),

                    Spacer(),

                    // Language indicator (thêm mới)
                    if (widget.post.languageId != null)
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accentColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.language,
                              size: 14,
                              color: accentColor,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Tiếng Anh', // Hoặc tên ngôn ngữ thực tế từ widget.post
                              style: TextStyle(
                                fontSize: 12,
                                color: accentColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Comment section với hiệu ứng xuất hiện và biến mất trơn tru
              AnimatedCrossFade(
                firstChild: SizedBox.shrink(),
                secondChild: CommentSection(
                  postId: widget.post.id!,
                  key: _commentSectionKey,
                ),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: Duration(milliseconds: 300),
                firstCurve: Curves.easeOut,
                secondCurve: Curves.easeIn,
                sizeCurve: Curves.easeInOut,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Phương thức public để làm mới comments
  void refreshComments() {
    if (_commentSectionKey.currentState != null) {
      // Sử dụng dynamic để tránh lỗi kiểu dữ liệu
      final state = _commentSectionKey.currentState;
      if (state != null) {
        (state as dynamic).refreshComments();
      }
    }
  }
}

// ForumPostSkeleton được giữ nguyên nhưng cải tiến
class ForumPostSkeleton extends StatelessWidget {
  const ForumPostSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16, left: 12, right: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Shimmer.fromColors(
        baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author row
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Author name
                        Container(
                          width: 140,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Time
                        Container(
                          width: 80,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // More button
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title
              Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),

              // Content lines
              Container(
                width: double.infinity,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 200,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const SizedBox(height: 16),

              // Image placeholder
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),

              const SizedBox(height: 16),

              // Tags
              Row(
                children: List.generate(
                  3,
                  (index) => Container(
                    width: 60 + index * 10,
                    height: 24,
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 70,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
