import 'package:flutter/material.dart';

class SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final double pix;
  final Color? color;

  const SettingItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
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
      trailing: Icon(Icons.arrow_forward_ios, size: 16 * pix, color: Colors.grey),
      onTap: onTap,
    );
  }
}