import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:language_app/hung_nm/profile/setting/goal/goal_completion_screen.dart';
import 'package:language_app/provider/study_plans_provider.dart';
import 'package:language_app/provider/auth_provider.dart';
import 'package:language_app/phu_nv/LoginSignup/login_screen.dart'; 


class StudyTimeScreen extends StatefulWidget {
  final String goal;
  final String time;

  const StudyTimeScreen({super.key, required this.goal, required this.time});

  @override
  State<StudyTimeScreen> createState() => _StudyTimeScreenState();
}

class _StudyTimeScreenState extends State<StudyTimeScreen> {
  String _selectedStudyTime = 'breakfast';
  late Color _goalColor;
  late IconData _goalIcon;
  late String _goalTitle;
  late String _timeTitle;

  @override
  void initState() {
    super.initState();
    _setGoalProperties();
    _checkAuthAndLoadStudyTime();
  }

  void _setGoalProperties() {
    switch (widget.goal) {
      case 'basic':
        _goalColor = Colors.green;
        _goalIcon = Icons.sentiment_satisfied_rounded;
        _goalTitle = 'Cơ bản';
        break;
      case 'advanced':
        _goalColor = Colors.blue;
        _goalIcon = Icons.trending_up_rounded;
        _goalTitle = 'Nâng cao';
        break;
      case 'expert':
        _goalColor = Colors.purple;
        _goalIcon = Icons.military_tech_rounded;
        _goalTitle = 'Chuyên sâu';
        break;
      default:
        _goalColor = const Color(0xff5B7BFE);
        _goalIcon = Icons.flag_rounded;
        _goalTitle = 'Mục tiêu';
    }

    switch (widget.time) {
      case '1month':
        _timeTitle = '1 tháng';
        break;
      case '3months':
        _timeTitle = '3 tháng';
        break;
      case '6months':
        _timeTitle = '6 tháng';
        break;
      default:
        _timeTitle = '1 tháng';
    }
  }

  Future<void> _checkAuthAndLoadStudyTime() async {
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
    await provider.fetchStudyPlan(context);
    if (provider.studyPlan != null) {
      setState(() {
        _selectedStudyTime = _mapStudyTimeSlotToStudyTime(provider.studyPlan!.studyTimeSlot);
      });
    }
  }

  String _mapStudyTimeSlotToStudyTime(String slot) {
    switch (slot) {
      case 'morning':
        return 'breakfast';
      case 'work_hours':
        return 'commuting';
      case 'noon':
        return 'lunch';
      case 'evening':
        return 'dinner';
      default:
        return 'breakfast';
    }
  }

  Future<void> _saveStudyTimeAndContinue(String studyTime) async {
    setState(() {
      _selectedStudyTime = studyTime;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalCompletionScreen(
          goal: widget.goal,
          time: widget.time,
          studyTime: studyTime,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = (size.width / 375).clamp(0.8, 1.2);
    final provider = Provider.of<StudyPlansProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Thời gian học tập'),
        backgroundColor: _goalColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: const AssetImage('assets/images/goal_background.png'),
            fit: BoxFit.cover,
            opacity: 0.05,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16 * pix),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressSteps(pix),
              SizedBox(height: 20 * pix),
              Text(
                'Khi nào bạn muốn học trong ngày?',
                style: TextStyle(
                  fontSize: 18 * pix,
                  fontWeight: FontWeight.bold,
                  color: _goalColor,
                ),
              ),
              SizedBox(height: 8 * pix),
              Text(
                'Chọn thời điểm phù hợp nhất để học tập hàng ngày',
                style: TextStyle(
                  fontSize: 14 * pix,
                  color: Colors.grey[600],
                ),
              ),
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
              SizedBox(height: 24 * pix),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTimeOptionCard(
                        'breakfast',
                        'Buổi sáng',
                        'Học vào buổi sáng giúp tiếp thu tốt nhất',
                        Icons.free_breakfast,
                        '6:00 - 9:00',
                        pix,
                      ),
                      SizedBox(height: 16 * pix),
                      _buildTimeOptionCard(
                        'commuting',
                        'Giờ di chuyển',
                        'Tận dụng thời gian di chuyển để học',
                        Icons.directions_bus,
                        '7:00 - 8:00 & 17:00 - 18:00',
                        pix,
                      ),
                      SizedBox(height: 16 * pix),
                      _buildTimeOptionCard(
                        'lunch',
                        'Giờ nghỉ trưa',
                        'Học trong giờ nghỉ trưa giúp thư giãn đầu óc',
                        Icons.lunch_dining,
                        '12:00 - 13:00',
                        pix,
                      ),
                      SizedBox(height: 16 * pix),
                      _buildTimeOptionCard(
                        'dinner',
                        'Buổi tối',
                        'Học vào buổi tối khi mọi việc đã hoàn thành',
                        Icons.nightlight_round,
                        '19:00 - 22:00',
                        pix,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16 * pix),
              _buildContinueButton(pix),
            ],
          ),
        ),
      ),
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
          _buildStepLine(false, _goalColor, pix),
          _buildStepCircle(4, false, _goalColor, pix),
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

  Widget _buildTimeOptionCard(
    String value,
    String title,
    String description,
    IconData icon,
    String timeRange,
    double pix,
  ) {
    final isSelected = _selectedStudyTime == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStudyTime = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected ? _goalColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16 * pix),
          border: Border.all(
            color: isSelected ? _goalColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? _goalColor.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 8 : 4,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16 * pix),
          child: Row(
            children: [
              Container(
                width: 56 * pix,
                height: 56 * pix,
                decoration: BoxDecoration(
                  color: _goalColor.withOpacity(isSelected ? 0.2 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: _goalColor,
                  size: 28 * pix,
                ),
              ),
              SizedBox(width: 16 * pix),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16 * pix,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? _goalColor : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 24 * pix,
                          height: 24 * pix,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? _goalColor : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? _goalColor
                                  : Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16 * pix,
                                )
                              : null,
                        ),
                      ],
                    ),
                    SizedBox(height: 8 * pix),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14 * pix,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 10 * pix),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10 * pix,
                        vertical: 4 * pix,
                      ),
                      decoration: BoxDecoration(
                        color: _goalColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12 * pix),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14 * pix,
                            color: _goalColor,
                          ),
                          SizedBox(width: 4 * pix),
                          Text(
                            timeRange,
                            style: TextStyle(
                              fontSize: 12 * pix,
                              fontWeight: FontWeight.bold,
                              color: _goalColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(double pix) {
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
          onTap: () => _saveStudyTimeAndContinue(_selectedStudyTime),
          borderRadius: BorderRadius.circular(12 * pix),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hoàn thành',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16 * pix,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8 * pix),
                Icon(
                  Icons.check_circle_outline,
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