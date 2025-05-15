import 'package:flutter/material.dart';

import 'package:language_app/hong_nm/level_screen.dart';
import 'package:language_app/res/imagesLA/AppImages.dart';

class EXSection extends StatefulWidget {
  const EXSection({
    super.key,
    required this.type,
  });
  final String type;

  @override
  State<EXSection> createState() => _EXSectionState();
}

class _EXSectionState extends State<EXSection> {
  String getImgURL() {
    switch (widget.type) {
      case "Ngữ pháp":
        return AppImages.imgnguphap;
      case "Nghe":
        return AppImages.imgnghe;
      case "Phát âm":
        return AppImages.imgnoi;
      default:
        return AppImages.imgnguphap;
    }
  }

  VoiCallBack() {
    if (widget.type == "Ngữ pháp") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Levelscreen(
            type: "Ngữ pháp",
          ),
        ),
      );
    } else if (widget.type == "Nghe") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Levelscreen(type: "Nghe"),
        ),
      );
    } else if (widget.type == "Phát âm") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Levelscreen(type: "Phát âm"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8 * pix, vertical: 4 * pix),
      width: 180 * pix,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * pix),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 35, 0, 189).withOpacity(0.2),
            offset: const Offset(0, 5),
            blurRadius: 10,
          ),
        ],
        border: Border.all(
          width: 0.5 * pix,
          color: const Color.fromARGB(255, 52, 194, 255),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24 * pix),
                topRight: Radius.circular(24 * pix),
              ),
              child: Container(
                height: 136 * pix,
                width: 180 * pix,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(getImgURL()),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 16 * pix,
                right: 16 * pix,
                top: 8 * pix,
                bottom: 8 * pix,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.type,
                    style: TextStyle(
                      fontSize: 18 * pix,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'BeVietnamPro',
                      color: const Color(0xff165598),
                    ),
                  ),
                  SizedBox(height: 5 * pix),
                  Row(
                    children: [
                      Spacer(),
                      InkWell(
                        onTap: () {
                          VoiCallBack();
                        },
                        child: Container(
                          height: 30 * pix,
                          width: 30 * pix,
                          decoration: BoxDecoration(
                            color: const Color(0xff4F46E5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18 * pix,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
