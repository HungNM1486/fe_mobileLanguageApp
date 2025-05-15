import 'package:flutter/material.dart';
import 'package:language_app/models/post_model.dart';
import 'package:language_app/provider/post_provider.dart';
import 'package:language_app/utils/toast_helper.dart';
import 'package:provider/provider.dart';
import 'widgets/forum_post_card.dart';
import 'likes_list_page.dart';
import 'gallery_viewer.dart';

class InlineForumPost extends StatefulWidget {
  final PostModel post;

  const InlineForumPost({Key? key, required this.post}) : super(key: key);

  @override
  State<InlineForumPost> createState() => _InlineForumPostState();
}

class _InlineForumPostState extends State<InlineForumPost> {
  // Sử dụng GlobalKey không định kiểu cụ thể
  final GlobalKey _postCardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bài viết',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          final post = postProvider.postDetail ?? widget.post;

          return RefreshIndicator(
            onRefresh: () async {
              try {
                await postProvider.getPostDetail(int.parse(post.id!));
                // Làm mới comment section nếu widget đã được tạo
                if (_postCardKey.currentState != null) {
                  // Sử dụng dynamic để tránh lỗi kiểu dữ liệu
                  final state = _postCardKey.currentState;
                  if (state != null) {
                    (state as dynamic).refreshComments();
                  }
                }
                ToastHelper.showSuccess(context, 'Đã cập nhật bài viết');
              } catch (e) {
                ToastHelper.showError(context, 'Không thể cập nhật: $e');
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  ForumPostCard(
                    key: _postCardKey,
                    post: post,
                    expandable: true,
                    showCommentsSection: true,
                    onPostDeleted: () {
                      Navigator.pop(context);
                    },
                    onImageTap: (imageUrls, initialIndex) {
                      _openGallery(imageUrls, initialIndex);
                    },
                    onLikesViewTap: (post) {
                      if ((post.likes?.length ?? 0) > 0) {
                        ToastHelper.showInfo(context,
                            'Xem ${post.likes?.length} người đã thích bài viết');
                        // Mở trang danh sách người thích
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => LikesListPage(post: post)));
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

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
}
