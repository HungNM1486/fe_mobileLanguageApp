import 'package:flutter/material.dart';
import 'package:language_app/widget/top_bar.dart';
import 'dart:async';
import 'vocabulary_summary_screen.dart';

class VocabularyGamePlayScreen extends StatefulWidget {
  final String topic;
  const VocabularyGamePlayScreen({super.key, required this.topic});

  @override
  State<VocabularyGamePlayScreen> createState() =>
      _VocabularyGamePlayScreenState();
}

class _VocabularyGamePlayScreenState extends State<VocabularyGamePlayScreen> {
  int currentGame = 1;
  int totalScore = 0;
  int gameTime = 0;

  @override
  void initState() {
    super.initState();
    _startGameTimer();
  }

  void _startGameTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => gameTime++);
    });
  }

  void _nextGame(int score) {
    setState(() {
      totalScore += score;
      currentGame++;
    });
  }

  void _showCongratsDialog(int gameNumber, int score) {
    final pix = (MediaQuery.of(context).size.width / 375).clamp(0.8, 1.2);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16 * pix)),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E2F)
            : Colors.white,
        child: Padding(
          padding: EdgeInsets.all(20 * pix),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.celebration,
                  size: 60 * pix, color: const Color(0xFFFFD700)),
              SizedBox(height: 16 * pix),
              Text(
                'Chúc mừng bạn hoàn thành Game $gameNumber!',
                style: TextStyle(
                  fontSize: 20 * pix,
                  fontFamily: 'BeVietnamPro',
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF1C2526),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8 * pix),
              Text(
                'Điểm: $score',
                style: TextStyle(
                  fontSize: 18 * pix,
                  fontFamily: 'BeVietnamPro',
                  color: const Color(0xFF10B981),
                ),
              ),
              SizedBox(height: 24 * pix),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _nextGame(score);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal: 24 * pix, vertical: 12 * pix),
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12 * pix)),
                  elevation: 0,
                ),
                child: Text(
                  gameNumber < 3
                      ? 'Bắt đầu Game ${gameNumber + 1}'
                      : 'Xem Tổng Kết',
                  style: TextStyle(
                    fontSize: 16 * pix,
                    fontFamily: 'BeVietnamPro',
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pix = MediaQuery.of(context).size.width / 375;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Widget currentGameWidget;
    switch (currentGame) {
      case 1:
        currentGameWidget =
            Game1(onComplete: (score) => _showCongratsDialog(1, score));
        break;
      case 2:
        currentGameWidget =
            Game2(onComplete: (score) => _showCongratsDialog(2, score));
        break;
      case 3:
        currentGameWidget = Game3(onComplete: (score) {
          totalScore += score;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  VocabularySummaryScreen(score: totalScore, time: gameTime),
            ),
          );
        });
        break;
      default:
        currentGameWidget = const SizedBox();
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade200, Colors.indigo.shade50],
            stops: const [0.0, 0.7],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: TopBar(title: 'Luyện Tập - ${widget.topic}')),
            Positioned(
              top: 110 * pix,
              left: 16 * pix,
              right: 16 * pix,
              bottom: 16 * pix,
              child: Column(
                children: [
                  // Progress bar
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 24 * pix, vertical: 8 * pix),
                    child: LinearProgressIndicator(
                      value: currentGame / 3,
                      backgroundColor: isDarkMode
                          ? Colors.grey[700]
                          : const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF10B981)),
                      minHeight: 4 * pix,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 16 * pix),
                    child: Row(
                      children: [
                        Icon(Icons.timer,
                            size: 20 * pix, color: const Color(0xFFD97706)),
                        SizedBox(width: 4 * pix),
                        Text(
                          '${gameTime ~/ 60}:${(gameTime % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 16 * pix,
                            fontFamily: 'BeVietnamPro',
                            color: const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: currentGameWidget),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Game 1: Nối từ - Đã sửa để ô to hơn
class Game1 extends StatefulWidget {
  final Function(int) onComplete;
  const Game1({super.key, required this.onComplete});

  @override
  State<Game1> createState() => _Game1State();
}

class _Game1State extends State<Game1> {
  List<Map<String, dynamic>> words = [
    {'en': 'Dog', 'vi': 'Chó', 'visible': true},
    {'en': 'Cat', 'vi': 'Mèo', 'visible': true},
    {'en': 'Bird', 'vi': 'Chim', 'visible': true},
    {'en': 'Fish', 'vi': 'Cá', 'visible': true},
    {'en': 'Horse', 'vi': 'Ngựa', 'visible': true},
  ];
  List<int?> selected = [null, null];
  int score = 0;
  bool isWrong = false;

  void _checkPair() {
    if (selected[0] != null && selected[1] != null) {
      final enIdx = selected[0]! ~/ 2;
      final viIdx = selected[1]! ~/ 2;
      if (words[enIdx]['en'] == 'Dog' && words[viIdx]['vi'] == 'Chó' ||
          words[enIdx]['en'] == 'Cat' && words[viIdx]['vi'] == 'Mèo' ||
          words[enIdx]['en'] == 'Bird' && words[viIdx]['vi'] == 'Chim' ||
          words[enIdx]['en'] == 'Fish' && words[viIdx]['vi'] == 'Cá' ||
          words[enIdx]['en'] == 'Horse' && words[viIdx]['vi'] == 'Ngựa') {
        setState(() {
          words[enIdx]['visible'] = false;
          words[viIdx]['visible'] = false;
          score += 20;
          selected = [null, null];
          isWrong = false;
        });
        if (words.every((w) => !w['visible'])) widget.onComplete(score);
      } else {
        setState(() => isWrong = true);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted)
            setState(() {
              selected = [null, null];
              isWrong = false;
            });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pix = (MediaQuery.of(context).size.width / 375).clamp(0.8, 1.2);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.all(16 * pix),
      child: Column(
        children: [
          Text(
            'Game 1: Nối Từ',
            style: TextStyle(
              fontSize: 20 * pix,
              fontFamily: 'BeVietnamPro',
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : const Color(0xFF1C2526),
            ),
          ),
          SizedBox(height: 16 * pix),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16 * pix),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Giảm số cột để ô to hơn
                crossAxisSpacing: 16 * pix,
                mainAxisSpacing: 16 * pix,
                childAspectRatio: 1.5, // Tăng tỷ lệ kích thước ô
              ),
              itemCount: words.length * 2,
              itemBuilder: (context, index) {
                final wordIndex = index ~/ 2;
                final isEnglish = index % 2 == 0;
                final word = words[wordIndex];

                if (!word['visible']) return const SizedBox.shrink();

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selected[0] == null) {
                        selected[0] = index;
                      } else if (selected[1] == null && selected[0] != index) {
                        selected[1] = index;
                        _checkPair();
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected.contains(index)
                          ? const Color(0xFF3B82F6).withOpacity(0.3)
                          : isDarkMode
                              ? Colors.grey[800]
                              : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12 * pix),
                      border: Border.all(
                        color: isWrong && selected.contains(index)
                            ? Colors.red
                            : Colors.transparent,
                        width: 2 * pix,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        isEnglish ? word['en'] : word['vi'],
                        style: TextStyle(
                          fontSize: 24 * pix, // Tăng kích thước chữ
                          fontFamily: 'BeVietnamPro',
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF1C2526),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isWrong)
            Padding(
              padding: EdgeInsets.only(top: 16 * pix),
              child: Text(
                'Sai rồi, thử lại nhé!',
                style: TextStyle(
                  fontSize: 16 * pix,
                  fontFamily: 'BeVietnamPro',
                  color: Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Game 2: Trộn từ - Đã sửa để clear input khi tiếp tục
class Game2 extends StatefulWidget {
  final Function(int) onComplete;
  const Game2({super.key, required this.onComplete});

  @override
  State<Game2> createState() => _Game2State();
}

class _Game2State extends State<Game2> {
  final List<String> words = ['Apple', 'Banana', 'Orange', 'Grape'];
  int currentWordIndex = 0;
  String scrambled = '';
  final TextEditingController _controller = TextEditingController();
  int score = 0;

  @override
  void initState() {
    super.initState();
    _scrambleWord();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrambleWord() {
    final word = words[currentWordIndex];
    scrambled = (word.split('')..shuffle()).join();
    _controller.clear(); // Clear input khi chuẩn bị từ mới
  }

  void _checkWord() {
    if (_controller.text.trim().toLowerCase() ==
        words[currentWordIndex].toLowerCase()) {
      setState(() {
        score += 25;
        currentWordIndex++;
        if (currentWordIndex < words.length) {
          _scrambleWord();
        } else {
          widget.onComplete(score);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pix = (MediaQuery.of(context).size.width / 375).clamp(0.8, 1.2);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.all(24 * pix),
      child: Column(
        children: [
          Text(
            'Game 2: Trộn Từ',
            style: TextStyle(
              fontSize: 20 * pix,
              fontFamily: 'BeVietnamPro',
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : const Color(0xFF1C2526),
            ),
          ),
          SizedBox(height: 24 * pix),
          if (currentWordIndex < words.length) ...[
            Card(
              color: isDarkMode ? const Color(0xFF1E1E2F) : Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12 * pix),
                side: BorderSide(
                    color: isDarkMode
                        ? Colors.grey[800]!
                        : const Color(0xFFE5E7EB)),
              ),
              child: Padding(
                padding: EdgeInsets.all(16 * pix),
                child: Column(
                  children: [
                    Text(
                      'Sắp xếp lại: $scrambled',
                      style: TextStyle(
                        fontSize: 18 * pix,
                        fontFamily: 'BeVietnamPro',
                        color:
                            isDarkMode ? Colors.white : const Color(0xFF1C2526),
                      ),
                    ),
                    SizedBox(height: 16 * pix),
                    TextField(
                      controller: _controller,
                      style: TextStyle(
                        color:
                            isDarkMode ? Colors.white : const Color(0xFF1C2526),
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDarkMode
                            ? Colors.grey[800]
                            : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * pix),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'Nhập từ',
                        hintStyle: TextStyle(
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600]),
                      ),
                    ),
                    SizedBox(height: 16 * pix),
                    ElevatedButton(
                      onPressed: _checkWord,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 24 * pix, vertical: 12 * pix),
                        backgroundColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12 * pix)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Kiểm Tra',
                        style: TextStyle(
                          fontSize: 16 * pix,
                          fontFamily: 'BeVietnamPro',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Game 3: Thử thách nghe - Đã sửa để clear input khi tiếp tục
class Game3 extends StatefulWidget {
  final Function(int) onComplete;
  const Game3({super.key, required this.onComplete});

  @override
  State<Game3> createState() => _Game3State();
}

class _Game3State extends State<Game3> {
  final List<String> words = ['Hello', 'World', 'Flutter', 'Dart'];
  int currentWordIndex = 0;
  final TextEditingController _controller = TextEditingController();
  bool isChecked = false;
  bool isCorrect = false;
  int score = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playAudio() {
    print('Playing: ${words[currentWordIndex]}');
  }

  void _checkAnswer() {
    setState(() {
      isChecked = true;
      isCorrect = _controller.text.trim().toLowerCase() ==
          words[currentWordIndex].toLowerCase();
      if (isCorrect) score += 30;
    });
  }

  void _nextWord() {
    setState(() {
      currentWordIndex++;
      isChecked = false;
      _controller.clear(); // Clear input khi chuyển từ
      if (currentWordIndex >= words.length) widget.onComplete(score);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pix = (MediaQuery.of(context).size.width / 375).clamp(0.8, 1.2);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.all(24 * pix),
      child: Column(
        children: [
          Text(
            'Game 3: Thử Thách Nghe',
            style: TextStyle(
              fontSize: 20 * pix,
              fontFamily: 'BeVietnamPro',
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : const Color(0xFF1C2526),
            ),
          ),
          SizedBox(height: 24 * pix),
          if (currentWordIndex < words.length) ...[
            Card(
              color: isDarkMode ? const Color(0xFF1E1E2F) : Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12 * pix),
                side: BorderSide(
                    color: isDarkMode
                        ? Colors.grey[800]!
                        : const Color(0xFFE5E7EB)),
              ),
              child: Padding(
                padding: EdgeInsets.all(16 * pix),
                child: Column(
                  children: [
                    IconButton(
                      onPressed: _playAudio,
                      icon: Icon(Icons.volume_up,
                          size: 40 * pix, color: const Color(0xFF3B82F6)),
                    ),
                    SizedBox(height: 16 * pix),
                    TextField(
                      controller: _controller,
                      enabled: !isChecked || !isCorrect,
                      style: TextStyle(
                        color:
                            isDarkMode ? Colors.white : const Color(0xFF1C2526),
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDarkMode
                            ? Colors.grey[800]
                            : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * pix),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'Điền từ bạn nghe được',
                        hintStyle: TextStyle(
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600]),
                      ),
                    ),
                    SizedBox(height: 16 * pix),
                    ElevatedButton(
                      onPressed:
                          isChecked && isCorrect ? _nextWord : _checkAnswer,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 24 * pix, vertical: 12 * pix),
                        backgroundColor: isChecked
                            ? (isCorrect ? const Color(0xFF10B981) : Colors.red)
                            : const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12 * pix)),
                        elevation: 0,
                      ),
                      child: Text(
                        isChecked
                            ? (isCorrect ? 'Tiếp Tục' : 'Kiểm Tra Lại')
                            : 'Kiểm Tra',
                        style: TextStyle(
                          fontSize: 16 * pix,
                          fontFamily: 'BeVietnamPro',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
