import 'package:flutter/material.dart';
import 'package:language_app/phu_nv/Admin/admin_home_screen.dart';
import 'package:language_app/phu_nv/LoginSignup/signup_screen.dart';
import 'package:language_app/phu_nv/SelectLanguage/start1_screen.dart';
import 'package:language_app/phu_nv/home_screen.dart';
import 'package:language_app/provider/auth_provider.dart';
import 'package:language_app/provider/user_provider.dart';
import 'package:language_app/res/imagesLA/AppImages.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:provider/provider.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        bool res = await Provider.of<AuthProvider>(context, listen: false)
            .login(_emailController.text, _passwordController.text, context);
        if (res) {
          int res2 = await Provider.of<UserProvider>(context, listen: false)
              .getUserInfo(context);
          if (res2 == 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đăng nhập thành công!')),
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminScreen(),
              ),
            );
          } else if (res2 == 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đăng nhập thành công!')),
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Homescreen(),
              ),
            );
          } else if (res2 == 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Vui lòng chọn ngôn ngữ')),
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Start1screen(),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi tải thông tin người dùng')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đăng nhập thất bại')),
          );
        }
      } catch (error) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Login Error'),
            content: Text(error.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return Consumer<AuthProvider>(builder: (context, authProvider, child) {
      if (authProvider.isLoading) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      return Scaffold(
          body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TopBar(
              title: 'Đăng nhập',
            ),
          ),
          Positioned(
            top: 100 * pix,
            left: 0,
            right: 0,
            bottom: 0 ,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 188 * pix,
                        height: 188 * pix,
                        padding: EdgeInsets.all(10 * pix),
                        child: Image.asset(AppImages.personlearn1),
                      ),
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
                          // Simple email validation
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
                      height: 16 * pix,
                    ),
                    Container(
                      width: size.width,
                      height: 20 * pix,
                      padding: EdgeInsets.only(left: 16 * pix, right: 20 * pix),
                      margin: EdgeInsets.only(bottom: 5 * pix),
                      child: Text(
                        'Mật khẩu',
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
                      margin: EdgeInsets.symmetric(horizontal: 16 * pix),
                      padding: EdgeInsets.only(left: 16 * pix),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(16 * pix),
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          labelStyle: TextStyle(
                            fontSize: 14 * pix,
                            fontFamily: 'BeVietnamPro',
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          if (value.length < 6) {
                            return 'Mật khẩu phải có ít nhất 6 ký tự';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 5 * pix,
                    ),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        width: size.width,
                        height: 20 * pix,
                        padding:
                            EdgeInsets.only(left: 16 * pix, right: 16 * pix),
                        child: Text('Quên mật khẩu?',
                            style: TextStyle(
                                fontSize: 14 * pix,
                                fontFamily: 'BeVietnamPro',
                                fontWeight: FontWeight.w500,
                                color: Colors.red[400]),
                            textAlign: TextAlign.right),
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
                          child: Text('Đăng nhập',
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
                          Text('Bạn chưa có tài khoản?',
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
                                      builder: (context) => Signupscreen()));
                            },
                            child: Text(' Đăng ký',
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
      ));
    });
  }
}
