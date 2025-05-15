import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:language_app/models/comment_model.dart';
import 'package:language_app/provider/user_provider.dart';
import 'package:language_app/service/comment_service.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentSection extends StatefulWidget {
  final String postId;

  const CommentSection({Key? key, required this.postId}) : super(key: key);

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final CommentService _commentService = CommentService();

  bool _isLoading = false;
  bool _isSubmitting = false;
  List<CommentModel> _comments = [];
  int? _editingCommentId;
  String? _editingCommentContent;

  @override
  void initState() {
    super.initState();
    // Thiết lập locale tiếng Việt cho timeago
    timeago.setLocaleMessages('vi', timeago.ViMessages());

    // Tải bình luận khi khởi tạo
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Tải danh sách bình luận
  Future<void> _loadComments() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final comments =
          await _commentService.getCommentsByPostId(int.parse(widget.postId));
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      _showSnackBar('Lỗi khi tải bình luận: ${e.toString()}', isError: true);
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Phương thức public để làm mới danh sách bình luận
  void refreshComments() async {
    await _loadComments();
  }

  // Thêm bình luận mới
  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Phát hiệu ứng haptic feedback
      HapticFeedback.mediumImpact();

      final newComment = await _commentService.createComment(
        int.parse(widget.postId),
        _commentController.text,
      );

      setState(() {
        _commentController.clear();
        _isSubmitting = false;
      });

      if (newComment != null) {
        // Tải lại bình luận
        await _loadComments();
        _showSnackBar('Đã thêm bình luận');

        // Cuộn xuống danh sách bình luận
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        _showSnackBar(
            'Không thể thêm bình luận. Tuy nhiên, hãy làm mới trang để kiểm tra lại.',
            isError: true);
        // Vẫn cố gắng làm mới trong trường hợp API thành công nhưng parse lỗi
        await _loadComments();
      }
    } catch (e) {
      _showSnackBar('Lỗi: ${e.toString()}. Hãy làm mới trang để kiểm tra.',
          isError: true);
      setState(() {
        _isSubmitting = false;
      });
      // Vẫn cố gắng làm mới trong trường hợp lỗi xảy ra sau khi đã thêm thành công
      await _loadComments();
    }
  }

  // Cập nhật bình luận
  Future<void> _updateComment() async {
    if (_editingCommentId == null ||
        _editingCommentContent == null ||
        _editingCommentContent!.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final updatedComment = await _commentService.updateComment(
        _editingCommentId!,
        _editingCommentContent!,
      );

      setState(() {
        _editingCommentId = null;
        _editingCommentContent = null;
        _isSubmitting = false;
      });

      if (updatedComment != null) {
        // Tải lại bình luận
        await _loadComments();
        _showSnackBar('Đã cập nhật bình luận');
      } else {
        _showSnackBar(
            'Không thể cập nhật bình luận. Tuy nhiên, hãy làm mới trang để kiểm tra lại.',
            isError: true);
        // Vẫn cố gắng làm mới trong trường hợp API thành công nhưng parse lỗi
        await _loadComments();
      }
    } catch (e) {
      _showSnackBar('Lỗi: ${e.toString()}. Hãy làm mới trang để kiểm tra.',
          isError: true);
      setState(() {
        _isSubmitting = false;
      });
      // Vẫn cố gắng làm mới trong trường hợp lỗi xảy ra sau khi đã cập nhật thành công
      await _loadComments();
    }
  }

  // Xóa bình luận
  Future<void> _deleteComment(int commentId) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await _commentService.deleteComment(commentId);

      if (success) {
        setState(() {
          _isSubmitting = false;
        });

        // Tải lại bình luận
        await _loadComments();

        _showSnackBar('Đã xóa bình luận');
      } else {
        _showSnackBar('Không thể xóa bình luận', isError: true);
        setState(() {
          _isSubmitting = false;
        });
      }
    } catch (e) {
      _showSnackBar('Lỗi: ${e.toString()}', isError: true);
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // Hiển thị form chỉnh sửa bình luận
  void _showEditCommentForm(CommentModel comment) {
    setState(() {
      _editingCommentId = comment.id;
      _editingCommentContent = comment.content;
    });

    // Hiển thị dialog chỉnh sửa
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa bình luận'),
        content: TextField(
          autofocus: true,
          maxLines: 3,
          controller: TextEditingController(text: comment.content),
          decoration: const InputDecoration(
            hintText: 'Nhập nội dung bình luận',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _editingCommentContent = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _editingCommentId = null;
                _editingCommentContent = null;
              });
            },
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateComment();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  // Hiển thị hộp thoại xác nhận xóa
  void _showDeleteConfirmation(int commentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa bình luận này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteComment(commentId);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  // Hiển thị SnackBar
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
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin user hiện tại
    final currentUser = Provider.of<UserProvider>(context).user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Bình luận',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Danh sách bình luận
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _comments.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Chưa có bình luận nào'),
                    ),
                  )
                : ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      final isCurrentUserComment =
                          currentUser?.id == comment.userId.toString();

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.blueGrey[100],
                                    backgroundImage:
                                        comment.userAvatar != null &&
                                                comment.userAvatar!.isNotEmpty
                                            ? NetworkImage(comment.userAvatar!)
                                            : null,
                                    child: (comment.userAvatar == null ||
                                            comment.userAvatar!.isEmpty)
                                        ? Text(
                                            (comment.userDisplayName ?? 'U')
                                                .substring(0, 1)
                                                .toUpperCase(),
                                            style: TextStyle(
                                              color: Colors.blue[800],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      comment.userDisplayName ?? 'Người dùng',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    timeago.format(
                                      DateTime.parse(comment.createdAt),
                                      locale: 'vi',
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),

                                  // Menu chỉnh sửa/xóa cho người dùng sở hữu comment
                                  if (isCurrentUserComment)
                                    PopupMenuButton(
                                      icon:
                                          const Icon(Icons.more_vert, size: 18),
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit, size: 18),
                                              SizedBox(width: 8),
                                              Text('Chỉnh sửa'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete,
                                                  size: 18, color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Xóa',
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _showEditCommentForm(comment);
                                        } else if (value == 'delete') {
                                          _showDeleteConfirmation(comment.id);
                                        }
                                      },
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(comment.content),

                              // Hiển thị phần trả lời (nếu có)
                              if (comment.replies.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: comment.replies.length,
                                    itemBuilder: (context, replyIndex) {
                                      final reply = comment.replies[replyIndex];
                                      final isCurrentUserReply =
                                          currentUser?.id ==
                                              reply.userId.toString();

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 12,
                                                  backgroundColor:
                                                      Colors.blueGrey[100],
                                                  backgroundImage:
                                                      reply.userAvatar !=
                                                                  null &&
                                                              reply.userAvatar!
                                                                  .isNotEmpty
                                                          ? NetworkImage(
                                                              reply.userAvatar!)
                                                          : null,
                                                  child: (reply.userAvatar ==
                                                              null ||
                                                          reply.userAvatar!
                                                              .isEmpty)
                                                      ? Text(
                                                          (reply.userDisplayName ??
                                                                  'U')
                                                              .substring(0, 1)
                                                              .toUpperCase(),
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: Colors
                                                                .blue[800],
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        )
                                                      : null,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    reply.userDisplayName ??
                                                        'Người dùng',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Text(
                                                  timeago.format(
                                                    DateTime.parse(
                                                        reply.createdAt),
                                                    locale: 'vi',
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),

                                                // Menu chỉnh sửa/xóa cho comment của người dùng
                                                if (isCurrentUserReply)
                                                  PopupMenuButton(
                                                    icon: const Icon(
                                                        Icons.more_vert,
                                                        size: 16),
                                                    itemBuilder: (context) => [
                                                      const PopupMenuItem(
                                                        value: 'edit',
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.edit,
                                                                size: 16),
                                                            SizedBox(width: 8),
                                                            Text('Chỉnh sửa'),
                                                          ],
                                                        ),
                                                      ),
                                                      const PopupMenuItem(
                                                        value: 'delete',
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.delete,
                                                                size: 16,
                                                                color:
                                                                    Colors.red),
                                                            SizedBox(width: 8),
                                                            Text('Xóa',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red)),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                    onSelected: (value) {
                                                      if (value == 'edit') {
                                                        _showEditCommentForm(
                                                            reply);
                                                      } else if (value ==
                                                          'delete') {
                                                        _showDeleteConfirmation(
                                                            reply.id);
                                                      }
                                                    },
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              reply.content,
                                              style:
                                                  const TextStyle(fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),

        // Form nhập bình luận mới
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Viết bình luận...',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 8),
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : IconButton(
                      onPressed: _addComment,
                      icon: const Icon(Icons.send),
                      color: Theme.of(context).primaryColor,
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
