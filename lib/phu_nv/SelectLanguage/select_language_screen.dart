import 'package:flutter/material.dart';
import 'package:language_app/phu_nv/SelectLanguage/start2_screen.dart';
import 'package:language_app/provider/language_provider.dart';
import 'package:language_app/provider/progress_provider.dart';
import 'package:language_app/provider/user_provider.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:provider/provider.dart';

class SelectLanguescreen extends StatefulWidget {
  const SelectLanguescreen({super.key});

  @override
  State<SelectLanguescreen> createState() => _SelectLanguescreenState();
}

class _SelectLanguescreenState extends State<SelectLanguescreen> {
  int _selected = 0;
  int _selectedID = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LanguageProvider>(context, listen: false).fetchLanguages();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _setLanguage() async {
    if (_selected == 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Vui lòng chọn ngôn ngữ"),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    try {
      bool res = await Provider.of<ProgressProvider>(context, listen: false)
          .createProgress(
        _selectedID,
      );
      if (res) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Cập nhật ngôn ngữ thành công"),
          duration: Duration(seconds: 2),
        ));
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Start2screen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Cập nhật ngôn ngữ thất bại"),
          duration: Duration(seconds: 2),
        ));
        print("Lỗi khi cập nhật thông tin người dùng.");
      }
    } catch (e) {
      print("Lỗi khi lưu ngôn ngữ: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
      if (languageProvider.isLoading) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              TopBar(
                title: 'Chọn ngôn ngữ',
              ),
              Container(
                height: size.height - 100 * pix,
                width: size.width,
                child: Stack(
                  children: [
                    Container(
                      height: size.height - 100 * pix,
                      width: size.width,
                      padding: EdgeInsets.only(top: 20 * pix),
                      child: ListView.builder(
                        itemCount: languageProvider.languages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(
                                bottom: 16 * pix,
                                left: 24 * pix,
                                right: 24 * pix),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selected = index + 1;
                                  _selectedID = int.tryParse(languageProvider
                                          .languages[index].id) ??
                                      0;
                                });
                              },
                              child: Container(
                                width: 327 * pix,
                                height: 62 * pix,
                                padding: EdgeInsets.all(5 * pix),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: _selected == index + 1
                                      ? Color(0xff40CEB6)
                                      : Colors.grey[300],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 52 * pix,
                                      width: 52 * pix,
                                      decoration: BoxDecoration(
                                        shape: BoxShape
                                            .circle, // Đặt hình dạng Container là hình tròn
                                      ),
                                      child: ClipOval(
                                        // Cắt hình ảnh thành hình tròn
                                        child: Image.network(
                                          languageProvider
                                              .languages[index].imageUrl,
                                          fit: BoxFit.cover,
                                          height: 52 * pix,
                                          width: 52 * pix,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Icon(
                                            Icons.error,
                                            size: 24 * pix,
                                            color: Colors.red,
                                          ), // Xử lý lỗi tải hình ảnh
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 52 * pix,
                                      width: 250 * pix,
                                      padding: EdgeInsets.only(top: 10 * pix),
                                      child: Text(
                                        languageProvider.languages[index].name,
                                        style: TextStyle(
                                            color: const Color.fromARGB(
                                                255, 0, 0, 0),
                                            fontSize: 18 * pix,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'BeVietnamPro'),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 80 * pix,
                      left: 16 * pix,
                      right: 16 * pix,
                      child: InkWell(
                        onTap: () {
                          _setLanguage();
                        },
                        child: Container(
                          width: size.width,
                          height: 56 * pix,
                          padding: EdgeInsets.only(
                              left: 16 * pix, right: 16 * pix, top: 12 * pix),
                          decoration: BoxDecoration(
                            color: Color(0xff5B7BFE),
                            borderRadius: BorderRadius.circular(16 * pix),
                          ),
                          child: Text('Tiếp tục',
                              style: TextStyle(
                                  fontSize: 20 * pix,
                                  fontFamily: 'BeVietnamPro',
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                              textAlign: TextAlign.center),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
