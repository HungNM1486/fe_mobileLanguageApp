import 'package:flutter/material.dart';

Future<bool> showLogoutDialog(BuildContext context) async {
  final size = MediaQuery.of(context).size;
  final pix = size.width / 375;

  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16 * pix),
          ),
          title: Text(
            'Đăng xuất',
            style: TextStyle(
              fontSize: 18 * pix,
              fontWeight: FontWeight.bold,
              color: const Color(0xff5B7BFE),
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản của mình?',
            style: TextStyle(
              fontSize: 14 * pix,
              color: Colors.grey[800],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Hủy',
                style: TextStyle(
                  fontSize: 14 * pix,
                  color: Colors.grey[600],
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Đăng xuất',
                style: TextStyle(
                  fontSize: 14 * pix,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ) ??
      false;
}