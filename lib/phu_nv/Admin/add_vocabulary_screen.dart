import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:language_app/models/vocabulary_model.dart';
import 'package:language_app/provider/vocabulary_provider.dart';
import 'package:language_app/provider/topic_provider.dart';
import 'package:language_app/widget/top_bar.dart';

class AddVocabularyScreen extends StatefulWidget {
  final bool isEditing;
  final VocabularyModel? vocabulary;
  final String? selectedTopicId;

  const AddVocabularyScreen({
    Key? key,
    this.isEditing = false,
    this.vocabulary,
    this.selectedTopicId,
  }) : super(key: key);

  @override
  State<AddVocabularyScreen> createState() => _AddVocabularyScreenState();
}

class _AddVocabularyScreenState extends State<AddVocabularyScreen> {
  final _formKey = GlobalKey<FormState>();

  final _wordController = TextEditingController();
  final _definitionController = TextEditingController();
  final _exampleController = TextEditingController();
  final _exampleTranslationController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String? _selectedTopicId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Load topics and initialize _selectedTopicId
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final topicProvider = Provider.of<TopicProvider>(context, listen: false);
      await topicProvider.fetchTopics();

      setState(() {
        if (widget.isEditing && widget.vocabulary != null) {
          _wordController.text = widget.vocabulary!.word;
          _definitionController.text = widget.vocabulary!.definition;
          _exampleController.text = widget.vocabulary!.example;
          _exampleTranslationController.text =
              widget.vocabulary!.exampleTranslation;
          _imageUrlController.text = widget.vocabulary!.imageUrl;
          _selectedTopicId = widget.vocabulary!.topicId.toString();

          // Kiểm tra _selectedTopicId
          if (!topicProvider.topics
              .any((topic) => topic.id == _selectedTopicId)) {
            _selectedTopicId = topicProvider.topics.isNotEmpty
                ? topicProvider.topics.first.id
                : null;
          }
        } else if (widget.selectedTopicId != null &&
            topicProvider.topics
                .any((topic) => topic.id == widget.selectedTopicId)) {
          _selectedTopicId = widget.selectedTopicId;
        } else {
          _selectedTopicId = topicProvider.topics.isNotEmpty
              ? topicProvider.topics.first.id
              : null;
        }
      });
    });
  }

  @override
  void dispose() {
    _wordController.dispose();
    _definitionController.dispose();
    _exampleController.dispose();
    _exampleTranslationController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveVocabulary() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTopicId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn một chủ đề')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final vocabularyProvider =
        Provider.of<VocabularyProvider>(context, listen: false);
    bool success;

    try {
      if (widget.isEditing && widget.vocabulary != null) {
        success = await vocabularyProvider.updateVocabulary(
          id: widget.vocabulary!.id.toString(),
          word: _wordController.text,
          definition: _definitionController.text,
          example: _exampleController.text,
          exampleTranslation: _exampleTranslationController.text,
          topicId: _selectedTopicId,
          imageUrl: _imageUrlController.text,
        );
      } else {
        success = await vocabularyProvider.createVocabulary(
          word: _wordController.text,
          definition: _definitionController.text,
          example: _exampleController.text,
          exampleTranslation: _exampleTranslationController.text,
          topicId: _selectedTopicId!,
          imageUrl: _imageUrlController.text.isNotEmpty
              ? _imageUrlController.text
              : null,
        );
      }

      setState(() {
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing
                ? 'Đã cập nhật từ vựng thành công'
                : 'Đã thêm từ vựng mới thành công'),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade200, Colors.indigo.shade50],
            stops: const [0.0, 0.7],
          ),
        ),
        child: Column(
          children: [
            TopBar(
              title:
                  widget.isEditing ? "Chỉnh sửa từ vựng" : "Thêm từ vựng mới",
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Word
                      Text(
                        'Từ vựng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _wordController,
                        decoration: InputDecoration(
                          hintText: 'Nhập từ vựng',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập từ vựng';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Definition
                      Text(
                        'Định nghĩa',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _definitionController,
                        decoration: InputDecoration(
                          hintText: 'Nhập định nghĩa',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập định nghĩa';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Example
                      Text(
                        'Ví dụ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _exampleController,
                        decoration: InputDecoration(
                          hintText: 'Nhập ví dụ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập ví dụ';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Example Translation
                      Text(
                        'Dịch ví dụ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _exampleTranslationController,
                        decoration: InputDecoration(
                          hintText: 'Nhập bản dịch của ví dụ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập bản dịch của ví dụ';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Topic
                      Text(
                        'Chủ đề',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Consumer<TopicProvider>(
                        builder: (context, topicProvider, child) {
                          if (topicProvider.isLoading) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (topicProvider.topics.isEmpty) {
                            return Text(
                              'Không có chủ đề nào, vui lòng thêm chủ đề trước',
                              style: TextStyle(color: Colors.red),
                            );
                          }

                          // Đảm bảo _selectedTopicId hợp lệ
                          if (_selectedTopicId != null &&
                              !topicProvider.topics.any(
                                  (topic) => topic.id == _selectedTopicId)) {
                            _selectedTopicId = topicProvider.topics.first.id;
                          }

                          return DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              hintText: 'Chọn chủ đề',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            value: _selectedTopicId,
                            items: topicProvider.topics.map((topic) {
                              return DropdownMenuItem<String>(
                                value: topic.id,
                                child: Text(topic.topic),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedTopicId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng chọn chủ đề';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 16),

                      // Image URL
                      Text(
                        'URL Hình ảnh (tùy chọn)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: InputDecoration(
                          hintText: 'Nhập URL hình ảnh',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),

                      // Preview image if URL is entered
                      if (_imageUrlController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Xem trước hình ảnh:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _imageUrlController.text,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 150,
                                      color: Colors.grey[200],
                                      width: double.infinity,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.broken_image,
                                              color: Colors.red,
                                              size: 40,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Không thể tải hình ảnh',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
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

                      SizedBox(height: 30),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveVocabulary,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  widget.isEditing
                                      ? 'Cập nhật'
                                      : 'Thêm từ vựng',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
