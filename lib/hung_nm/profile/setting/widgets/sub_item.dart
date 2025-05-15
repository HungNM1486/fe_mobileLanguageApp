import 'package:flutter/material.dart';

class SubItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final double pix;
  final Color? color;

  const SubItem({
    super.key,
    required this.title,
    required this.icon,
    required this.pix,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 24 * pix, color: color ?? Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16 * pix,
          fontFamily: 'BeVietnamPro',
          color: color ?? Colors.black,
        ),
      ),
      onTap: () {
        // Logic xử lý từng mục (có thể thêm sau)
      },
    );
  }
}