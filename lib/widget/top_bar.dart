import 'package:flutter/material.dart';

class TopBar extends StatefulWidget {
  const TopBar({super.key, required this.title, this.isBack = true});
  final String title;
  final bool isBack;

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Container(
      height: 100 * pix,
      width: size.width,
      padding: EdgeInsets.only(top: 10 * pix),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xff43AAFF), Color(0xff5053FF)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: pix * 50,
            margin: EdgeInsets.only(top: 16 * pix),
            child: widget.isBack
                ? IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  )
                : SizedBox(),
          ),
          Expanded(
            child: Container(
              height: 80 * pix,
              padding: EdgeInsets.only(top: 30 * pix, right: 50 * pix),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24 * pix,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'BeVietnamPro',
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
