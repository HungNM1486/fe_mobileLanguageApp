import 'package:flutter/material.dart';
import 'package:language_app/provider/language_provider.dart';
import 'package:language_app/provider/topic_provider.dart';
import 'package:provider/provider.dart';

import 'package:language_app/models/topic_model.dart';
import 'package:language_app/models/language_model.dart';
import 'package:language_app/widget/top_bar.dart';

class AddTopicScreen extends StatefulWidget {
  final TopicModel? topic;
  final bool isEditing;

  const AddTopicScreen({
    Key? key,
    this.topic,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<AddTopicScreen> createState() => _AddTopicScreenState();
}

class _AddTopicScreenState extends State<AddTopicScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _imageController = TextEditingController();

  bool _isLoading = false;

  int _selectedLanguageId = 1;
  int _selectedLevel = 1;

  final List<int> _levels = [1, 2, 3];
  final Map<int, String> _levelNames = {
    1: 'Cơ bản',
    2: 'Trung cấp',
    3: 'Nâng cao',
  };

  @override
  void initState() {
    super.initState();

    // Lấy danh sách ngôn ngữ khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LanguageProvider>(context, listen: false).fetchLanguages();
    });

    // Nếu đang chỉnh sửa topic, điền thông tin sẵn có
    if (widget.isEditing && widget.topic != null) {
      _topicController.text = widget.topic!.topic;
      _selectedLevel = int.parse(widget.topic!.level);
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _saveTopic() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLanguageId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn ngôn ngữ')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final topicProvider = Provider.of<TopicProvider>(context, listen: false);
    bool success = false;

    try {
      if (widget.isEditing && widget.topic != null) {
        // Cập nhật topic
        success = await topicProvider.updateTopic(
          id: widget.topic!.id,
          topic: _topicController.text,
          languageId: _selectedLanguageId,
          level: _selectedLevel,
          imageUrl: _imageController.text,
        );
      } else {
        // Thêm topic mới
        success = await topicProvider.createTopic(
          topic: _topicController.text,
          languageId: _selectedLanguageId,
          level: _selectedLevel,
          imageUrl: _imageController.text,
        );
      }

      setState(() {
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing
                ? 'Đã cập nhật chủ đề thành công'
                : 'Đã thêm chủ đề mới thành công'),
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
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade200, Colors.indigo.shade50],
            stops: const [0.0, 0.7],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: TopBar(
                title:
                    widget.isEditing ? "Chỉnh sửa chủ đề" : "Thêm chủ đề mới",
              ),
            ),
            Positioned(
              top: 100 * pix,
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tên chủ đề',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _topicController,
                        decoration: InputDecoration(
                          hintText: 'Nhập tên chủ đề',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tên chủ đề';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Ngôn ngữ
                      Text(
                        'Ngôn ngữ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Consumer<LanguageProvider>(
                        builder: (context, languageProvider, child) {
                          if (languageProvider.isLoading) {
                            return Center(child: CircularProgressIndicator());
                          }

                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey.shade400,
                              ),
                            ),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                              hint: Text('Chọn ngôn ngữ'),
                              isExpanded: true,
                              value: _selectedLanguageId.toString(),
                              items: languageProvider.languages
                                  .map((LanguageModel language) {
                                return DropdownMenuItem<String>(
                                  value: language.id,
                                  child: Row(
                                    children: [
                                      if (language.imageUrl.isNotEmpty)
                                        Container(
                                          width: 30,
                                          height: 20,
                                          margin: EdgeInsets.only(right: 10),
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  language.imageUrl),
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                      Text(language.name),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedLanguageId = int.parse(value!);
                                });
                              },
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 16),

                      // Cấp độ
                      Text(
                        'Cấp độ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.shade400,
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                          value: _selectedLevel.toString(),
                          isExpanded: true,
                          items: _levels.map((int level) {
                            return DropdownMenuItem<String>(
                              value: level.toString(),
                              child: Text(_levelNames[level]!),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedLevel = int.parse(value!);
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Image chủ đề (URL)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _imageController,
                        decoration: InputDecoration(
                          hintText: 'Nhập link ảnh chủ đề',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập link ảnh chủ đề';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 30),

                      // Nút lưu
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveTopic,
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
                                  widget.isEditing ? 'Cập nhật' : 'Thêm chủ đề',
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
