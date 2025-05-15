import 'package:flutter/material.dart';
import 'package:language_app/phu_nv/LoginSignup/login_screen.dart';
import 'package:language_app/provider/auth_provider.dart';
import 'package:language_app/res/imagesLA/AppImages.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:provider/provider.dart';

class Signupscreen2 extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;

  const Signupscreen2({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  @override
  State<Signupscreen2> createState() => _Signupscreen2State();
}

class _Signupscreen2State extends State<Signupscreen2> {
  bool _obscureText1 = true;
  bool _obscureText2 = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        bool res = await Provider.of<AuthProvider>(context, listen: false)
            .signup(
                firstName: widget.firstName,
                lastName: widget.lastName,
                email: widget.email,
                password: _passwordController.text,
                context: context);
        if (res) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đăng ký thành công!'),
              duration: Duration(seconds: 2),
            ),
          );
          _passwordController.clear();
          _confirmPasswordController.clear();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Loginscreen(),
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Đăng ký không thành công'),
              content: Text('Vui lòng kiểm tra lại thông tin của bạn.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      } catch (error) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Register Error'),
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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TopBar(title: 'Đăng ký', isBack: true),
              Center(
                child: Container(
                  width: 175 * pix,
                  height: 180 * pix,
                  margin: EdgeInsets.only(top: 20 * pix, left: 20 * pix),
                  padding: EdgeInsets.all(10 * pix),
                  child: Image.asset(AppImages.personlearn2),
                ),
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
                  obscureText: _obscureText1,
                  decoration: InputDecoration(
                    labelText: 'Nhập mật khẩu',
                    labelStyle: TextStyle(
                      fontSize: 14 * pix,
                      fontFamily: 'BeVietnamPro',
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText1 ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText1 = !_obscureText1;
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
                    // Check for a mix of letters and numbers
                    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
                    final hasNumber = RegExp(r'[0-9]').hasMatch(value);
                    if (!hasLetter || !hasNumber) {
                      return 'Mật khẩu phải chứa cả chữ và số';
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
                  'Xác nhận mật khẩu',
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
                  controller: _confirmPasswordController,
                  obscureText: _obscureText2,
                  decoration: InputDecoration(
                    labelText: 'Nhập lại mật khẩu',
                    labelStyle: TextStyle(
                      fontSize: 14 * pix,
                      fontFamily: 'BeVietnamPro',
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText2 ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText2 = !_obscureText2;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng xác nhận mật khẩu';
                    }
                    if (value != _passwordController.text) {
                      return 'Mật khẩu không khớp';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(
                height: 89 * pix,
              ),
              Padding(
                padding: EdgeInsets.all(16 * pix),
                child: InkWell(
                  onTap: _submitForm,
                  child: Container(
                    width: size.width,
                    height: 56 * pix,
                    margin: EdgeInsets.only(top: 16 * pix),
                    padding: EdgeInsets.only(
                        left: 16 * pix, right: 16 * pix, top: 12 * pix),
                    decoration: BoxDecoration(
                      color: Color(0xff5B7BFE),
                      borderRadius: BorderRadius.circular(16 * pix),
                    ),
                    child: Text('Đăng ký',
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
    );
  }
}
