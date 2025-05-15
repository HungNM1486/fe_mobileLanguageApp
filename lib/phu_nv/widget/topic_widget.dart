import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:language_app/phu_nv/Vocab/vocabulary_screen.dart';
import 'package:language_app/models/topic_model.dart';

class Topicwidget extends StatefulWidget {
  const Topicwidget({super.key, required this.topic});
  final TopicModel topic;

  @override
  State<Topicwidget> createState() => _TopicwidgetState();
}

String capitalizeFirst(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1).toLowerCase();
}

class _TopicwidgetState extends State<Topicwidget> {
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
              child: Stack(
                children: [
                  Container(
                    height: 136 * pix,
                    width: 180 * pix,
                    child: Image.network(
                      widget.topic.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 10 * pix,
                    right: 10 * pix,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8 * pix,
                        vertical: 4 * pix,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12 * pix),
                      ),
                      child: Text(
                        '${widget.topic.numbervocabulary} từ',
                        style: TextStyle(
                          fontSize: 12 * pix,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff4F46E5),
                        ),
                      ),
                    ),
                  ),
                  if (widget.topic.isDone)
                    Positioned(
                      top: 10 * pix,
                      left: 10 * pix,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8 * pix,
                          vertical: 4 * pix,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(12 * pix),
                        ),
                        child: Text(
                          'Đã học',
                          style: TextStyle(
                            fontSize: 12 * pix,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff4F46E5),
                          ),
                        ),
                      ),
                    ),
                ],
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
                  AutoSizeText(
                    capitalizeFirst(widget.topic.topic),
                    style: TextStyle(
                      fontSize: 16 * pix,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'BeVietnamPro',
                      color: const Color(0xff165598),
                    ),
                    maxLines: 1, // hoặc nhiều dòng nếu cần
                    minFontSize: 10, // không nhỏ hơn 10
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5 * pix),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8 * pix,
                          vertical: 4 * pix,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xff4F46E5).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8 * pix),
                        ),
                        child: Text(
                          widget.topic.translevel(),
                          style: TextStyle(
                            fontSize: 10 * pix,
                            fontFamily: 'BeVietnamPro',
                            color: const Color(0xff4F46E5),
                          ),
                        ),
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VocabularyScreen(
                                topic: widget.topic,
                              ),
                            ),
                          );
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
