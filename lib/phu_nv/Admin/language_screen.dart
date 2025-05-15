import 'package:flutter/material.dart';
import 'package:language_app/phu_nv/Admin/add_language_screen.dart';
import 'package:language_app/provider/language_provider.dart';
import 'package:provider/provider.dart';

import 'package:language_app/widget/top_bar.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  @override
  void initState() {
    super.initState();
    // Khởi tạo và lấy danh sách ngôn ngữ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final languageProvider =
          Provider.of<LanguageProvider>(context, listen: false);
      languageProvider.fetchLanguages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddLanguageScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Thêm ngôn ngữ mới',
      ),
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
                title: "Quản lý ngôn ngữ",
              ),
            ),
            Positioned(
              top: 100 * pix,
              left: 0,
              right: 0,
              bottom: 0,
              child: Consumer<LanguageProvider>(
                builder: (context, languageProvider, child) {
                  if (languageProvider.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (languageProvider.languages.isEmpty) {
                    return Center(
                      child: Text(
                        'Không có ngôn ngữ nào. Hãy thêm ngôn ngữ mới!',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: languageProvider.languages.length,
                    itemBuilder: (context, index) {
                      final language = languageProvider.languages[index];
                      return Dismissible(
                        key: Key(language.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Xác nhận"),
                                content: Text(
                                  "Bạn có chắc muốn xóa ngôn ngữ '${language.name}'?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text("Hủy"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text("Xóa"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) async {
                          bool res = await languageProvider
                              .deleteLanguage(int.parse(language.id));
                          if (res) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Đã xóa ngôn ngữ '${language.name}'",
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Lỗi: Không thể xóa ngôn ngữ '${language.name}'",
                                ),
                              ),
                            );
                          }
                        },
                        child: Card(
                          elevation: 4,
                          margin: EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                language.imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey[500],
                                    ),
                                  );
                                },
                              ),
                            ),
                            title: Text(
                              language.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddLanguageScreen(
                                      language: language,
                                      isEditing: true,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
