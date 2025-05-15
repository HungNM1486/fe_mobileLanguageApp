import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final double pix;

  const SectionTitle({super.key, required this.title, required this.pix});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8 * pix),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18 * pix,
          fontFamily: 'BeVietnamPro',
          fontWeight: FontWeight.bold,
          color: const Color(0xff5B7BFE),
        ),
      ),
    );
  }
}