import 'package:flutter/material.dart';
import 'package:language_app/provider/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:language_app/models/language_model.dart';
import 'package:language_app/widget/top_bar.dart';

class AddLanguageScreen extends StatefulWidget {
  final LanguageModel? language;
  final bool isEditing;

  const AddLanguageScreen({
    Key? key,
    this.language,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<AddLanguageScreen> createState() => _AddLanguageScreenState();
}

class _AddLanguageScreenState extends State<AddLanguageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _flagController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Nếu đang chỉnh sửa ngôn ngữ, điền thông tin sẵn có
    if (widget.isEditing && widget.language != null) {
      _nameController.text = widget.language!.name;
      _flagController.text = widget.language!.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _flagController.dispose();
    super.dispose();
  }

  Future<void> _saveLanguage() async {
    // Kiểm tra ít nhất một trường có giá trị khi cập nhật
    if (widget.isEditing && 
        _nameController.text.isEmpty && 
        _flagController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập ít nhất một trường để cập nhật'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Kiểm tra form khi tạo mới
    if (!widget.isEditing && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    bool success = false;

    if (widget.isEditing && widget.language != null) {
      // Cập nhật ngôn ngữ
      success = await languageProvider.updateLanguage(
        id: int.parse(widget.language!.id),
        name: _nameController.text.isNotEmpty 
            ? _nameController.text 
            : widget.language!.name,
        flagUrl: _flagController.text.isNotEmpty 
            ? _flagController.text 
            : widget.language!.imageUrl,
      );
    } else {
      // Thêm ngôn ngữ mới
      success = await languageProvider.createLanguage(
        name: _nameController.text,
        flagUrl: _flagController.text,
      );
    }

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditing
              ? 'Đã cập nhật ngôn ngữ thành công'
              : 'Đã thêm ngôn ngữ mới thành công'),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lỗi: Không thể lưu ngôn ngữ'),
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
                title: widget.isEditing
                    ? "Chỉnh sửa ngôn ngữ"
                    : "Thêm ngôn ngữ mới",
              ),
            ),
            Positioned(
              top: 100 * pix,
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tên ngôn ngữ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Nhập tên ngôn ngữ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        validator: (value) {
                          if (!widget.isEditing && 
                              (value == null || value.isEmpty)) {
                            return 'Vui lòng nhập tên ngôn ngữ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Link ảnh ngôn ngữ
                      const Text(
                        'Link ảnh ngôn ngữ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _flagController,
                        decoration: InputDecoration(
                          hintText: 'Nhập link ảnh ngôn ngữ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        validator: (value) {
                          if (!widget.isEditing && 
                              (value == null || value.isEmpty)) {
                            return 'Vui lòng nhập link ảnh ngôn ngữ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),

                      // Nút lưu
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveLanguage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  widget.isEditing
                                      ? 'Cập nhật'
                                      : 'Thêm ngôn ngữ',
                                  style: const TextStyle(fontSize: 16),
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