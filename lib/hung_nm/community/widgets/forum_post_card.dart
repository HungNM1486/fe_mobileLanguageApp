import 'package:flutter/material.dart';
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

class ForumPostCard extends StatefulWidget {
  const ForumPostCard({
    super.key,
    required this.post,
    required this.onTap,
    this.onPostDeleted,
  });
  final PostModel post;
  final VoidCallback onTap;
  final VoidCallback? onPostDeleted;
  @override
  State<ForumPostCard> createState() => _ForumPostCardState();
}

class _ForumPostCardState extends State<ForumPostCard> {
  bool _isLiking = false;
  @override
  void initState() {
    super.initState();
  }

  Future<void> _likePost() async {
    // Tránh double click
    if (_isLiking) return;

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
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xóa bài viết này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePost();
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
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
        return const Center(child: CircularProgressIndicator());
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
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Báo cáo bài viết',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              _buildReportOption('spam', 'Nội dung không phù hợp'),
              _buildReportOption('abuse', 'Spam hoặc quảng cáo'),
              _buildReportOption('harassment', 'Thông tin sai lệch'),
              _buildReportOption('other', 'Lý do khác'),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportOption(String reasonCode, String reasonText) {
    return ListTile(
      title: Text(reasonText),
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
            builder: (context) => Center(child: CircularProgressIndicator()),
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
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text('Gửi báo cáo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author info and time
            Padding(
              padding: EdgeInsets.all(12 * pix),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    child: ClipOval(
                        child: (widget.post.userAvatar != null &&
                                widget.post.userAvatar!.isNotEmpty)
                            ? NetworkImageWidget(
                                url: widget.post.userAvatar!,
                                width: 40 * pix,
                                height: 40 * pix)
                            : NetworkImageWidget(
                                url:
                                    "https://static.vecteezy.com/system/resources/thumbnails/009/734/564/small_2x/default-avatar-profile-icon-of-social-media-user-vector.jpg",
                                width: 40 * pix,
                                height: 40 * pix)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.userName ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timeago.format(widget.post.createdAt!, locale: 'vi'),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // Lấy userId hiện tại để kiểm tra quyền
                      final currentUserId =
                          Provider.of<UserProvider>(context, listen: false)
                              .user
                              ?.id;
                      final isAuthor = widget.post.userId == currentUserId;

                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isAuthor) ...[
                              ListTile(
                                leading: const Icon(Icons.edit),
                                title: const Text('Chỉnh sửa bài viết'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _editPost();
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.delete),
                                title: const Text('Xóa bài viết'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _confirmDelete();
                                },
                              ),
                              const Divider(),
                            ],
                            ListTile(
                              leading: const Icon(Icons.flag),
                              title: const Text('Báo cáo'),
                              onTap: () {
                                Navigator.pop(context);
                                _reportPost();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                widget.post.title ?? 'No Title',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Content preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                widget.post.content ?? 'No content available',
                style: TextStyle(color: Colors.grey.shade800),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Post image (if any)
            if (widget.post.imageUrls!.isNotEmpty)
              Container(
                height: 180,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: widget.post.imageUrls?.length == 1
                    ? CachedNetworkImage(
                        imageUrl: widget.post.imageUrls!.first,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.post.imageUrls?.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 160,
                            margin: const EdgeInsets.only(left: 8),
                            child: CachedNetworkImage(
                              imageUrl: widget.post.imageUrls![index],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          );
                        },
                      ),
              ),

            // Topics/tags
            if (widget.post.tags!.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: widget.post.tags!.map((topic) {
                    return InkWell(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '#$topic',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            // Interaction buttons
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  _isLiking
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                            strokeWidth: 2,
                          ),
                        )
                      : TextButton.icon(
                          onPressed: () {
                            _likePost();
                          },
                          icon: Icon(
                            Icons.thumb_up_outlined,
                            size: 18,
                            color: Colors.grey.shade700,
                          ),
                          label: Text(
                            widget.post.likes!.length.toString(),
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                  // Comment button
                  TextButton.icon(
                    onPressed: widget.onTap,
                    icon: Icon(
                      Icons.chat_bubble_outline,
                      size: 18,
                      color: Colors.grey.shade700,
                    ),
                    label: Text(
                      widget.post.comments!.length.toString(),
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ForumPostSkeleton extends StatelessWidget {
  const ForumPostSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author row
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
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
                          width: 120,
                          height: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        // Time
                        Container(
                          width: 80,
                          height: 10,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Title
              Container(
                width: double.infinity,
                height: 16,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              // Content preview
              Container(
                width: double.infinity,
                height: 12,
                color: Colors.white,
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                height: 12,
                color: Colors.white,
              ),
              const SizedBox(height: 4),
              Container(
                width: 200,
                height: 12,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              // Action row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  3,
                  (index) => Container(
                    width: 60,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
