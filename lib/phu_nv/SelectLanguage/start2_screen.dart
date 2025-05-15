import 'package:flutter/material.dart';
import 'package:language_app/phu_nv/home_screen.dart';
import 'package:language_app/res/imagesLA/AppImages.dart';
import 'package:language_app/widget/top_bar.dart';

class Start2screen extends StatefulWidget {
  const Start2screen({super.key});

  @override
  State<Start2screen> createState() => _Start2screenState();
}

class _Start2screenState extends State<Start2screen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            TopBar(
              title: 'Học ngay thôi',
            ),
            Center(
              child: Container(
                height: 120 * pix,
                width: size.width - 32 * pix,
                padding: EdgeInsets.only(top: 20 * pix, left: 28 * pix),
                child: Text(
                  'Tuyệt vời! Cùng bắt đầu nào!',
                  style: TextStyle(
                      fontSize: 36 * pix,
                      fontFamily: 'BeVietnamPro',
                      color: Color(0xff07A0BF),
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            SizedBox(
              height: 16 * pix,
            ),
            Center(
              child: Container(
                width: 332 * pix,
                height: 351 * pix,
                padding: EdgeInsets.all(10 * pix),
                child: Image.asset(AppImages.personlearn4),
              ),
            ),
            SizedBox(
              height: 30 * pix,
            ),
            Padding(
              padding: EdgeInsets.all(16 * pix),
              child: InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Homescreen()));
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
                  child: Text('Bắt đầu',
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
          ],
        ),
      ),
    );
  }
}
