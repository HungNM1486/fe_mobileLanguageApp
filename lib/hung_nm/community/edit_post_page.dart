import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:language_app/models/post_model.dart';
import 'package:language_app/provider/post_provider.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:language_app/utils/toast_helper.dart';

class EditPostPage extends StatefulWidget {
  final PostModel post;

  const EditPostPage({Key? key, required this.post}) : super(key: key);

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _topicController;
  final List<String> _topics = [];
  final List<String> _imagesToRemove = []; // Danh sách hình ảnh cần xóa
  final List<File> _newImages = []; // Danh sách hình ảnh mới
  bool _isSubmitting = false;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  final ImagePicker _imagePicker = ImagePicker();

  // Danh sách các chủ đề đề xuất
  static const List<String> _suggestedTopics = [
    'Ngữ pháp',
    'Từ vựng',
    'Phát âm',
    'Nói',
    'Viết',
    'Đọc hiểu',
    'Nghe',
    'Mẹo học',
    'Chia sẻ'
  ];

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị từ bài viết hiện tại
    _titleController = TextEditingController(text: widget.post.title);
    _contentController = TextEditingController(text: widget.post.content);
    _topicController = TextEditingController();
    _topics.addAll(widget.post.tags ?? []);

    // Thiết lập animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _topicController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _addTopic(String topic) {
    if (topic.isNotEmpty && !_topics.contains(topic)) {
      setState(() {
        _topics.add(topic);
        _topicController.clear();
      });
      // Phản hồi xúc giác
      HapticFeedback.lightImpact();
    }
  }

  void _removeTopic(String topic) {
    setState(() {
      _topics.remove(topic);
    });
    HapticFeedback.lightImpact();
  }

  bool _hasChanges() {
    // In ra các giá trị để dễ debug
    print('Tiêu đề hiện tại: ${_titleController.text}');
    print('Tiêu đề ban đầu: ${widget.post.title}');
    print('Nội dung hiện tại: ${_contentController.text}');
    print('Nội dung ban đầu: ${widget.post.content}');
    print('Chủ đề hiện tại: $_topics');
    print('Chủ đề ban đầu: ${widget.post.tags}');

    bool titleChanged =
        _titleController.text.trim() != (widget.post.title ?? '').trim();
    bool contentChanged =
        _contentController.text.trim() != (widget.post.content ?? '').trim();
    bool tagsChanged = !_areListsEqual(_topics, widget.post.tags ?? []);

    print('Tiêu đề đã thay đổi: $titleChanged');
    print('Nội dung đã thay đổi: $contentChanged');
    print('Chủ đề đã thay đổi: $tagsChanged');

    return titleChanged || contentChanged || tagsChanged;
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final postProvider = Provider.of<PostProvider>(context, listen: false);

      // In ra thông tin để dễ debug
      print('Tiêu đề: ${_titleController.text}');
      print('Nội dung: ${_contentController.text}');
      print('Chủ đề: $_topics');
      print('Ảnh cần xóa: $_imagesToRemove');
      print('Số ảnh mới: ${_newImages.length}');

      final success = await postProvider.editPost(
        postId: widget.post.id!,
        title: _titleController.text,
        content: _contentController.text,
        tags: _topics,
        imagesToRemove: _imagesToRemove,
        newImages: _newImages,
      );

      setState(() => _isSubmitting = false);

      if (success) {
        _showSuccessMessage();
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        _showErrorMessage('Không thể cập nhật bài viết');
      }
    } catch (e) {
      print('Lỗi cập nhật bài viết: $e');
      setState(() => _isSubmitting = false);
      _showErrorMessage('Lỗi: ${e.toString()}');
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bài viết đã được cập nhật thành công'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Scaffold(
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode
                  ? const [Color(0xFF1A1A2E), Color(0xFF0F3460)]
                  : [Colors.white, const Color(0xFFF5F9FC)],
            ),
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(16 * pix),
              children: [
                _buildTitleField(pix),
                SizedBox(height: 20 * pix),
                _buildContentField(pix),
                SizedBox(height: 24 * pix),

                // Phần quản lý hình ảnh
                if (widget.post.imageUrls != null &&
                    widget.post.imageUrls!.isNotEmpty) ...[
                  _buildExistingImages(pix, isDarkMode),
                  SizedBox(height: 8 * pix),
                ],

                if (_imagesToRemove.isNotEmpty) ...[
                  _buildMarkedForRemovalImages(pix, isDarkMode),
                  SizedBox(height: 8 * pix),
                ],

                if (_newImages.isNotEmpty) ...[
                  _buildNewImages(pix, isDarkMode),
                  SizedBox(height: 8 * pix),
                ],

                // Nút thêm ảnh
                _buildAddImageButton(pix, isDarkMode),
                SizedBox(height: 16 * pix),

                _buildTopicsSection(pix),
                SizedBox(height: 16 * pix),
                _buildSuggestedTopics(isDarkMode, pix),
                SizedBox(height: 40 * pix),
                _buildSaveButton(pix),
                SizedBox(height: 30 * pix),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      title: const Text(
        'Chỉnh sửa bài viết',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: 'BeVietnamPro',
        ),
      ),
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor:
          isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFF4B6CB7),
      foregroundColor: Colors.white,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          if (_hasChanges()) {
            _showDiscardChangesDialog();
          } else {
            Navigator.pop(context);
          }
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Điền thông tin về bài viết của bạn'),
                behavior: SnackBarBehavior.floating,
              ));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField(double pix) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF222639) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: TextFormField(
            controller: _titleController,
            style: TextStyle(
              fontSize: 18 * pix,
              fontWeight: FontWeight.w500,
              fontFamily: 'BeVietnamPro',
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              labelText: 'Tiêu đề',
              labelStyle: TextStyle(
                fontSize: 16 * pix,
                fontFamily: 'BeVietnamPro',
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              contentPadding: EdgeInsets.all(20 * pix),
              border: InputBorder.none,
              filled: true,
              fillColor:
                  isDarkMode ? Colors.black12 : Colors.white.withOpacity(0.8),
              prefixIcon: Icon(
                Icons.title_rounded,
                color:
                    isDarkMode ? Colors.blue.shade300 : const Color(0xFF4B6CB7),
                size: 22,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập tiêu đề';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContentField(double pix) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF222639) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: TextFormField(
            controller: _contentController,
            style: TextStyle(
              fontSize: 16 * pix,
              fontFamily: 'BeVietnamPro',
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              labelText: 'Nội dung',
              alignLabelWithHint: true,
              labelStyle: TextStyle(
                fontSize: 16 * pix,
                fontFamily: 'BeVietnamPro',
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              contentPadding: EdgeInsets.all(20 * pix),
              border: InputBorder.none,
              filled: true,
              fillColor:
                  isDarkMode ? Colors.black12 : Colors.white.withOpacity(0.8),
              prefixIcon: Icon(
                Icons.article_rounded,
                color:
                    isDarkMode ? Colors.blue.shade300 : const Color(0xFF4B6CB7),
                size: 22,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập nội dung bài viết';
              }
              return null;
            },
            maxLines: 10,
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
      ),
    );
  }

  // Xóa phương thức này vì không dùng nữa
  /*
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    required bool isDarkMode, 
    required double pix,
    int? maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12 * pix),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: TextStyle(
          fontSize: maxLines == 1 ? 18 * pix : 16 * pix,
          fontWeight: maxLines == 1 ? FontWeight.w500 : FontWeight.normal,
          fontFamily: 'BeVietnamPro',
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          alignLabelWithHint: maxLines != 1,
          labelStyle: TextStyle(
            fontSize: 16 * pix,
            fontFamily: 'BeVietnamPro',
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          contentPadding: EdgeInsets.all(16 * pix),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12 * pix),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
          prefixIcon: Icon(
            prefixIcon,
            color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
          ),
        ),
        validator: validator,
        maxLines: maxLines,
        textCapitalization: maxLines != 1 ? TextCapitalization.sentences : TextCapitalization.none,
      ),
    );
  }
  */

  Widget _buildTopicsSection(double pix) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.local_offer_rounded,
              size: 20 * pix,
              color:
                  isDarkMode ? Colors.blue.shade300 : const Color(0xFF4B6CB7),
            ),
            SizedBox(width: 8 * pix),
            Text(
              'Chủ đề',
              style: TextStyle(
                fontSize: 18 * pix,
                fontWeight: FontWeight.w600,
                fontFamily: 'BeVietnamPro',
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 12 * pix),

        // Input để thêm chủ đề
        _buildTopicInput(pix),
        SizedBox(height: 16 * pix),

        // Hiển thị các chủ đề đã chọn
        _buildSelectedTopics(pix),
      ],
    );
  }

  Widget _buildTopicInput(double pix) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF222639) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _topicController,
                  style: TextStyle(
                    fontSize: 16 * pix,
                    fontFamily: 'BeVietnamPro',
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Thêm chủ đề...',
                    hintStyle: TextStyle(
                      fontSize: 16 * pix,
                      fontFamily: 'BeVietnamPro',
                      color: Colors.grey.shade500,
                    ),
                    contentPadding: EdgeInsets.all(16 * pix),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: isDarkMode
                        ? Colors.black12
                        : Colors.white.withOpacity(0.8),
                    prefixIcon: Icon(
                      Icons.add_circle_outline_rounded,
                      color: isDarkMode
                          ? Colors.blue.shade300
                          : const Color(0xFF4B6CB7),
                    ),
                  ),
                  onSubmitted: (value) => _addTopic(value),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: _topicController.text.isEmpty
                      ? (isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade200)
                      : (isDarkMode
                          ? Colors.blue.shade700
                          : const Color(0xFF4B6CB7)),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.add,
                    color: _topicController.text.isEmpty
                        ? (isDarkMode
                            ? Colors.grey.shade500
                            : Colors.grey.shade500)
                        : Colors.white,
                    size: 22 * pix,
                  ),
                  onPressed: () => _addTopic(_topicController.text),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTopics(double pix) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Wrap(
      spacing: 10 * pix,
      runSpacing: 10 * pix,
      children: _topics.map((topic) => _buildTopicChip(topic, pix)).toList(),
    );
  }

  Widget _buildTopicChip(String topic, double pix) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [const Color(0xFF304880), const Color(0xFF1A72BA)]
                : [const Color(0xFF4776C4), const Color(0xFF5685E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20 * pix),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4B6CB7).withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20 * pix),
            onTap: () => HapticFeedback.lightImpact(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 12 * pix,
                vertical: 8 * pix,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    topic,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14 * pix,
                      fontFamily: 'BeVietnamPro',
                    ),
                  ),
                  SizedBox(width: 8 * pix),
                  GestureDetector(
                    onTap: () => _removeTopic(topic),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withOpacity(0.9),
                      size: 16 * pix,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestedTopics(bool isDarkMode, double pix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chủ đề đề xuất',
          style: TextStyle(
            fontSize: 16 * pix,
            fontWeight: FontWeight.w500,
            fontFamily: 'BeVietnamPro',
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8 * pix),
        Wrap(
          spacing: 8 * pix,
          runSpacing: 8 * pix,
          children: _suggestedTopics
              .map((topic) => _buildSuggestedTopicChip(topic, isDarkMode, pix))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSuggestedTopicChip(String topic, bool isDarkMode, double pix) {
    final isSelected = _topics.contains(topic);
    return GestureDetector(
      onTap: () {
        if (isSelected) {
          _removeTopic(topic);
        } else {
          _addTopic(topic);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? Colors.blue.shade800 : Colors.blue.shade600)
              : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(20 * pix),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 16 * pix,
          vertical: 8 * pix,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.add_circle_outline,
              size: 16 * pix,
              color: isSelected
                  ? Colors.white
                  : (isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700),
            ),
            SizedBox(width: 6 * pix),
            Text(
              topic,
              style: TextStyle(
                fontSize: 14 * pix,
                fontFamily: 'BeVietnamPro',
                color: isSelected
                    ? Colors.white
                    : (isDarkMode ? Colors.white : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(double pix) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24 * pix),
      height: 58 * pix,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4B6CB7),
            Color(0xFF182848),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4B6CB7).withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isSubmitting ? null : _saveChanges,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Center(
            child: _isSubmitting
                ? SizedBox(
                    width: 24 * pix,
                    height: 24 * pix,
                    child: CircularProgressIndicator(
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 24 * pix,
                      ),
                      SizedBox(width: 10 * pix),
                      Text(
                        'Lưu thay đổi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17 * pix,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'BeVietnamPro',
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void _showDiscardChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bỏ các thay đổi?'),
        content: const Text(
            'Bạn có các thay đổi chưa lưu. Bạn có chắc chắn muốn thoát không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tiếp tục chỉnh sửa'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Đóng dialog
              Navigator.pop(context); // Đóng trang chỉnh sửa
            },
            child: const Text('Bỏ thay đổi'),
          ),
        ],
      ),
    );
  }

  bool _areListsEqual(List<String> list1, List<String> list2) {
    print('So sánh hai danh sách:');
    print('Danh sách 1: $list1');
    print('Danh sách 2: $list2');

    if (list1.length != list2.length) {
      print('Độ dài khác nhau: ${list1.length} vs ${list2.length}');
      return false;
    }

    // Tạo bản sao và sắp xếp để so sánh chính xác hơn
    final sortedList1 = List<String>.from(list1)..sort();
    final sortedList2 = List<String>.from(list2)..sort();

    for (int i = 0; i < sortedList1.length; i++) {
      if (sortedList1[i].trim() != sortedList2[i].trim()) {
        print(
            'Khác nhau tại vị trí $i: ${sortedList1[i]} vs ${sortedList2[i]}');
        return false;
      }
    }

    print('Hai danh sách giống nhau');
    return true;
  }

  // Phương thức chọn ảnh từ thiết bị
  Future<void> _pickImages() async {
    try {
      final List<XFile> selectedImages = await _imagePicker.pickMultiImage(
        imageQuality: 70,
        maxWidth: 1200,
      );

      if (selectedImages.isNotEmpty) {
        setState(() {
          for (var image in selectedImages) {
            _newImages.add(File(image.path));
          }
        });

        ToastHelper.showSuccess(
            context, 'Đã thêm ${selectedImages.length} ảnh');
      }
    } catch (e) {
      print('Lỗi khi chọn ảnh: $e');
      ToastHelper.showError(context, 'Không thể chọn ảnh');
    }
  }

  // Phương thức xóa ảnh khỏi danh sách ảnh mới đã chọn
  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
    ToastHelper.showInfo(context, 'Đã xóa ảnh');
  }

  // Phương thức đánh dấu ảnh cũ cần xóa
  void _markImageToRemove(String imageUrl) {
    setState(() {
      _imagesToRemove.add(imageUrl);
    });
    ToastHelper.showInfo(context, 'Đã đánh dấu xóa ảnh');
  }

  // Phương thức bỏ đánh dấu xóa ảnh
  void _unmarkImageToRemove(String imageUrl) {
    setState(() {
      _imagesToRemove.remove(imageUrl);
    });
    ToastHelper.showInfo(context, 'Đã bỏ đánh dấu xóa ảnh');
  }

  // Xây dựng phần hiển thị hình ảnh hiện có
  Widget _buildExistingImages(double pix, bool isDarkMode) {
    // Lọc ra các hình ảnh chưa bị đánh dấu xóa
    final existingImages = widget.post.imageUrls
            ?.where(
              (url) => !_imagesToRemove.contains(url),
            )
            .toList() ??
        [];

    if (existingImages.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16 * pix),
          child: Row(
            children: [
              Icon(
                Icons.photo_library_rounded,
                size: 20 * pix,
                color:
                    isDarkMode ? Colors.blue.shade300 : const Color(0xFF4B6CB7),
              ),
              SizedBox(width: 8 * pix),
              Text(
                'Hình ảnh hiện có',
                style: TextStyle(
                  fontSize: 18 * pix,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'BeVietnamPro',
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 120 * pix,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: existingImages.length,
            itemBuilder: (context, index) {
              final imageUrl = existingImages[index];
              return Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 8 * pix),
                    width: 120 * pix,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8 * pix),
                      border: Border.all(
                        color:
                            isDarkMode ? Colors.white24 : Colors.grey.shade300,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8 * pix),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4 * pix,
                    right: 12 * pix,
                    child: GestureDetector(
                      onTap: () => _markImageToRemove(imageUrl),
                      child: Container(
                        padding: EdgeInsets.all(4 * pix),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16 * pix,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // Xây dựng phần hiển thị hình ảnh đã đánh dấu xóa
  Widget _buildMarkedForRemovalImages(double pix, bool isDarkMode) {
    if (_imagesToRemove.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16 * pix),
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                size: 20 * pix,
                color: Colors.red.shade400,
              ),
              SizedBox(width: 8 * pix),
              Text(
                'Hình ảnh sẽ bị xóa',
                style: TextStyle(
                  fontSize: 18 * pix,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'BeVietnamPro',
                  color: Colors.red.shade400,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 120 * pix,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _imagesToRemove.length,
            itemBuilder: (context, index) {
              final imageUrl = _imagesToRemove[index];
              return Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 8 * pix),
                    width: 120 * pix,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8 * pix),
                      border: Border.all(
                        color: Colors.red.shade200,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8 * pix),
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.red.withOpacity(0.2),
                          BlendMode.srcATop,
                        ),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => Center(
                            child: Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4 * pix,
                    right: 12 * pix,
                    child: GestureDetector(
                      onTap: () => _unmarkImageToRemove(imageUrl),
                      child: Container(
                        padding: EdgeInsets.all(4 * pix),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.restore,
                          color: Colors.white,
                          size: 16 * pix,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // Xây dựng phần hiển thị hình ảnh mới
  Widget _buildNewImages(double pix, bool isDarkMode) {
    if (_newImages.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16 * pix),
          child: Row(
            children: [
              Icon(
                Icons.add_photo_alternate,
                size: 20 * pix,
                color:
                    isDarkMode ? Colors.green.shade300 : Colors.green.shade600,
              ),
              SizedBox(width: 8 * pix),
              Text(
                'Hình ảnh mới',
                style: TextStyle(
                  fontSize: 18 * pix,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'BeVietnamPro',
                  color: isDarkMode
                      ? Colors.green.shade300
                      : Colors.green.shade600,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 120 * pix,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _newImages.length,
            itemBuilder: (context, index) {
              final image = _newImages[index];
              return Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 8 * pix),
                    width: 120 * pix,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8 * pix),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.green.shade700
                            : Colors.green.shade300,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8 * pix),
                      child: Image.file(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4 * pix,
                    right: 12 * pix,
                    child: GestureDetector(
                      onTap: () => _removeNewImage(index),
                      child: Container(
                        padding: EdgeInsets.all(4 * pix),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16 * pix,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // Xây dựng nút thêm hình ảnh
  Widget _buildAddImageButton(double pix, bool isDarkMode) {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 16 * pix),
        padding: EdgeInsets.symmetric(horizontal: 16 * pix, vertical: 12 * pix),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isDarkMode ? Colors.blue.shade800 : Colors.blue.shade500,
              isDarkMode ? Colors.blue.shade900 : Colors.blue.shade700,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12 * pix),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_photo_alternate,
              color: Colors.white,
              size: 20 * pix,
            ),
            SizedBox(width: 8 * pix),
            Text(
              'Thêm hình ảnh',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16 * pix,
                fontFamily: 'BeVietnamPro',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
