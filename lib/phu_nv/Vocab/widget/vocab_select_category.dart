import 'package:flutter/material.dart';

class VocabSelectCategory extends StatelessWidget {
  const VocabSelectCategory({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.pix,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double pix;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12 * pix),
        padding: EdgeInsets.all(15 * pix),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32 * pix,
              color: color,
            ),
            SizedBox(width: 12 * pix),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18 * pix,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'BeVietnamPro',
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14 * pix,
                      color: Colors.grey.shade700,
                      fontFamily: 'BeVietnamPro',
                    ),
                  ),
                  Container(
                    height: 30 * pix,
                    width: double.maxFinite,
                    margin: EdgeInsets.only(
                        top: 10 * pix,
                        left: 16 * pix,
                        right: 16 * pix,
                        bottom: 5 * pix),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: color,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Chinh phục ngay",
                        style: TextStyle(
                          fontSize: 14 * pix,
                          color: color,
                          fontFamily: 'BeVietnamPro',
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
