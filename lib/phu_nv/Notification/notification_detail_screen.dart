import 'package:flutter/material.dart';
import 'package:language_app/models/notification_model.dart';
import 'package:language_app/provider/post_provider.dart';
import 'package:language_app/hung_nm/community/widgets/forum_post_card.dart';
import 'package:language_app/hung_nm/community/gallery_viewer.dart';
import 'package:language_app/hung_nm/community/likes_list_page.dart';
import 'package:provider/provider.dart';

class NotificationDetailscreen extends StatefulWidget {
  final NotificationModel notification;

  const NotificationDetailscreen({Key? key, required this.notification})
      : super(key: key);

  @override
  State<NotificationDetailscreen> createState() =>
      _NotificationDetailscreenState();
}

class _NotificationDetailscreenState extends State<NotificationDetailscreen> {
  // Primary colors
  final Color _accentColor = Color(0xFF5B6EF5);
  final Color _secondaryColor = Color(0xFFF86A6A);

  // State variable for related post loading
  bool _isLoadingPost = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chi tiết thông báo",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: isDarkMode ? Color(0xFF0F0F23) : Colors.grey[50],
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: _buildNotificationContent(context, pix, isDarkMode),
        ),
      ),
    );
  }

  Widget _buildNotificationContent(
      BuildContext context, double pix, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with icon and title
        _buildHeader(pix, isDarkMode),
        SizedBox(height: 20 * pix),

        // Content card with details
        _buildContentCard(pix, isDarkMode),
        SizedBox(height: 20 * pix),

        // Additional info if present
        if (widget.notification.data != null &&
            widget.notification.data!.isNotEmpty)
          _buildAdditionalInfo(context, pix, isDarkMode),
        SizedBox(height: 16 * pix),

        // Action buttons
        _buildActionButtons(context, pix, isDarkMode),
      ],
    );
  }

  Widget _buildHeader(double pix, bool isDarkMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon container
        Container(
          padding: EdgeInsets.all(14 * pix),
          decoration: BoxDecoration(
            color: widget.notification.color,
            borderRadius: BorderRadius.circular(12 * pix),
          ),
          child: Icon(
            widget.notification.icon,
            color: Colors.white,
            size: 24 * pix,
          ),
        ),
        SizedBox(width: 16 * pix),

        // Title and timestamp
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.notification.title.isNotEmpty
                    ? widget.notification.title
                    : 'Không có tiêu đề',
                style: TextStyle(
                  fontSize: 18 * pix,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 8 * pix),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14 * pix,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                  ),
                  SizedBox(width: 6 * pix),
                  Text(
                    widget.notification.time,
                    style: TextStyle(
                      fontSize: 14 * pix,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentCard(double pix, bool isDarkMode) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12 * pix),
        side: BorderSide(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      color: isDarkMode ? Color(0xFF1A1E30) : Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16 * pix),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nội dung thông báo",
              style: TextStyle(
                fontSize: 16 * pix,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 12 * pix),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14 * pix),
              decoration: BoxDecoration(
                color: isDarkMode ? Color(0xFF252A40) : Colors.grey[50],
                borderRadius: BorderRadius.circular(10 * pix),
                border: Border.all(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Text(
                widget.notification.content.isNotEmpty
                    ? widget.notification.content
                    : 'Không có nội dung',
                style: TextStyle(
                  fontSize: 15 * pix,
                  height: 1.5,
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.9)
                      : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo(
      BuildContext context, double pix, bool isDarkMode) {
    if (widget.notification.data == null || widget.notification.data!.isEmpty) {
      return SizedBox();
    }

    // For comment notifications with postId, filter out postId from display
    Map<String, dynamic> dataToDisplay = Map.from(widget.notification.data!);

    if (widget.notification.type == 'comment' &&
        widget.notification.data!.containsKey('postId')) {
      dataToDisplay.remove('postId');

      if (dataToDisplay.isEmpty) {
        return SizedBox();
      }
    }

    List<Widget> infoWidgets = [];

    try {
      dataToDisplay.forEach((key, value) {
        // Format value for display
        String displayValue;
        if (value is String) {
          displayValue = value;
        } else if (value is num) {
          displayValue = value.toString();
        } else if (value is List) {
          displayValue = value.join(', ');
        } else if (value is Map) {
          displayValue = value.toString();
        } else {
          displayValue = value.toString();
        }

        infoWidgets.add(
          Container(
            margin: EdgeInsets.only(bottom: 10 * pix),
            padding: EdgeInsets.all(12 * pix),
            decoration: BoxDecoration(
              color: isDarkMode ? Color(0xFF252A40) : Colors.white,
              borderRadius: BorderRadius.circular(10 * pix),
              border: Border.all(
                color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _getIconForKey(key),
                  color: _accentColor,
                  size: 18 * pix,
                ),
                SizedBox(width: 12 * pix),

                // Key-value content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatKey(key),
                        style: TextStyle(
                          fontSize: 14 * pix,
                          fontWeight: FontWeight.w600,
                          color:
                              isDarkMode ? Colors.grey[300] : Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 6 * pix),
                      Text(
                        displayValue,
                        style: TextStyle(
                          fontSize: 15 * pix,
                          height: 1.4,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      });
    } catch (e) {
      debugPrint('Error processing notification.data: $e');
      return Text(
        'Không thể hiển thị thông tin bổ sung',
        style: TextStyle(
          fontSize: 15 * pix,
          color: _secondaryColor,
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12 * pix),
        side: BorderSide(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      color: isDarkMode ? Color(0xFF1A1E30) : Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16 * pix),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Thông tin thêm",
              style: TextStyle(
                fontSize: 16 * pix,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 12 * pix),
            ...infoWidgets,
          ],
        ),
      ),
    );
  }

  // Get appropriate icon for data keys
  IconData _getIconForKey(String key) {
    switch (key.toLowerCase()) {
      case 'userid':
      case 'user':
      case 'username':
        return Icons.person_rounded;
      case 'postid':
      case 'post':
        return Icons.article_rounded;
      case 'commentid':
      case 'comment':
        return Icons.chat_rounded;
      case 'date':
      case 'time':
      case 'created':
      case 'updated':
        return Icons.access_time_rounded;
      case 'status':
      case 'state':
        return Icons.info_rounded;
      case 'type':
      case 'category':
        return Icons.category_rounded;
      default:
        return Icons.label_rounded;
    }
  }

  // Format keys for better display
  String _formatKey(String key) {
    // Handle common key formats
    switch (key.toLowerCase()) {
      case 'userid':
        return 'ID Người dùng';
      case 'username':
        return 'Tên người dùng';
      case 'postid':
        return 'ID Bài viết';
      case 'commentid':
        return 'ID Bình luận';
      case 'created':
      case 'createdat':
        return 'Ngày tạo';
      case 'updated':
      case 'updatedat':
        return 'Ngày cập nhật';
      default:
        // Convert camelCase or snake_case to Title Case with spaces
        String formatted = key
            .replaceAllMapped(
                RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
            .replaceAll('_', ' ')
            .trim();

        // Capitalize first letter
        if (formatted.isNotEmpty) {
          formatted = formatted[0].toUpperCase() + formatted.substring(1);
        }

        return formatted;
    }
  }

  Widget _buildActionButtons(
      BuildContext context, double pix, bool isDarkMode) {
    // Check if this is a comment notification with postId
    if (widget.notification.type == 'comment' &&
        widget.notification.data != null &&
        widget.notification.data!.containsKey('postId')) {
      final postId = widget.notification.data!['postId'];
      return Center(
        child: ElevatedButton.icon(
          onPressed: () => _viewPost(context, postId, isDarkMode),
          icon: Icon(Icons.article_rounded),
          label: Text('Xem bài viết'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      );
    }

    // Check for other types of notifications with specific actions
    if (widget.notification.type == 'like' &&
        widget.notification.data != null &&
        widget.notification.data!.containsKey('postId')) {
      final postId = widget.notification.data!['postId'];
      return Center(
        child: ElevatedButton.icon(
          onPressed: () => _viewPost(context, postId, isDarkMode),
          icon: Icon(Icons.article_rounded),
          label: Text('Xem bài viết'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      );
    }

    // For notifications without specific actions, show a back button
    return Center(
      child: TextButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back),
        label: Text('Quay lại'),
        style: TextButton.styleFrom(
          foregroundColor: isDarkMode ? Colors.grey[400] : _accentColor,
        ),
      ),
    );
  }

  Future<void> _viewPost(
      BuildContext context, dynamic postId, bool isDarkMode) async {
    setState(() {
      _isLoadingPost = true;
    });

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_accentColor)),
      ),
    );

    try {
      // Fetch post details
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final success = await postProvider.getPostDetail(postId);

      // Close loading dialog
      Navigator.pop(context);

      if (success && postProvider.postDetail != null) {
        // Show bottom sheet with post
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: isDarkMode ? Color(0xFF0F0F23) : Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                AppBar(
                  title: Text('Bài viết'),
                  centerTitle: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: ForumPostCard(
                      post: postProvider.postDetail!,
                      expandable: true,
                      showCommentsSection: true,
                      onImageTap: (imageUrls, initialIndex) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ModernGallery(
                              imageUrls: imageUrls,
                              initialIndex: initialIndex,
                            ),
                          ),
                        );
                      },
                      onLikesViewTap: (post) {
                        if ((post.likes?.length ?? 0) > 0) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LikesListPage(post: post),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải bài viết'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: _secondaryColor,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog and show error
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi xảy ra: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _secondaryColor,
        ),
      );
    } finally {
      setState(() {
        _isLoadingPost = false;
      });
    }
  }
}
