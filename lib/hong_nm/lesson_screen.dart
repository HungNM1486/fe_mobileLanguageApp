import 'package:flutter/material.dart';
import 'package:language_app/hong_nm/do_grammar_screen.dart';
import 'package:language_app/models/exercise_model.dart';
import 'package:language_app/provider/exercise_provider.dart';
import 'package:language_app/res/theme/app_colors.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:provider/provider.dart';

class Lessonscreen extends StatefulWidget {
  const Lessonscreen({super.key, required this.ex});
  final ExerciseModel ex;
  @override
  State<Lessonscreen> createState() => _LessonscreenState();
}

class _LessonscreenState extends State<Lessonscreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExerciseProvider>(context, listen: false)
          .fetchExercise(widget.ex.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

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
              right: 0,
              left: 0,
              child: TopBar(title: widget.ex.name),
            ),
            Consumer<ExerciseProvider>(builder: (context, exProvider, child) {
              if (exProvider.isLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              final exercise = exProvider.exercise;

              return Positioned(
                top: 116 * pix,
                right: 0,
                left: 0,
                bottom: 16 * pix,
                child: exercise?.theory != null
                    ? Container(
                        width: size.width - 32 * pix,
                        height: size.height - 150 * pix,
                        margin: EdgeInsets.symmetric(horizontal: 16 * pix),
                        padding: EdgeInsets.all(16 * pix),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                height: 36 * pix,
                                width: size.width,
                                child: Text(
                                  "Lý thuyết:",
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                exercise!.theory,
                                style: TextStyle(
                                    fontSize: 18 * pix,
                                    fontFamily: 'BeVietnamPro'),
                              ),
                              SizedBox(height: 126 * pix),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        width: size.width - 32 * pix,
                        height: size.height - 150 * pix,
                        margin: EdgeInsets.symmetric(horizontal: 16 * pix),
                        padding: EdgeInsets.all(16 * pix),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Center(
                          child: Text(
                            "Chưa có lý thuyết",
                            style: TextStyle(
                                fontSize: 18 * pix, fontFamily: 'BeVietnamPro'),
                          ),
                        ),
                      ),
              );
            }),
            Consumer<ExerciseProvider>(builder: (context, exProvider, child) {
              if (exProvider.isLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              final exercise = exProvider.exercise;
              return Positioned(
                bottom: 32 * pix,
                right: 16 * pix,
                left: 16 * pix,
                child: _buildExerciseItem(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoGrammarscreen(
                          exercise: exercise!,
                        ),
                      ),
                    );
                  },
                ),
              );
            })
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseItem({
    required VoidCallback onTap,
  }) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50 * pix,
        width: size.width,
        margin:
            EdgeInsets.only(bottom: 10 * pix, left: 16 * pix, right: 16 * pix),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 255, 173, 33),
              AppColors.accent.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: AppColors.accent,
            width: 1 * pix,
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
              offset: Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: Text(
            "Làm ngay",
            style: TextStyle(
              color: const Color.fromARGB(255, 0, 0, 0),
              fontSize: 16 * pix,
              fontFamily: 'BeVietnamPro',
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}
