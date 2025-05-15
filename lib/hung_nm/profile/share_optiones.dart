import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:clipboard/clipboard.dart';

class ShareOptions {
  // Hiển thị modal bottom sheet chứa mã QR và tùy chọn chia sẻ
  static void showShareOptions(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = (size.width / 375).clamp(0.8, 1.2);
    const String inviteLink =
        'https://example.com/invite/abc123'; // Đường dẫn mẫu

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20 * pix),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20 * pix),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Chia sẻ mã QR',
                style: TextStyle(
                  fontSize: 18 * pix,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20 * pix),
              QrImageView(
                data: inviteLink,
                version: QrVersions.auto,
                size: 150 * pix,
                backgroundColor: Colors.grey[200]!,
                padding: EdgeInsets.all(10 * pix),
              ),
              SizedBox(height: 20 * pix),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareButton(
                    icon: Icons.message,
                    label: 'Tin nhắn',
                    color: const Color(0xff5B7BFE),
                    onTap: () {
                      Navigator.pop(context);
                      Share.share('Mời bạn tham gia: $inviteLink',
                          subject: 'Chia sẻ qua tin nhắn');
                    },
                    pix: pix,
                  ),
                  _buildShareButton(
                    icon: Icons.email,
                    label: 'Email',
                    color: const Color(0xff5B7BFE),
                    onTap: () {
                      Navigator.pop(context);
                      Share.share('Mời bạn tham gia: $inviteLink',
                          subject: 'Chia sẻ qua email');
                    },
                    pix: pix,
                  ),
                  _buildShareButton(
                    icon: Icons.copy,
                    label: 'Sao chép',
                    color: const Color(0xff5B7BFE),
                    onTap: () async {
                      await FlutterClipboard.copy(inviteLink);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã sao chép đường dẫn'),
                            backgroundColor: const Color(0xff5B7BFE),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    },
                    pix: pix,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildShareButton({
    required IconData icon,
    required String label,
    required Color color,
    required Function() onTap,
    required double pix,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10 * pix),
      child: Padding(
        padding: EdgeInsets.all(10 * pix),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(10 * pix),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24 * pix,
                color: color,
              ),
            ),
            SizedBox(height: 8 * pix),
            Text(
              label,
              style: TextStyle(
                fontSize: 12 * pix,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
