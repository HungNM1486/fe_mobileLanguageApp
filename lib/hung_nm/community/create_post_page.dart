import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:language_app/provider/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:language_app/provider/post_provider.dart';
import 'package:language_app/models/language_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:animations/animations.dart';
import 'package:dotted_border/dotted_border.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({Key? key}) : super(key: key);

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage>
    with SingleTickerProviderStateMixin {
  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();

  // Form data
  List<String> _topics = [];
  bool _isAnonymous = false;
  bool _isSubmitting = false;
  List<File> _selectedImages = [];
  int? _selectedLanguageId;

  // Image picker
  final ImagePicker _picker = ImagePicker();

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Scroll controller for smooth scrolling
  final ScrollController _scrollController = ScrollController();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Modern color palette
  final Color _accentColor = Color(0xFF5B6EF5); // Primary accent
  final Color _secondaryColor = Color(0xFFF86A6A); // Action/highlight
  final Color _successColor = Color(0xFF46BEA3); // Success state

  // Suggested topics
  final List<String> _suggestedTopics = [
    'Ngữ pháp',
    'Từ vựng',
    'Phát âm',
    'Viết',
    'Nói',
    'Đọc hiểu',
    'Luyện thi',
    'Kinh nghiệm',
    'Góc nhìn',
    'Chia sẻ',
  ];

  @override
  void initState() {
    super.initState();
    // Thêm cài đặt locale tiếng Việt cho timeago
    timeago.setLocaleMessages('vi', timeago.ViMessages());

    // Khởi tạo animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<double>(
      begin: 0,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();

    // Tải danh sách ngôn ngữ khi trang được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LanguageProvider>(context, listen: false).fetchLanguages();
    });

    // Thiết lập màu thanh trạng thái
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _topicController.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Chọn ảnh từ thư viện
  Future<void> _pickImages() async {
    try {
      final List<XFile>? pickedImages = await _picker.pickMultiImage();
      if (pickedImages != null && pickedImages.isNotEmpty) {
        // Limit to 5 images total
        if (_selectedImages.length + pickedImages.length > 5) {
          _showSnackBar('Bạn chỉ có thể chọn tối đa 5 ảnh', isError: true);
          return;
        }

        // Kiểm tra kích thước file
        for (var image in pickedImages) {
          final file = File(image.path);
          final fileSize = await file.length();

          // Giới hạn kích thước file là 10MB
          if (fileSize > 10 * 1024 * 1024) {
            _showSnackBar(
                'Ảnh ${image.name} quá lớn, vui lòng chọn ảnh nhỏ hơn 10MB',
                isError: true);
            continue;
          }

          setState(() {
            _selectedImages.add(file);
          });

          // Tạo hiệu ứng haptic feedback khi thêm ảnh
          HapticFeedback.lightImpact();
        }
      }
    } catch (e) {
      _showSnackBar('Không thể chọn ảnh: $e', isError: true);
    }
  }

  // Xóa ảnh đã chọn
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    // Tạo hiệu ứng haptic feedback khi xóa ảnh
    HapticFeedback.mediumImpact();
  }

  // Thêm chủ đề mới
  void _addTopic() {
    if (_topicController.text.isEmpty) return;

    if (!_topics.contains(_topicController.text)) {
      setState(() {
        _topics.add(_topicController.text);
        _topicController.clear();
      });
      // Tạo hiệu ứng haptic feedback khi thêm topic
      HapticFeedback.lightImpact();
    } else {
      _showSnackBar('Chủ đề này đã được thêm', isError: true);
    }
  }

  // Thêm chủ đề từ danh sách gợi ý
  void _addSuggestedTopic(String topic) {
    if (!_topics.contains(topic)) {
      setState(() {
        _topics.add(topic);
      });
      // Tạo hiệu ứng haptic feedback khi thêm topic
      HapticFeedback.lightImpact();
    } else {
      _showSnackBar('Chủ đề này đã được thêm', isError: true);
    }
  }

  // Hiển thị SnackBar được thiết kế lại
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
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

  // Gửi bài viết lên server
  Future<void> _submitPost() async {
    // Disable keyboard
    FocusScope.of(context).unfocus();

    // Kiểm tra form validation
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLanguageId == null) {
      _showSnackBar('Vui lòng chọn ngôn ngữ cho bài viết', isError: true);
      return;
    }

    try {
      setState(() {
        _isSubmitting = true;
      });

      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final success = await postProvider.createPost(
        title: _titleController.text,
        content: _contentController.text,
        languageId: _selectedLanguageId!,
        tags: _topics.isNotEmpty ? _topics : null,
        files: _selectedImages.isNotEmpty ? _selectedImages : null,
      );

      if (success) {
        _showSnackBar('Đăng bài thành công');

        // Đợi snackbar hiển thị xong rồi mới pop
        Future.delayed(const Duration(seconds: 1), () {
          // Trả về kết quả thành công để CommunityForumPage biết cần cập nhật
          Navigator.pop(context, true);
        });
      } else {
        _showSnackBar('Đăng bài thất bại, vui lòng thử lại sau', isError: true);
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

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final bool isLoadingLanguages = languageProvider.isLoading;
    final List<LanguageModel> languages = languageProvider.languages;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF0F0F23) : Color(0xFFF8F9FD),
      appBar: _buildModernAppBar(isDarkMode),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          if (postProvider.isLoading) {
            return _buildLoadingState(isDarkMode);
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, 0.1),
                end: Offset.zero,
              ).animate(_fadeAnimation),
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  physics: BouncingScrollPhysics(),
                  children: [
                    // Modern title section
                    _buildPageTitle(isDarkMode),
                    SizedBox(height: 20),

                    // Section title
                    _buildSectionTitle('Nội dung bài viết',
                        Icons.edit_note_rounded, isDarkMode),
                    SizedBox(height: 16),

                    // Card container for main content
                    _buildContentCard(
                      child: Column(
                        children: [
                          // Tiêu đề with modern style
                          _buildTitleField(isDarkMode),
                          SizedBox(height: 20),

                          // Nội dung with modern style
                          _buildContentField(isDarkMode),
                        ],
                      ),
                      isDarkMode: isDarkMode,
                    ),
                    SizedBox(height: 28),

                    // Section title for language
                    _buildSectionTitle('Ngôn ngữ bài viết',
                        Icons.language_rounded, isDarkMode),
                    SizedBox(height: 16),

                    // Card container for language selection
                    _buildContentCard(
                      child: isLoadingLanguages
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                _accentColor),
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Đang tải danh sách ngôn ngữ...',
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : _buildLanguageSelector(languages, isDarkMode),
                      isDarkMode: isDarkMode,
                    ),
                    SizedBox(height: 28),

                    // Section title for topics
                    _buildSectionTitle(
                        'Chủ đề bài viết', Icons.tag_rounded, isDarkMode),
                    SizedBox(height: 16),

                    // Card container for topic input
                    _buildContentCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Input để thêm chủ đề mới
                          _buildTopicInputRow(isDarkMode),
                          SizedBox(height: 20),

                          // Hiển thị các chủ đề đã thêm
                          if (_topics.isNotEmpty)
                            _buildSelectedTopics(isDarkMode),

                          SizedBox(height: 20),

                          // Gợi ý các chủ đề
                          _buildSuggestedTopics(isDarkMode),
                        ],
                      ),
                      isDarkMode: isDarkMode,
                    ),
                    SizedBox(height: 28),

                    // Section title for images
                    _buildSectionTitle(
                        'Hình ảnh đính kèm', Icons.image_rounded, isDarkMode),
                    SizedBox(height: 16),

                    // Card container for image selection
                    _buildContentCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Button thêm ảnh
                          _buildImageUploader(isDarkMode),

                          // Hiển thị ảnh đã chọn
                          if (_selectedImages.isNotEmpty) ...[
                            SizedBox(height: 20),
                            _buildSelectedImages(isDarkMode),
                          ],
                        ],
                      ),
                      isDarkMode: isDarkMode,
                    ),
                    SizedBox(height: 40),

                    // Nút đăng bài viết
                    _buildSubmitButton(isDarkMode),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Build modern app bar
  PreferredSizeWidget _buildModernAppBar(bool isDarkMode) {
    return AppBar(
      elevation: 0,
      backgroundColor: isDarkMode ? Color(0xFF0F0F23) : Color(0xFFF8F9FD),
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.grey[800]!.withOpacity(0.8)
                : Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            color: isDarkMode ? Colors.white : Colors.black87,
            size: 20,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        // Cancel button with cleaner design
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextButton.icon(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            icon: Icon(Icons.close_rounded),
            label: Text('Hủy'),
            style: TextButton.styleFrom(
              foregroundColor: isDarkMode ? Colors.grey[400] : Colors.grey[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  // Page title with animation
  Widget _buildPageTitle(bool isDarkMode) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_accentColor, Color(0xFF7D8EFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _accentColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.post_add_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tạo bài viết mới',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Chia sẻ kiến thức của bạn với cộng đồng',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Loading state with animation
  Widget _buildLoadingState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: isDarkMode ? Color(0xFF1A1E30) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Đang đăng bài viết...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              fontFamily: 'BeVietnamPro',
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Vui lòng đợi trong giây lát',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
              fontFamily: 'BeVietnamPro',
            ),
          ),
        ],
      ),
    );
  }

  // Modern section title
  Widget _buildSectionTitle(String title, IconData icon, bool isDarkMode) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: _accentColor,
          ),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  // Content card with refined styling
  Widget _buildContentCard({required Widget child, required bool isDarkMode}) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1A1E30) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // Title input field with modern styling
  Widget _buildTitleField(bool isDarkMode) {
    return TextFormField(
      controller: _titleController,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: isDarkMode ? Colors.white : Colors.black87,
        height: 1.3,
      ),
      decoration: InputDecoration(
        labelText: 'Tiêu đề bài viết',
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
        hintText: 'Nhập tiêu đề hấp dẫn',
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          fontSize: 15,
        ),
        prefixIcon: Container(
          margin: EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: _accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(12),
              right: Radius.circular(0),
            ),
          ),
          child: Icon(
            Icons.title_rounded,
            color: _accentColor,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _accentColor,
            width: 1.5,
          ),
        ),
        filled: true,
        fillColor: isDarkMode ? Color(0xFF252A40) : Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(vertical: 16),
      ),
      maxLength: 100,
      textCapitalization: TextCapitalization.sentences,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập tiêu đề bài viết';
        }
        return null;
      },
    );
  }

  // Content input field with modern styling
  Widget _buildContentField(bool isDarkMode) {
    return TextFormField(
      controller: _contentController,
      maxLines: 6,
      style: TextStyle(
        fontSize: 16,
        color: isDarkMode ? Colors.white : Colors.black87,
        height: 1.4,
      ),
      decoration: InputDecoration(
        labelText: 'Nội dung bài viết',
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
        hintText: 'Chia sẻ kiến thức, kinh nghiệm của bạn...',
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          fontSize: 15,
        ),
        alignLabelWithHint: true,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 130),
          child: Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(12),
                right: Radius.circular(0),
              ),
            ),
            child: Icon(
              Icons.article_rounded,
              color: _accentColor,
            ),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _accentColor,
            width: 1.5,
          ),
        ),
        filled: true,
        fillColor: isDarkMode ? Color(0xFF252A40) : Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(vertical: 16),
      ),
      textCapitalization: TextCapitalization.sentences,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập nội dung bài viết';
        }
        if (value.length < 10) {
          return 'Nội dung bài viết quá ngắn';
        }
        return null;
      },
    );
  }

  // Language selector with modern styling
  Widget _buildLanguageSelector(
      List<LanguageModel> languages, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF252A40) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          hint: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.language_rounded,
                    color: _accentColor,
                    size: 18,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Chọn ngôn ngữ',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          value: _selectedLanguageId,
          items: languages.map((language) {
            return DropdownMenuItem<int>(
              value: int.tryParse(language.id),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    if (language.imageUrl.isNotEmpty)
                      Container(
                        width: 30,
                        height: 30,
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.grey[700]!
                                : Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            language.imageUrl,
                            width: 26,
                            height: 26,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.language_rounded, size: 20),
                          ),
                        ),
                      ),
                    SizedBox(width: 12),
                    Text(
                      language.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedLanguageId = value;
            });
            // Tạo hiệu ứng haptic feedback
            HapticFeedback.lightImpact();
          },
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.grey[800]!.withOpacity(0.3)
                  : Colors.grey[100]!,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _accentColor,
              size: 24,
            ),
          ),
          dropdownColor: isDarkMode ? Color(0xFF252A40) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          padding: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  // Topic input row with modern styling
  Widget _buildTopicInputRow(bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _topicController,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              labelText: 'Thêm chủ đề',
              labelStyle: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              hintText: 'Ví dụ: Ngữ pháp, Từ vựng...',
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                fontSize: 15,
              ),
              prefixIcon: Container(
                margin: EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(12),
                    right: Radius.circular(0),
                  ),
                ),
                child: Icon(
                  Icons.label_rounded,
                  color: _accentColor,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _accentColor,
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: isDarkMode ? Color(0xFF252A40) : Colors.grey[50],
              contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
            onFieldSubmitted: (value) {
              if (value.isNotEmpty) {
                _addTopic();
              }
            },
          ),
        ),
        SizedBox(width: 12),
        // Button to add topic with gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_accentColor, Color(0xFF7D8EFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
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
              onTap: _addTopic,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(14),
                child: Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Selected topics with modern chips
  Widget _buildSelectedTopics(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF252A40) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 16,
                color: _successColor,
              ),
              SizedBox(width: 8),
              Text(
                'Chủ đề đã chọn:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _topics.map((topic) {
              return _buildModernChip(
                topic,
                isDarkMode,
                onDeleted: () {
                  setState(() {
                    _topics.remove(topic);
                  });
                  HapticFeedback.lightImpact();
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Suggested topics section
  Widget _buildSuggestedTopics(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.tips_and_updates_rounded,
              size: 16,
              color: isDarkMode ? Colors.amber[400] : Colors.amber[700],
            ),
            SizedBox(width: 8),
            Text(
              'Chủ đề gợi ý:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _suggestedTopics.map((topic) {
            bool isSelected = _topics.contains(topic);
            return GestureDetector(
              onTap: () {
                if (!isSelected) {
                  _addSuggestedTopic(topic);
                } else {
                  setState(() {
                    _topics.remove(topic);
                  });
                  HapticFeedback.lightImpact();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [_accentColor.withOpacity(0.7), _accentColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected
                      ? null
                      : isDarkMode
                          ? Color(0xFF252A40)
                          : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : isDarkMode
                            ? Colors.grey[700]!
                            : Colors.grey[300]!,
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _accentColor.withOpacity(0.3),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.add_circle_outline_rounded,
                      size: 16,
                      color: isSelected ? Colors.white : _accentColor,
                    ),
                    SizedBox(width: 6),
                    Text(
                      topic,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : isDarkMode
                                ? Colors.white70
                                : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Modern chip design
  Widget _buildModernChip(String label, bool isDarkMode,
      {required VoidCallback onDeleted}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_accentColor.withOpacity(0.7), _accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withOpacity(0.3),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        backgroundColor: Colors.transparent,
        deleteIcon: Icon(
          Icons.cancel_rounded,
          size: 18,
          color: Colors.white,
        ),
        onDeleted: onDeleted,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    );
  }

  // Modern image uploader
  Widget _buildImageUploader(bool isDarkMode) {
    return GestureDetector(
      onTap: _pickImages,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(16),
        padding: EdgeInsets.zero,
        color: _accentColor.withOpacity(0.5),
        strokeWidth: 2,
        dashPattern: const [8, 4],
        child: Container(
          width: double.infinity,
          height: 140,
          decoration: BoxDecoration(
            color: _accentColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_photo_alternate_rounded,
                  size: 30,
                  color: _accentColor,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Chọn ảnh từ thư viện',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tối đa 5 ảnh, mỗi ảnh không quá 10MB',
                style: TextStyle(
                  fontSize: 13,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Selected images gallery
  Widget _buildSelectedImages(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.photo_library_rounded,
              size: 16,
              color: _accentColor,
            ),
            SizedBox(width: 8),
            Text(
              'Ảnh đã chọn (${_selectedImages.length}/5):',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Image preview with OpenContainer for animation
                    OpenContainer(
                      closedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      closedColor: Colors.transparent,
                      closedElevation: 0,
                      openElevation: 0,
                      transitionDuration: const Duration(milliseconds: 400),
                      closedBuilder: (context, action) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImages[index],
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                      openBuilder: (context, action) {
                        return Scaffold(
                          backgroundColor: Colors.black,
                          appBar: AppBar(
                            backgroundColor: Colors.black,
                            elevation: 0,
                            leading: IconButton(
                              icon: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black38,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            actions: [
                              IconButton(
                                icon: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _secondaryColor.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.delete_rounded,
                                    color: _secondaryColor,
                                    size: 16,
                                  ),
                                ),
                                onPressed: () {
                                  _removeImage(index);
                                  Navigator.pop(context);
                                },
                              ),
                              SizedBox(width: 16),
                            ],
                          ),
                          body: Center(
                            child: InteractiveViewer(
                              minScale: 0.5,
                              maxScale: 3.0,
                              child: Image.file(
                                _selectedImages[index],
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Delete button
                    Positioned(
                      right: 6,
                      top: 6,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Submit button with gradient and loading state
  Widget _buildSubmitButton(bool isDarkMode) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_accentColor, Color(0xFF7D8EFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _isSubmitting ? null : _submitPost,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white24,
          highlightColor: Colors.white10,
          child: Center(
            child: _isSubmitting
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2.5,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Đang đăng bài...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Đăng bài viết',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
