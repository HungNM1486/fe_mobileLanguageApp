import 'package:flutter/material.dart';
import 'package:language_app/models/exercise_model.dart';
import 'package:language_app/models/question_model.dart';
import 'package:language_app/provider/exercise_provider.dart';
import 'package:language_app/provider/question_provider.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:provider/provider.dart';

class DoGrammarscreen extends StatefulWidget {
  const DoGrammarscreen({super.key, required this.exercise});
  final ExerciseModel exercise;
  @override
  State<DoGrammarscreen> createState() => _DoGrammarscreenState();
}

class _DoGrammarscreenState extends State<DoGrammarscreen> {
  int currentQuestion = 0;
  int correctAnswers = 0;
  String selectedAnswer = "";
  bool answerChecked = false;
  bool loading = false;

  late List<QuestionModel> questions;

  @override
  void initState() {
    super.initState();
    questions = widget.exercise.questions;
  }

  void checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      answerChecked = true;
      if (answer == questions[currentQuestion].answer) {
        correctAnswers++;
      }
      Future.delayed(Duration(seconds: 1), () {
        if (currentQuestion < questions.length - 1) {
          setState(() {
            currentQuestion++;
            selectedAnswer = "";
            answerChecked = false;
          });
        } else {
          createResult(correctAnswers);
        }
      });
    });
  }

  Future<void> createResult(int) async {
    setState(() {
      loading = true;
    });
    final exProvider = Provider.of<ExerciseProvider>(context, listen: false);
    bool res = await exProvider.createResult(
      widget.exercise.id,
      (correctAnswers / (questions.length) * 10).round(),
    );
    if (res) {
      setState(() {
        loading = false;
      });
      showResult();
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

  void showResult() {
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
                color: correctAnswers == questions.length
                    ? Colors.green.withOpacity(0.1)
                    : Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    correctAnswers == questions.length
                        ? Icons.star
                        : Icons.emoji_events,
                    color: correctAnswers == questions.length
                        ? Colors.green
                        : Colors.amber,
                    size: 40,
                  ),
                  SizedBox(width: 10),
                  Text(
                    ((correctAnswers / (questions.length) * 10).round())
                            .toString() +
                        " điểm",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: correctAnswers == questions.length
                          ? Colors.green
                          : Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Text(
              correctAnswers == questions.length
                  ? "Tuyệt vời! Bạn đã trả lời đúng tất cả các câu hỏi."
                  : "Bạn đã làm đúng $correctAnswers/${questions.length} câu!",
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
                      currentQuestion = 0;
                      correctAnswers = 0;
                      selectedAnswer = "";
                      answerChecked = false;
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Consumer<QuestionProvider>(
        builder: (context, questionProvider, child) {
      if (questionProvider.isLoading) {
        return Center(
          child: CircularProgressIndicator(),
        );
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
            TopBar(title: widget.exercise.name, isBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16 * pix),
                child: Column(
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "Câu ${currentQuestion + 1}/${questions.length}",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "Đúng: $correctAnswers",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Text(
                              questions[currentQuestion].question,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ...questions[currentQuestion].options.map<Widget>((option) {
                      bool isCorrect =
                          option == questions[currentQuestion].answer;
                      bool isSelected = option == selectedAnswer;

                      Color bgColor = Colors.white;
                      Color borderColor = Colors.grey.shade300;
                      Color textColor = Colors.black87;
                      IconData? optionIcon;

                      if (answerChecked) {
                        if (isSelected) {
                          if (isCorrect) {
                            bgColor = Colors.green.withOpacity(0.1);
                            borderColor = Colors.green;
                            textColor = Colors.green;
                            optionIcon = Icons.check_circle;
                          } else {
                            bgColor = Colors.red.withOpacity(0.1);
                            borderColor = Colors.red;
                            textColor = Colors.red;
                            optionIcon = Icons.cancel;
                          }
                        } else if (isCorrect) {
                          bgColor = Colors.green.withOpacity(0.1);
                          borderColor = Colors.green;
                          textColor = Colors.green;
                          optionIcon = Icons.check_circle;
                        }
                      } else if (isSelected) {
                        bgColor = Colors.blue.withOpacity(0.1);
                        borderColor = Colors.blue;
                        textColor = Colors.blue;
                      }

                      return GestureDetector(
                        onTap: () {
                          if (!answerChecked) {
                            checkAnswer(option);
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          padding: EdgeInsets.all(16),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor, width: 2),
                            boxShadow: !answerChecked
                                ? [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 5,
                                      offset: Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: textColor,
                                    fontWeight: isSelected ||
                                            (answerChecked && isCorrect)
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (optionIcon != null)
                                Icon(
                                  optionIcon,
                                  color: textColor,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 25),
                    SizedBox(height: 30),
                    if (answerChecked)
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selectedAnswer ==
                                  questions[currentQuestion].answer
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedAnswer ==
                                    questions[currentQuestion].answer
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selectedAnswer ==
                                      questions[currentQuestion].answer
                                  ? Icons.check_circle
                                  : Icons.info,
                              color: selectedAnswer ==
                                      questions[currentQuestion].answer
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                selectedAnswer ==
                                        questions[currentQuestion].answer
                                    ? "Chính xác! Đáp án đúng là '${questions[currentQuestion].answer}'."
                                    : "Đáp án đúng là '${questions[currentQuestion].answer}'.\n${questions[currentQuestion].hint}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ));
    });
  }
}
