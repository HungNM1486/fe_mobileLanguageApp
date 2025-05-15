import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:language_app/hung_nm/profile/profile_sceen.dart';
import 'package:language_app/provider/study_plans_provider.dart';
import 'package:language_app/provider/auth_provider.dart';
import 'package:language_app/phu_nv/LoginSignup/login_screen.dart';

class GoalCompletionScreen extends StatefulWidget {
  final String goal;
  final String time;
  final String studyTime;

  const GoalCompletionScreen({
    super.key,
    required this.goal,
    required this.time,
    required this.studyTime,
  });

  @override
  State<GoalCompletionScreen> createState() => _GoalCompletionScreenState();
}

class _GoalCompletionScreenState extends State<GoalCompletionScreen> {
  late ConfettiController _confettiController;
  late Color _goalColor;
  late IconData _goalIcon;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _setGoalProperties();
    _checkAuthAndSaveStudyPlan();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _setGoalProperties() {
    switch (widget.goal) {
      case 'basic':
        _goalColor = Colors.green;
        _goalIcon = Icons.sentiment_satisfied_rounded;
        break;
      case 'advanced':
        _goalColor = Colors.blue;
        _goalIcon = Icons.trending_up_rounded;
        break;
      case 'expert':
        _goalColor = Colors.purple;
        _goalIcon = Icons.military_tech_rounded;
        break;
      default:
        _goalColor = const Color(0xff5B7BFE);
        _goalIcon = Icons.flag_rounded;
    }
  }

  Future<void> _checkAuthAndSaveStudyPlan() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = await authProvider.checkAuthStatus();
    if (!isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Loginscreen()),
      );
      return;
    }
    final provider = Provider.of<StudyPlansProvider>(context, listen: false);

    final level = _mapGoalToLevel(widget.goal);
    final completionTime = _mapTimeToCompletionTime(widget.time);
    final studyTimeSlot = _mapStudyTimeToStudyTimeSlot(widget.studyTime);

    if (provider.studyPlan == null) {
      await provider.createStudyPlan(
        level: level,
        completionTimeMonths: completionTime,
        studyTimeSlot: studyTimeSlot,
        context: context,
      );
    } else {
      await provider.updateStudyPlan(
        id: provider.studyPlan!.id,
        level: level,
        completionTimeMonths: completionTime,
        studyTimeSlot: studyTimeSlot,
        context: context,
      );
    }
  }

  String _mapGoalToLevel(String goal) {
    switch (goal) {
      case 'basic':
        return 'basic';
      case 'advanced':
        return 'advanced';
      case 'expert':
        return 'intensive';
      default:
        return 'basic';
    }
  }

  int _mapTimeToCompletionTime(String time) {
    switch (time) {
      case '1month':
        return 1;
      case '3months':
        return 3;
      case '6months':
        return 6;
      default:
        return 1;
    }
  }

  String _mapStudyTimeToStudyTimeSlot(String studyTime) {
    switch (studyTime) {
      case 'breakfast':
        return 'morning';
      case 'commuting':
        return 'work_hours';
      case 'lunch':
        return 'noon';
      case 'dinner':
        return 'evening';
      default:
        return 'morning';
    }
  }

  String _getGoalText() {
    switch (widget.goal) {
      case 'basic':
        return 'Cơ bản';
      case 'advanced':
        return 'Nâng cao';
      case 'expert':
        return 'Chuyên sâu';
      default:
        return 'Cơ bản';
    }
  }

  String _getTimeText() {
    switch (widget.time) {
      case '1month':
        return '1 tháng';
      case '3months':
        return '3 tháng';
      case '6months':
        return '6 tháng';
      default:
        return '1 tháng';
    }
  }

  String _getStudyTimeText() {
    switch (widget.studyTime) {
      case 'breakfast':
        return 'Buổi sáng';
      case 'commuting':
        return 'Giờ di chuyển';
      case 'lunch':
        return 'Giờ nghỉ trưa';
      case 'dinner':
        return 'Buổi tối';
      default:
        return 'Buổi sáng';
    }
  }

  IconData _getStudyTimeIcon() {
    switch (widget.studyTime) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'commuting':
        return Icons.directions_bus;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.nightlight_round;
      default:
        return Icons.free_breakfast;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = (size.width / 375).clamp(0.8, 1.2);
    final provider = Provider.of<StudyPlansProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _goalColor.withOpacity(0.1),
                  Colors.white,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(pix),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(16 * pix),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildCompletionHeader(pix),
                          SizedBox(height: 30 * pix),
                          _buildProgressSteps(pix),
                          SizedBox(height: 30 * pix),
                          if (provider.isLoading)
                            Center(child: CircularProgressIndicator()),
                          if (provider.errorMessage != null)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8 * pix),
                              child: Text(
                                provider.errorMessage!,
                                style: TextStyle(color: Colors.red, fontSize: 14 * pix),
                              ),
                            ),
                          _buildGoalSummaryCard(pix),
                          SizedBox(height: 24 * pix),
                          _buildMotivationCard(pix),
                          SizedBox(height: 24 * pix),
                          _buildFinishButton(pix, context),
                          SizedBox(height: 16 * pix),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.2,
              colors: [
                _goalColor,
                Colors.orange,
                Colors.pink,
                Colors.yellow,
                Colors.lightBlue,
                Colors.green
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(double pix) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * pix, vertical: 8 * pix),
      child: Row(
        children: [
          const Spacer(),
          Text(
            'Hoàn thành thiết lập',
            style: TextStyle(
              fontSize: 18 * pix,
              fontWeight: FontWeight.bold,
              color: _goalColor,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildCompletionHeader(double pix) {
    return Column(
      children: [
        Container(
          width: 100 * pix,
          height: 100 * pix,
          decoration: BoxDecoration(
            color: _goalColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 80 * pix,
              height: 80 * pix,
              decoration: BoxDecoration(
                color: _goalColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 60 * pix,
                  height: 60 * pix,
                  decoration: BoxDecoration(
                    color: _goalColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _goalColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.celebration,
                    size: 30 * pix,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20 * pix),
        Text(
          'Chúc mừng!',
          style: TextStyle(
            fontSize: 28 * pix,
            fontWeight: FontWeight.bold,
            color: _goalColor,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10 * pix),
        Text(
          'Bạn đã thiết lập thành công mục tiêu học tập của mình.',
          style: TextStyle(
            fontSize: 16 * pix,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressSteps(double pix) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16 * pix, horizontal: 12 * pix),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * pix),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStepCircle(1, true, _goalColor, pix),
          _buildStepLine(true, _goalColor, pix),
          _buildStepCircle(2, true, _goalColor, pix),
          _buildStepLine(true, _goalColor, pix),
          _buildStepCircle(3, true, _goalColor, pix),
          _buildStepLine(true, _goalColor, pix),
          _buildStepCircle(4, true, _goalColor, pix),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, bool completed, Color color, double pix) {
    return Container(
      width: 30 * pix,
      height: 30 * pix,
      decoration: BoxDecoration(
        color: completed ? color : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: completed ? color : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Center(
        child: completed
            ? Icon(
                Icons.check,
                color: Colors.white,
                size: 16 * pix,
              )
            : Text(
                step.toString(),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: 14 * pix,
                ),
              ),
      ),
    );
  }

  Widget _buildStepLine(bool completed, Color color, double pix) {
    return Expanded(
      child: Container(
        height: 3 * pix,
        color: completed ? color : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildGoalSummaryCard(double pix) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * pix),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16 * pix),
            decoration: BoxDecoration(
              color: _goalColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16 * pix),
                topRight: Radius.circular(16 * pix),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8 * pix),
                  decoration: BoxDecoration(
                    color: _goalColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.settings,
                    color: _goalColor,
                    size: 20 * pix,
                  ),
                ),
                SizedBox(width: 12 * pix),
                Text(
                  'Tổng quan mục tiêu',
                  style: TextStyle(
                    fontSize: 16 * pix,
                    fontWeight: FontWeight.bold,
                    color: _goalColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16 * pix),
            child: Column(
              children: [
                _buildSummaryItem(
                  'Cấp độ mục tiêu:',
                  _getGoalText(),
                  _goalIcon,
                  pix,
                ),
                Divider(height: 24 * pix),
                _buildSummaryItem(
                  'Thời gian hoàn thành:',
                  _getTimeText(),
                  Icons.calendar_month,
                  pix,
                ),
                Divider(height: 24 * pix),
                _buildSummaryItem(
                  'Thời điểm học hàng ngày:',
                  _getStudyTimeText(),
                  _getStudyTimeIcon(),
                  pix,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, String value, IconData icon, double pix) {
    return Row(
      children: [
        Container(
          width: 40 * pix,
          height: 40 * pix,
          decoration: BoxDecoration(
            color: _goalColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10 * pix),
          ),
          child: Icon(
            icon,
            color: _goalColor,
            size: 20 * pix,
          ),
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
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4 * pix),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16 * pix,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationCard(double pix) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * pix),
      decoration: BoxDecoration(
        color: _goalColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16 * pix),
        border: Border.all(
          color: _goalColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: _goalColor,
                size: 24 * pix,
              ),
              SizedBox(width: 8 * pix),
              Text(
                'Mẹo nhỏ',
                style: TextStyle(
                  fontSize: 16 * pix,
                  fontWeight: FontWeight.bold,
                  color: _goalColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * pix),
          Text(
            'Học tập mỗi ngày, dù chỉ 5 phút, sẽ giúp bạn duy trì thói quen và tiến bộ nhanh hơn. Hãy đặt nhắc nhở và duy trì động lực của bạn!',
            style: TextStyle(
              fontSize: 14 * pix,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishButton(double pix, BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56 * pix,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _goalColor,
            _goalColor.withOpacity(0.8),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12 * pix),
        boxShadow: [
          BoxShadow(
            color: _goalColor.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
              (route) => false,
            );
          },
          borderRadius: BorderRadius.circular(12 * pix),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bắt đầu hành trình học tập',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16 * pix,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8 * pix),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20 * pix,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}