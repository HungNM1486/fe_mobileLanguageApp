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

class _CommentSectionState extends State<CommentSection>
    with SingleTickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final CommentService _commentService = CommentService();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Define modern colors
  final Color _accentColor = Color(0xFF5B6EF5); // Primary accent color
  final Color _secondaryColor =
      Color(0xFFF86A6A); // For delete/negative actions
  final Color _successColor = Color(0xFF46BEA3); // For success states

  bool _isLoading = false;
  bool _isSubmitting = false;
  List<CommentModel> _comments = [];
  int? _editingCommentId;
  String? _editingCommentContent;
  bool _hasNewComment = false; // Track new comments for auto-scroll

  @override
  void initState() {
    super.initState();
    // Thiết lập locale tiếng Việt cho timeago
    timeago.setLocaleMessages('vi', timeago.ViMessages());

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Tải bình luận khi khởi tạo
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
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
        _hasNewComment = true; // Set flag to auto-scroll
      });

      if (newComment != null) {
        // Tải lại bình luận
        await _loadComments();
        _showSnackBar('Đã thêm bình luận');

        // Cuộn xuống danh sách bình luận
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_scrollController.hasClients && _hasNewComment) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
            _hasNewComment = false;
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
      // Add haptic feedback
      HapticFeedback.heavyImpact();

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
        title: Row(
          children: [
            Icon(Icons.edit_rounded, color: _accentColor, size: 24),
            SizedBox(width: 10),
            Text(
              'Chỉnh sửa bình luận',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: TextField(
          autofocus: true,
          maxLines: 5,
          controller: TextEditingController(text: comment.content),
          decoration: InputDecoration(
            hintText: 'Nhập nội dung bình luận',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _accentColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.all(16),
          ),
          style: TextStyle(
            fontSize: 16,
            height: 1.4,
          ),
          onChanged: (value) {
            _editingCommentContent = value;
          },
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _editingCommentId = null;
                _editingCommentContent = null;
              });
            },
            child: Text(
              'Hủy',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateComment();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              'Lưu',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
        actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  // Hiển thị hộp thoại xác nhận xóa
  void _showDeleteConfirmation(int commentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: _secondaryColor, size: 24),
            SizedBox(width: 10),
            Text(
              'Xác nhận xóa',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa bình luận này không?',
          style: TextStyle(
            fontSize: 16,
            height: 1.4,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _secondaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteComment(commentId);
            },
            child: Text(
              'Xóa',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
        actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
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
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: isError ? _secondaryColor : _successColor,
        duration: const Duration(seconds: 3),
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        elevation: 4,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin user hiện tại
    final currentUser = Provider.of<UserProvider>(context).user;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Background colors based on theme
    final backgroundColor = isDarkMode ? Color(0xFF0F0F23) : Colors.grey[50];
    final cardColor = isDarkMode ? Color(0xFF1A1E30) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    // Run animation on build
    _animationController.forward();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Comments header with modern styling
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.chat_rounded,
                          color: _accentColor,
                          size: 22,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Bình luận',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_comments.length}',
                          style: TextStyle(
                            color: _accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Spacer(),
                      if (!_isLoading)
                        IconButton(
                          icon:
                              Icon(Icons.refresh_rounded, color: _accentColor),
                          onPressed: refreshComments,
                          tooltip: 'Làm mới bình luận',
                        ),
                    ],
                  ),
                ),

                // Comments list
                _isLoading
                    ? _buildLoadingState()
                    : _comments.isEmpty
                        ? _buildEmptyState()
                        : _buildCommentsList(currentUser, isDarkMode, cardColor,
                            textColor, subtextColor),

                // Comment input area
                _buildCommentInput(isDarkMode, cardColor),
              ],
            ),
          ),
        );
      },
    );
  }

  // Loading state
  Widget _buildLoadingState() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Đang tải bình luận...',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Empty state
  Widget _buildEmptyState() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 40,
                color: _accentColor,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Chưa có bình luận nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Hãy là người đầu tiên bình luận về bài viết này',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Comments list
  Widget _buildCommentsList(
      currentUser, isDarkMode, cardColor, textColor, subtextColor) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      controller: _scrollController,
      itemCount: _comments.length,
      itemBuilder: (context, index) {
        final comment = _comments[index];
        final isCurrentUserComment =
            currentUser?.id == comment.userId.toString();

        return _buildCommentItem(
          comment: comment,
          isCurrentUserComment: isCurrentUserComment,
          isDarkMode: isDarkMode,
          cardColor: cardColor,
          textColor: textColor,
          subtextColor: subtextColor,
          currentUser: currentUser,
        );
      },
    );
  }

  // Comment item
  Widget _buildCommentItem({
    required CommentModel comment,
    required bool isCurrentUserComment,
    required bool isDarkMode,
    required Color cardColor,
    required Color textColor,
    required Color subtextColor,
    required dynamic currentUser,
  }) {
    // Determine bubble alignment and styling based on author
    final isOwnComment = isCurrentUserComment;
    final bubbleAlignment =
        isOwnComment ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isOwnComment
        ? _accentColor.withOpacity(isDarkMode ? 0.3 : 0.15)
        : isDarkMode
            ? Color(0xFF2A2D3E)
            : Colors.grey[100]!;
    final bubbleBorderRadius = isOwnComment
        ? BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          )
        : BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          );

    return Align(
      alignment: bubbleAlignment,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        child: Column(
          crossAxisAlignment:
              isOwnComment ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Author info row
            Padding(
              padding: EdgeInsets.only(
                left: isOwnComment ? 0 : 8,
                right: isOwnComment ? 8 : 0,
                bottom: 4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isOwnComment) ...[
                    CircleAvatar(
                      radius: 12,
                      backgroundColor:
                          isDarkMode ? Colors.grey[700] : Colors.grey[300],
                      backgroundImage: comment.userAvatar != null &&
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
                                color: isDarkMode ? Colors.white : _accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            )
                          : null,
                    ),
                    SizedBox(width: 6),
                  ],
                  Text(
                    isOwnComment
                        ? 'Bạn'
                        : (comment.userDisplayName ?? 'Người dùng'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isOwnComment ? _accentColor : textColor,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    timeago.format(DateTime.parse(comment.createdAt),
                        locale: 'vi'),
                    style: TextStyle(
                      fontSize: 11,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ),

            // Comment bubble
            Material(
              color: Colors.transparent,
              child: InkWell(
                onLongPress: isCurrentUserComment
                    ? () {
                        HapticFeedback.mediumImpact();
                        _showCommentActions(comment);
                      }
                    : null,
                borderRadius: bubbleBorderRadius,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: bubbleBorderRadius,
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.transparent
                          : isOwnComment
                              ? _accentColor.withOpacity(0.1)
                              : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    comment.content,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.3,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),

            // Show menu indicator for own comments
            if (isCurrentUserComment)
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 8),
                child: Text(
                  'Nhấn giữ để thêm tùy chọn',
                  style: TextStyle(
                    fontSize: 10,
                    color: subtextColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            // Replies section
            if (comment.replies.isNotEmpty)
              Container(
                margin: EdgeInsets.only(
                  top: 8,
                  left: isOwnComment ? 32 : 24,
                  right: isOwnComment ? 24 : 32,
                ),
                child: Column(
                  crossAxisAlignment: isOwnComment
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: comment.replies.map((reply) {
                    final isCurrentUserReply =
                        currentUser?.id == reply.userId.toString();
                    return _buildReplyItem(
                      reply: reply,
                      isCurrentUserReply: isCurrentUserReply,
                      isDarkMode: isDarkMode,
                      textColor: textColor,
                      subtextColor: subtextColor,
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Reply item
  Widget _buildReplyItem({
    required CommentModel reply,
    required bool isCurrentUserReply,
    required bool isDarkMode,
    required Color textColor,
    required Color subtextColor,
  }) {
    final isOwnReply = isCurrentUserReply;
    final bubbleAlignment =
        isOwnReply ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isOwnReply
        ? _accentColor.withOpacity(isDarkMode ? 0.2 : 0.1)
        : isDarkMode
            ? Color(0xFF222639)
            : Colors.grey[50]!;
    final bubbleBorderRadius = isOwnReply
        ? BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          )
        : BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          );

    return Align(
      alignment: bubbleAlignment,
      child: Container(
        margin: EdgeInsets.only(bottom: 6),
        child: Column(
          crossAxisAlignment:
              isOwnReply ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Reply author info
            Padding(
              padding: EdgeInsets.only(
                left: isOwnReply ? 0 : 8,
                right: isOwnReply ? 8 : 0,
                bottom: 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isOwnReply) ...[
                    CircleAvatar(
                      radius: 10,
                      backgroundColor:
                          isDarkMode ? Colors.grey[700] : Colors.grey[300],
                      backgroundImage: reply.userAvatar != null &&
                              reply.userAvatar!.isNotEmpty
                          ? NetworkImage(reply.userAvatar!)
                          : null,
                      child: (reply.userAvatar == null ||
                              reply.userAvatar!.isEmpty)
                          ? Text(
                              (reply.userDisplayName ?? 'U')
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : _accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 8,
                              ),
                            )
                          : null,
                    ),
                    SizedBox(width: 4),
                  ],
                  Text(
                    isOwnReply
                        ? 'Bạn'
                        : (reply.userDisplayName ?? 'Người dùng'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isOwnReply ? _accentColor : textColor,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    timeago.format(DateTime.parse(reply.createdAt),
                        locale: 'vi'),
                    style: TextStyle(
                      fontSize: 10,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ),

            // Reply bubble
            Material(
              color: Colors.transparent,
              child: InkWell(
                onLongPress: isCurrentUserReply
                    ? () {
                        HapticFeedback.mediumImpact();
                        _showCommentActions(reply);
                      }
                    : null,
                borderRadius: bubbleBorderRadius,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: bubbleBorderRadius,
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.transparent
                          : isOwnReply
                              ? _accentColor.withOpacity(0.1)
                              : Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    reply.content,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.3,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show comment actions menu (Edit & Delete)
  void _showCommentActions(CommentModel comment) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Color(0xFF1A1E30) : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
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

            // Comment preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '"${comment.content.length > 60 ? '${comment.content.substring(0, 60)}...' : comment.content}"',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(),

            // Edit option
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.edit_rounded, color: _accentColor),
              ),
              title: Text(
                'Chỉnh sửa bình luận',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showEditCommentForm(comment);
              },
            ),

            // Delete option
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.delete_rounded, color: _secondaryColor),
              ),
              title: Text(
                'Xóa bình luận',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: _secondaryColor,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(comment.id);
              },
            ),

            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Comment input area
  Widget _buildCommentInput(bool isDarkMode, Color cardColor) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1A1E30) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -3),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar (can be added if needed)
          /*
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage('Your user avatar URL'),
            backgroundColor: Colors.grey[300],
          ),
          SizedBox(width: 12),
          */

          // Text input field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Color(0xFF252A40) : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDarkMode ? Colors.transparent : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Viết bình luận...',
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                    fontSize: 15,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: InputBorder.none,
                  isDense: true,
                ),
                maxLines: 4,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 15,
                  height: 1.3,
                ),
              ),
            ),
          ),

          SizedBox(width: 12),

          // Send button
          _isSubmitting
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_accentColor, Color(0xFF7D8EFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _accentColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _addComment,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
