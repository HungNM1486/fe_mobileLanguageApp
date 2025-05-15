import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:language_app/models/exercise_model.dart';
import 'package:language_app/provider/exercise_provider.dart';
import 'package:language_app/res/imagesLA/AppImages.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:provider/provider.dart';

class DoListenscreen extends StatefulWidget {
  const DoListenscreen({super.key, required this.ex});
  final ExerciseModel ex;

  @override
  _DoListenscreenState createState() => _DoListenscreenState();
}

class _DoListenscreenState extends State<DoListenscreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final FlutterTts _tts = FlutterTts();
  double _speed = 1.0;
  bool _isPlaying = false;
  List<String?> _selectedAnswers = [];
  bool _submitted = false;
  int correctAnswers = 0;
  bool loading = false;
  List<String> _textChunks = [];
  int _currentChunkIndex = 0;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Cấu hình FlutterTts
    _configureTts();

    // Fetch dữ liệu exercise đầy đủ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExerciseProvider>(context, listen: false)
          .fetchExercise(widget.ex.id);
    });
  }

  void _configureTts() {
    _tts.setLanguage("en-US");
    _tts.setSpeechRate(_speed);
    _tts.setVolume(1.0);
    _tts.setPitch(0.9); // Giảm pitch một chút để nghe rõ hơn

    _tts.setCompletionHandler(() {
      _handleChunkCompletion();
    });

    _tts.setCancelHandler(() {
      setState(() {
        _isPlaying = false;
        _isPaused = false;
        _currentChunkIndex = 0;
        _animationController.stop();
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tts.stop();
    super.dispose();
  }

  // Phương thức để chia văn bản thành các đoạn nhỏ dựa vào dấu câu
  List<String> _splitTextIntoParts(String text) {
    // Biểu thức chính quy để tìm các câu kết thúc bằng dấu ., ?, !, ... và các dấu câu khác
    RegExp sentenceEndPattern = RegExp(r'[.!?;:]');

    List<String> chunks = [];
    int lastMatchEnd = 0;

    // Tìm các vị trí của dấu câu
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && sentenceEndPattern.hasMatch(text[i])) {
        // Thêm 1 ký tự sau dấu câu để đảm bảo dấu câu được đọc với câu trước đó
        int endPos = i + 1;

        // Đảm bảo không vượt quá độ dài của văn bản
        if (endPos > text.length) endPos = text.length;

        // Trích xuất đoạn văn bản từ vị trí cuối cùng đến dấu câu hiện tại
        String chunk = text.substring(lastMatchEnd, endPos).trim();

        if (chunk.isNotEmpty) {
          chunks.add(chunk);
        }

        // Cập nhật vị trí kết thúc của câu cuối cùng
        lastMatchEnd = endPos;
      }
    }

    // Thêm phần còn lại của văn bản nếu có
    if (lastMatchEnd < text.length) {
      String remainingText = text.substring(lastMatchEnd).trim();
      if (remainingText.isNotEmpty) {
        chunks.add(remainingText);
      }
    }

    // Nếu không tìm thấy dấu câu nào, sử dụng toàn bộ văn bản
    if (chunks.isEmpty && text.trim().isNotEmpty) {
      chunks.add(text);
    }

    return chunks;
  }

  // Xử lý khi một đoạn văn bản được đọc xong
  void _handleChunkCompletion() async {
    if (_currentChunkIndex < _textChunks.length - 1 &&
        _isPlaying &&
        !_isPaused) {
      _currentChunkIndex++;

      // Thêm delay 1 giây trước khi đọc đoạn tiếp theo
      await Future.delayed(Duration(seconds: 1));

      if (_isPlaying && !_isPaused) {
        await _tts.speak(_textChunks[_currentChunkIndex]);
      }
    } else {
      setState(() {
        _isPlaying = false;
        _currentChunkIndex = 0;
        _animationController.stop();
      });
    }
  }

  void _toggleAudio(String text) async {
    if (_isPlaying) {
      await _tts.stop();
      _animationController.stop();
      setState(() {
        _isPlaying = false;
        _isPaused = false;
        _currentChunkIndex = 0;
      });
    } else {
      // Chia văn bản thành các đoạn nhỏ dựa trên dấu câu
      _textChunks = _splitTextIntoParts(text);

      if (_textChunks.isNotEmpty) {
        await _tts.setSpeechRate(_speed);
        _currentChunkIndex = 0;
        await _tts.speak(_textChunks[_currentChunkIndex]);
        _animationController.repeat(reverse: true);
        setState(() {
          _isPlaying = true;
          _isPaused = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không có nội dung âm thanh')));
      }
    }
  }

  Future<void> createResult(ExerciseModel exercise) async {
    setState(() {
      loading = true;
    });

    final exProvider = Provider.of<ExerciseProvider>(context, listen: false);
    bool res = await exProvider.createResult(
      exercise.id,
      (correctAnswers / exercise.questions.length * 10).round(),
    );

    if (res) {
      setState(() {
        loading = false;
      });
      showResult(exercise.questions.length);
    } else {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Có lỗi xảy ra trong quá trình tạo kết quả."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _submitAnswers(ExerciseModel exercise) {
    setState(() {
      _submitted = true;
      correctAnswers = 0;
    });

    // Đếm lại số câu trả lời đúng
    for (int i = 0; i < exercise.questions.length; i++) {
      if (_selectedAnswers[i] == exercise.questions[i].answer) {
        correctAnswers++;
      }
    }

    // Gửi kết quả lên server
    createResult(exercise);
  }

  void showResult(int questionCount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          "Kết quả",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: correctAnswers == questionCount
                    ? Colors.green.withOpacity(0.1)
                    : Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    correctAnswers == questionCount
                        ? Icons.star
                        : Icons.emoji_events,
                    color: correctAnswers == questionCount
                        ? Colors.green
                        : Colors.amber,
                    size: 40,
                  ),
                  SizedBox(width: 10),
                  Text(
                    ((correctAnswers / questionCount * 10).round()).toString() +
                        " điểm",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: correctAnswers == questionCount
                          ? Colors.green
                          : Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Text(
              correctAnswers == questionCount
                  ? "Tuyệt vời! Bạn đã trả lời đúng tất cả các câu hỏi."
                  : "Bạn đã làm đúng $correctAnswers/$questionCount câu!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _submitted = false;
                      _selectedAnswers = List.filled(questionCount, null);
                      correctAnswers = 0;
                    });
                  },
                  icon: Icon(Icons.refresh),
                  label: Text("Làm lại"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back),
                  label: Text("Quay lại"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Phương thức để hiển thị văn bản đang được đọc
  void _showTranscriptDialog(String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nội dung bài nghe'),
        content: SingleChildScrollView(
          child: Text(text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Consumer<ExerciseProvider>(
      builder: (context, exerciseProvider, child) {
        // Kiểm tra xem đã fetch exercise thành công chưa
        if (exerciseProvider.isLoading || loading) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final currentExercise = exerciseProvider.exercise;
        // Khởi tạo selectedAnswers nếu chưa được khởi tạo và có questions
        if (_selectedAnswers.isEmpty) {
          _selectedAnswers =
              List.filled(currentExercise!.questions.length, null);
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
            child: Column(
              children: [
                TopBar(title: widget.ex.name, isBack: true),
                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16 * pix),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16 * pix),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(16 * pix),
                            child: Column(
                              children: [
                                Text(
                                  "Nghe đoạn hội thoại và trả lời câu hỏi",
                                  style: TextStyle(
                                    fontSize: 16 * pix,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blueGrey[800],
                                  ),
                                ),
                                SizedBox(height: 16 * pix),
                                Container(
                                  height: 220 * pix,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    image: DecorationImage(
                                      image: AssetImage(AppImages.bgdolisten),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16 * pix),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedBuilder(
                                        animation: _animationController,
                                        builder: (context, child) {
                                          return GestureDetector(
                                            onTap: () => _toggleAudio(
                                                currentExercise!.audio),
                                            child: Container(
                                              height: 60 * pix,
                                              width: 60 * pix,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.blue,
                                                    Colors.lightBlue
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.blue
                                                        .withOpacity(0.3),
                                                    spreadRadius: _isPlaying
                                                        ? 4 +
                                                            (_animationController
                                                                    .value *
                                                                4)
                                                        : 0,
                                                    blurRadius: 10,
                                                    offset: Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                _isPlaying
                                                    ? Icons.pause
                                                    : Icons.play_arrow,
                                                color: Colors.white,
                                                size: 30 * pix,
                                              ),
                                            ),
                                          );
                                        }),
                                    SizedBox(width: 16 * pix),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: DropdownButton<double>(
                                        value: _speed,
                                        underline: SizedBox(),
                                        icon: Icon(Icons.speed,
                                            color: Colors.blue),
                                        style: TextStyle(
                                          color: Colors.blueGrey[800],
                                          fontWeight: FontWeight.bold,
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            _speed = value!;
                                            _tts.setSpeechRate(_speed);
                                          });
                                        },
                                        items: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
                                            .map((speed) => DropdownMenuItem(
                                                  value: speed,
                                                  child: Text("${speed}x"),
                                                ))
                                            .toList(),
                                      ),
                                    ),
                                    SizedBox(width: 16 * pix),
                                    // Thêm nút hiển thị văn bản
                                    GestureDetector(
                                      onTap: () => _showTranscriptDialog(
                                          currentExercise!.audio),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Icon(
                                          Icons.text_fields,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24 * pix),
                          ...List.generate(currentExercise!.questions.length,
                              (index) {
                            final question = currentExercise.questions[index];
                            final isCorrect = _submitted &&
                                _selectedAnswers[index] == question.answer;
                            final isWrong = _submitted &&
                                _selectedAnswers[index] != null &&
                                _selectedAnswers[index] != question.answer;

                            return Container(
                              margin: EdgeInsets.only(bottom: 24 * pix),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(16 * pix),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10 * pix),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[100],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          "${index + 1}",
                                          style: TextStyle(
                                            fontSize: 18 * pix,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12 * pix),
                                      Expanded(
                                        child: Text(
                                          question.question,
                                          style: TextStyle(
                                            fontSize: 16 * pix,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blueGrey[800],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16 * pix),
                                  Column(
                                    children:
                                        question.options.map<Widget>((option) {
                                      bool isSelected =
                                          _selectedAnswers[index] == option;
                                      bool isCorrectAnswer =
                                          option == question.answer;

                                      Color backgroundColor = Colors.white;
                                      Color borderColor = Colors.grey[300]!;
                                      Color textColor = Colors.blueGrey[800]!;

                                      if (_submitted) {
                                        if (isCorrectAnswer) {
                                          backgroundColor = Colors.green[50]!;
                                          borderColor = Colors.green;
                                          textColor = Colors.green[800]!;
                                        } else if (isSelected) {
                                          backgroundColor = Colors.red[50]!;
                                          borderColor = Colors.red;
                                          textColor = Colors.red[800]!;
                                        }
                                      } else if (isSelected) {
                                        backgroundColor = Colors.blue[50]!;
                                        borderColor = Colors.blue;
                                        textColor = Colors.blue[800]!;
                                      }

                                      return GestureDetector(
                                        onTap: _submitted
                                            ? null
                                            : () {
                                                setState(() {
                                                  _selectedAnswers[index] =
                                                      option;
                                                });
                                              },
                                        child: Container(
                                          margin:
                                              EdgeInsets.only(bottom: 12 * pix),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12 * pix,
                                              horizontal: 16 * pix),
                                          decoration: BoxDecoration(
                                            color: backgroundColor,
                                            border: Border.all(
                                                color: borderColor, width: 1.5),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 22 * pix,
                                                height: 22 * pix,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? borderColor
                                                        : Colors.grey[400]!,
                                                    width: 2,
                                                  ),
                                                  color: isSelected
                                                      ? borderColor
                                                      : Colors.white,
                                                ),
                                                child: isSelected
                                                    ? Icon(
                                                        _submitted
                                                            ? (isCorrectAnswer
                                                                ? Icons.check
                                                                : Icons.close)
                                                            : Icons.check,
                                                        color: Colors.white,
                                                        size: 14 * pix,
                                                      )
                                                    : null,
                                              ),
                                              SizedBox(width: 12 * pix),
                                              Expanded(
                                                child: Text(
                                                  option,
                                                  style: TextStyle(
                                                    fontSize: 16 * pix,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w600
                                                        : FontWeight.normal,
                                                    color: textColor,
                                                  ),
                                                ),
                                              ),
                                              if (_submitted && isCorrectAnswer)
                                                Icon(Icons.check_circle_outline,
                                                    color: Colors.green),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  if (_submitted &&
                                      _selectedAnswers[index] != null)
                                    Container(
                                      margin: EdgeInsets.only(top: 8 * pix),
                                      padding: EdgeInsets.all(12 * pix),
                                      decoration: BoxDecoration(
                                        color: isCorrect
                                            ? Colors.green[50]
                                            : Colors.red[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isCorrect
                                              ? Colors.green[200]!
                                              : Colors.red[200]!,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isCorrect
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            color: isCorrect
                                                ? Colors.green
                                                : Colors.red,
                                            size: 20 * pix,
                                          ),
                                          SizedBox(width: 8 * pix),
                                          Expanded(
                                            child: Text(
                                              isCorrect
                                                  ? "Chính xác! Đáp án của bạn đúng."
                                                  : "Sai rồi! Đáp án đúng là: ${question.answer}\n${question.hint}",
                                              style: TextStyle(
                                                color: isCorrect
                                                    ? Colors.green[800]
                                                    : Colors.red[800],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),
                          if (!_submitted)
                            Container(
                              margin: EdgeInsets.only(bottom: 24 * pix),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_selectedAnswers
                                      .every((answer) => answer != null)) {
                                    _submitAnswers(currentExercise);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Vui lòng trả lời tất cả các câu hỏi!"),
                                        backgroundColor: Colors.amber[700],
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  minimumSize: Size(double.infinity, 56 * pix),
                                  elevation: 4,
                                ),
                                child: Text(
                                  "Kiểm tra đáp án",
                                  style: TextStyle(
                                    fontSize: 18 * pix,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          if (_submitted)
                            Container(
                              margin: EdgeInsets.only(bottom: 24 * pix),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _submitted = false;
                                    _selectedAnswers = List.filled(
                                        currentExercise!.questions.length,
                                        null);
                                    correctAnswers = 0;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  minimumSize: Size(double.infinity, 56 * pix),
                                  elevation: 4,
                                ),
                                child: Text(
                                  "Làm lại bài tập",
                                  style: TextStyle(
                                    fontSize: 18 * pix,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
