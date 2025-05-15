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

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

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
    super.dispose();
  }

  // Chọn ảnh từ thư viện
  Future<void> _pickImages() async {
    try {
      final List<XFile>? pickedImages = await _picker.pickMultiImage();
      if (pickedImages != null && pickedImages.isNotEmpty) {
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
    if (_topicController.text.isNotEmpty) {
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
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        elevation: 4,
      ),
    );
  }

  // Gửi bài viết lên server
  Future<void> _submitPost() async {
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
      // Gradient background
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      // Custom app bar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        title: Text(
          'Tạo bài viết mới',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
            fontSize: 18,
            fontFamily: 'BeVietnamPro',
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: _isSubmitting ? null : _submitPost,
            icon: const Icon(Icons.send_rounded),
            label: Text(_isSubmitting ? 'Đang đăng...' : 'Đăng bài'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blueAccent,
              backgroundColor: Colors.blue.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              disabledBackgroundColor: Colors.grey.withOpacity(0.1),
              disabledForegroundColor: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      // Body with animations
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          if (postProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Đang đăng bài viết...',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'BeVietnamPro',
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section title
                    _buildSectionTitle('Nội dung bài viết', Icons.edit),
                    const SizedBox(height: 16),

                    // Card container for main content
                    _buildContentCard(
                      child: Column(
                        children: [
                          // Tiêu đề
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: 'Tiêu đề bài viết',
                              hintText: 'Nhập tiêu đề hấp dẫn',
                              prefixIcon: const Icon(Icons.title),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDarkMode
                                      ? Colors.grey[700]!
                                      : Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDarkMode
                                      ? Colors.grey[700]!
                                      : Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.blueAccent,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor:
                                  isDarkMode ? Colors.grey[800] : Colors.white,
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'BeVietnamPro',
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                            maxLength: 100,
                            textCapitalization: TextCapitalization.sentences,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập tiêu đề bài viết';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Nội dung
                          TextFormField(
                            controller: _contentController,
                            maxLines: 6,
                            decoration: InputDecoration(
                              labelText: 'Nội dung bài viết',
                              hintText:
                                  'Chia sẻ kiến thức, kinh nghiệm của bạn...',
                              alignLabelWithHint: true,
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(bottom: 140),
                                child: Icon(Icons.article),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDarkMode
                                      ? Colors.grey[700]!
                                      : Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDarkMode
                                      ? Colors.grey[700]!
                                      : Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.blueAccent,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor:
                                  isDarkMode ? Colors.grey[800] : Colors.white,
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'BeVietnamPro',
                              color: isDarkMode ? Colors.white : Colors.black87,
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
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section title for language
                    _buildSectionTitle('Ngôn ngữ bài viết', Icons.language),
                    const SizedBox(height: 16),

                    // Card container for language selection
                    _buildContentCard(
                      child: isLoadingLanguages
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDarkMode
                                      ? Colors.grey[700]!
                                      : Colors.grey[300]!,
                                ),
                                color: isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.white,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  isExpanded: true,
                                  hint: Row(
                                    children: [
                                      Icon(
                                        Icons.language,
                                        color: isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Chọn ngôn ngữ',
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                          fontFamily: 'BeVietnamPro',
                                        ),
                                      ),
                                    ],
                                  ),
                                  value: _selectedLanguageId,
                                  items: languages.map((language) {
                                    return DropdownMenuItem<int>(
                                      value: int.tryParse(language.id),
                                      child: Row(
                                        children: [
                                          if (language.imageUrl.isNotEmpty)
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: Image.network(
                                                language.imageUrl,
                                                width: 24,
                                                height: 24,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    const Icon(Icons.language,
                                                        size: 24),
                                              ),
                                            ),
                                          const SizedBox(width: 12),
                                          Text(
                                            language.name,
                                            style: TextStyle(
                                              fontFamily: 'BeVietnamPro',
                                              fontWeight: FontWeight.w500,
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ],
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
                                  icon: Icon(
                                    Icons.arrow_drop_down_circle,
                                    color: isDarkMode
                                        ? Colors.blueAccent.withOpacity(0.7)
                                        : Colors.blueAccent,
                                  ),
                                  dropdownColor: isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),

                    // Section title for topics
                    _buildSectionTitle('Chủ đề bài viết', Icons.tag),
                    const SizedBox(height: 16),

                    // Card container for topic input
                    _buildContentCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Input để thêm chủ đề mới
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _topicController,
                                  decoration: InputDecoration(
                                    labelText: 'Thêm chủ đề',
                                    hintText: 'Ví dụ: Ngữ pháp, Từ vựng...',
                                    prefixIcon: const Icon(Icons.label),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: isDarkMode
                                            ? Colors.grey[700]!
                                            : Colors.grey[300]!,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.blueAccent,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.white,
                                  ),
                                  style: TextStyle(
                                    fontFamily: 'BeVietnamPro',
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                  onFieldSubmitted: (value) {
                                    if (value.isNotEmpty) {
                                      _addTopic();
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Button thêm topic
                              ElevatedButton(
                                onPressed: _addTopic,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.all(15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Icon(Icons.add),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Hiển thị các chủ đề đã thêm
                          if (_topics.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.grey[800]!.withOpacity(0.3)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDarkMode
                                      ? Colors.grey[700]!
                                      : Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Chủ đề đã chọn:',
                                    style: TextStyle(
                                      fontFamily: 'BeVietnamPro',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDarkMode
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _topics.map((topic) {
                                      return AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        child: Chip(
                                          label: Text(
                                            topic,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'BeVietnamPro',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          backgroundColor: Colors.blueAccent,
                                          deleteIcon: const Icon(
                                            Icons.close,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                          onDeleted: () {
                                            setState(() {
                                              _topics.remove(topic);
                                            });
                                            // Tạo hiệu ứng haptic feedback
                                            HapticFeedback.lightImpact();
                                          },
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 16),

                          // Gợi ý các chủ đề
                          Text(
                            'Chủ đề gợi ý:',
                            style: TextStyle(
                              fontFamily: 'BeVietnamPro',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
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
                                    // Tạo hiệu ứng haptic feedback
                                    HapticFeedback.lightImpact();
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.blueAccent
                                        : isDarkMode
                                            ? Colors.grey[800]
                                            : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.blueAccent
                                          : isDarkMode
                                              ? Colors.grey[700]!
                                              : Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    topic,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : isDarkMode
                                              ? Colors.white70
                                              : Colors.black87,
                                      fontFamily: 'BeVietnamPro',
                                      fontWeight: isSelected
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section title for images
                    _buildSectionTitle('Hình ảnh đính kèm', Icons.image),
                    const SizedBox(height: 16),

                    // Card container for image selection
                    _buildContentCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Button thêm ảnh
                          GestureDetector(
                            onTap: _pickImages,
                            child: DottedBorder(
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(12),
                              padding: EdgeInsets.zero,
                              color: isDarkMode
                                  ? Colors.grey[600]!
                                  : Colors.grey[400]!,
                              strokeWidth: 2,
                              dashPattern: const [8, 4],
                              child: Container(
                                width: double.infinity,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? Colors.grey[800]!.withOpacity(0.3)
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 40,
                                      color: isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Chọn ảnh từ thư viện',
                                      style: TextStyle(
                                        fontFamily: 'BeVietnamPro',
                                        fontSize: 16,
                                        color: isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tối đa 10MB/ảnh, tối đa 5 ảnh',
                                      style: TextStyle(
                                        fontFamily: 'BeVietnamPro',
                                        fontSize: 12,
                                        color: isDarkMode
                                            ? Colors.grey[500]
                                            : Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Hiển thị ảnh đã chọn
                          if (_selectedImages.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Ảnh đã chọn:',
                              style: TextStyle(
                                fontFamily: 'BeVietnamPro',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _selectedImages.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Stack(
                                      children: [
                                        // Preview ảnh với animation
                                        OpenContainer(
                                          closedShape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          closedColor: Colors.transparent,
                                          closedElevation: 0,
                                          openElevation: 0,
                                          transitionDuration:
                                              const Duration(milliseconds: 300),
                                          closedBuilder: (context, action) {
                                            return Hero(
                                              tag: 'image_$index',
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.file(
                                                  _selectedImages[index],
                                                  width: 120,
                                                  height: 120,
                                                  fit: BoxFit.cover,
                                                ),
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
                                                  icon: const Icon(
                                                      Icons.arrow_back),
                                                  color: Colors.white,
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                ),
                                                actions: [
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.white),
                                                    onPressed: () {
                                                      _removeImage(index);
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                              ),
                                              body: Center(
                                                child: InteractiveViewer(
                                                  minScale: 0.5,
                                                  maxScale: 3.0,
                                                  child: Hero(
                                                    tag: 'image_$index',
                                                    child: Image.file(
                                                      _selectedImages[index],
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),

                                        // Button xóa ảnh
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: GestureDetector(
                                            onTap: () => _removeImage(index),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.3),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 16,
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Nút đăng bài viết
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitPost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Đang đăng bài...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'BeVietnamPro',
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'Đăng bài viết',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'BeVietnamPro',
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget hiển thị tiêu đề section
  Widget _buildSectionTitle(String title, IconData icon) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(
          icon,
          size: 22,
          color: isDarkMode
              ? Colors.blueAccent.withOpacity(0.7)
              : Colors.blueAccent,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'BeVietnamPro',
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  // Widget card container
  Widget _buildContentCard({required Widget child}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
