import 'package:flutter/material.dart';
import 'package:language_app/phu_nv/LoginSignup/login_screen.dart';
import 'package:language_app/phu_nv/LoginSignup/signup_screen2.dart';
import 'package:language_app/res/imagesLA/AppImages.dart';
import 'package:language_app/widget/top_bar.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, navigate to next signup screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Signupscreen2(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TopBar(
              title: 'Đăng ký',
              isBack: true,
            ),
          ),
          Positioned(
            top: 100 * pix,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 105 * pix,
                            height: 82 * pix,
                            padding: EdgeInsets.all(10 * pix),
                            child: Image.asset(AppImages.learnhome),
                          ),
                          Container(
                            width: size.width,
                            height: 70 * pix,
                            padding: EdgeInsets.only(top: 10 * pix),
                            child: Text(
                              'Bắt đầu học ngay thôi nào!',
                              style: TextStyle(
                                  fontSize: 22 * pix,
                                  fontFamily: 'BeVietnamPro',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: size.width,
                      height: 20 * pix,
                      padding: EdgeInsets.only(left: 16 * pix, right: 20 * pix),
                      margin: EdgeInsets.only(bottom: 5 * pix),
                      child: Text(
                        'Họ và tên đệm',
                        style: TextStyle(
                            fontSize: 14 * pix,
                            fontFamily: 'BeVietnamPro',
                            color: Colors.black),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      width: size.width,
                      height: 56 * pix,
                      margin: EdgeInsets.only(left: 16 * pix, right: 16 * pix),
                      padding: EdgeInsets.only(left: 16 * pix),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(16 * pix),
                      ),
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: 'Nhập họ của bạn',
                          labelStyle: TextStyle(
                              fontSize: 14 * pix,
                              fontFamily: 'BeVietnamPro',
                              color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập họ và tên đệm';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 16 * pix,
                    ),
                    Container(
                      width: size.width,
                      height: 20 * pix,
                      padding: EdgeInsets.only(left: 16 * pix, right: 20 * pix),
                      margin: EdgeInsets.only(bottom: 5 * pix),
                      child: Text(
                        'Tên',
                        style: TextStyle(
                            fontSize: 14 * pix,
                            fontFamily: 'BeVietnamPro',
                            color: Colors.black),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      width: size.width,
                      height: 56 * pix,
                      margin: EdgeInsets.only(left: 16 * pix, right: 16 * pix),
                      padding: EdgeInsets.only(left: 16 * pix),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(16 * pix),
                      ),
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText: 'Nhập tên của bạn',
                          labelStyle: TextStyle(
                              fontSize: 14 * pix,
                              fontFamily: 'BeVietnamPro',
                              color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tên';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 16 * pix,
                    ),
                    Container(
                      width: size.width,
                      height: 20 * pix,
                      padding: EdgeInsets.only(left: 16 * pix, right: 20 * pix),
                      margin: EdgeInsets.only(bottom: 5 * pix),
                      child: Text(
                        'Email',
                        style: TextStyle(
                            fontSize: 14 * pix,
                            fontFamily: 'BeVietnamPro',
                            color: Colors.black),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      width: size.width,
                      height: 56 * pix,
                      margin: EdgeInsets.only(left: 16 * pix, right: 16 * pix),
                      padding: EdgeInsets.only(left: 16 * pix),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(16 * pix),
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Nhập email của bạn',
                          labelStyle: TextStyle(
                              fontSize: 14 * pix,
                              fontFamily: 'BeVietnamPro',
                              color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập email';
                          }
                          final emailRegExp =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegExp.hasMatch(value)) {
                            return 'Email không hợp lệ';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 69 * pix,
                    ),
                    Padding(
                      padding: EdgeInsets.all(16 * pix),
                      child: InkWell(
                        onTap: _submitForm,
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
                    ),
                    SizedBox(
                      height: 10 * pix,
                    ),
                    Container(
                      width: size.width,
                      height: 20 * pix,
                      padding: EdgeInsets.only(left: 16 * pix, right: 16 * pix),
                      child: Text('Or',
                          style: TextStyle(
                              fontSize: 14 * pix,
                              fontFamily: 'BeVietnamPro',
                              color: Colors.black),
                          textAlign: TextAlign.center),
                    ),
                    Container(
                      width: size.width,
                      height: 56 * pix,
                      padding: EdgeInsets.only(
                          left: 66 * pix, right: 16 * pix, top: 12 * pix),
                      child: Row(
                        children: [
                          Text('Bạn đã có tài khoản?',
                              style: TextStyle(
                                  fontSize: 14 * pix,
                                  fontFamily: 'BeVietnamPro',
                                  color: Colors.black),
                              textAlign: TextAlign.center),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Loginscreen()));
                            },
                            child: Text(' Đăng nhập',
                                style: TextStyle(
                                    fontSize: 14 * pix,
                                    fontFamily: 'BeVietnamPro',
                                    color: Color(0xff5B7BFE)),
                                textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
