import 'package:flutter/material.dart';
import 'widgets/friend_suggestion.dart';
import 'package:language_app/widget/top_bar.dart';

class FindFrSreen extends StatelessWidget {
  const FindFrSreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.white,
          ],
        ),
      ),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 100 * pix,
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: _buildMainContent(context, size, pix),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: TopBar(title: 'Tìm bạn bè'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, Size size, double pix) {
    return Padding(
      padding: EdgeInsets.all(16.0 * pix),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tìm bạn học cùng",
            style: TextStyle(
              fontSize: 22 * pix,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          SizedBox(height: 8 * pix),
          Text(
            "Kết nối với những người học khác để cùng tiến bộ",
            style: TextStyle(
              fontSize: 14 * pix,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 20 * pix),
          _SearchBar(pix: pix),
          SizedBox(height: 24 * pix),
          _buildFriendsSuggestionHeader(pix),
          SizedBox(height: 10 * pix),
          FriendSuggestionList(size: size, pix: pix),
        ],
      ),
    );
  }

  Widget _buildFriendsSuggestionHeader(double pix) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Gợi ý kết bạn",
          style: TextStyle(
            fontSize: 18 * pix,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final double pix;

  const _SearchBar({required this.pix});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm bạn bè...',
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14 * pix,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.blue.shade400,
            size: 22 * pix,
          ),
          suffixIcon: Container(
            margin: EdgeInsets.all(8 * pix),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8 * pix),
            ),
            child: Icon(
              Icons.filter_list,
              color: Colors.blue.shade700,
              size: 18 * pix,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0 * pix),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: 14.0 * pix,
            horizontal: 16.0 * pix,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0 * pix),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0 * pix),
            borderSide: BorderSide(color: Colors.blue.shade300, width: 1.5),
          ),
        ),
      ),
    );
  }
}
