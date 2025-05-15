import 'package:flutter/material.dart';

class DetailVocabItem extends StatelessWidget {
  const DetailVocabItem({
    super.key,
    required this.label,
    required this.content,
    required this.icon,
  });
  final String label;
  final String content;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * pix),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20 * pix,
            color: Colors.blue.shade700,
          ),
          SizedBox(width: 12 * pix),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14 * pix,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 4 * pix),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 16 * pix,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
