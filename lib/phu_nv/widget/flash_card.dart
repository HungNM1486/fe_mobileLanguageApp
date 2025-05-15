import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:language_app/phu_nv/widget/network_img.dart';

class FlashCard extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  final bool isFlipped;
  final Animation<double>? rotationAnimation;

  FlashCard({
    Key? key,
    required this.title,
    required this.description,
    required this.image,
    required this.isFlipped,
    this.rotationAnimation,
  }) : super(key: key);

  void _playAudio(String mes) async {
    final audioPlayer = AudioPlayer();
    final url = isFlipped
        ? "https://translate.google.com/translate_tts?ie=UTF-8&tl=vi&client=tw-ob&q=$mes"
        : 'https://translate.google.com/translate_tts?ie=UTF-8&tl=en&client=tw-ob&q=$mes';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        },
      );

      if (response.statusCode == 200) {
        await audioPlayer.play(BytesSource(response.bodyBytes));
      } else {
        print("Failed to fetch audio: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching audio: $e");
    }
  }

  String capitalizeFirst(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    final List<String> parts = title.split(",");
    return _buildCardContent(context, pix, parts);
  }

  Widget _buildCardContent(
      BuildContext context, double pix, List<String> parts) {
    return Container(
      height: 450 * pix, // Reduced height to prevent overflow
      width: 340 * pix,
      margin: EdgeInsets.only(top: 20 * pix),
      padding: EdgeInsets.only(top: 16 * pix),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * pix),
        gradient: LinearGradient(
          colors: [
            isFlipped ? Color(0xff5053FF) : Color.fromARGB(255, 255, 198, 173),
            isFlipped ? Color.fromARGB(255, 255, 198, 173) : Color(0xff5053FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: Offset(0, 5),
            blurRadius: 10,
          ),
        ],
      ),
      child: SingleChildScrollView(
        // Add ScrollView to handle overflow
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              capitalizeFirst(parts[0]),
              style: TextStyle(
                fontSize: 36 * pix,
                fontFamily: 'BeVietnamPro',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10 * pix),
            InkWell(
              onTap: () => _playAudio(title),
              child: Icon(
                Icons.volume_up,
                color: Colors.white,
                size: 48, // Slightly reduced icon size
              ),
            ),
            image == ""
                ? Text(
                    "?",
                    style: TextStyle(
                      fontSize: 120 * pix, // Reduced font size
                      color: Colors.white,
                      fontFamily: 'BeVietnamPro',
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Container(
                    height: 180 * pix, // Set fixed height for image
                    width: 180 * pix, // Set fixed width for image
                    child: NetworkImageWidget(
                      url: image,
                      width: 180,
                      height: 180,
                    ),
                  ),
            Padding(
              padding: EdgeInsets.only(
                left: 16 * pix,
                right: 16 * pix,
                top: 8 * pix,
                bottom: 8 * pix,
              ),
              child: Text(
                capitalizeFirst(description),
                style: TextStyle(
                  fontSize: 18 * pix, // Reduced font size
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            InkWell(
              onTap: () => _playAudio(description),
              child: Icon(
                Icons.volume_up,
                color: Colors.white,
                size: 32, // Reduced icon size
              ),
            ),
            SizedBox(height: 8 * pix), // Add padding at bottom
          ],
        ),
      ),
    );
  }
}
