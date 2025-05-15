import 'package:flutter/material.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pix = MediaQuery.of(context).size.width / 375;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ngôn ngữ'),
        backgroundColor: const Color(0xff5B7BFE),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'Tính năng đang phát triển',
          style: TextStyle(
            fontSize: 18 * pix,
            fontFamily: 'BeVietnamPro',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
