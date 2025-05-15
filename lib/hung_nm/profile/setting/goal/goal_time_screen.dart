import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:language_app/hung_nm/profile/setting/goal/study_time_screen.dart';
import 'package:language_app/provider/study_plans_provider.dart';
import 'package:language_app/provider/auth_provider.dart';
import 'package:language_app/phu_nv/LoginSignup/login_screen.dart'; 

class GoalTimeScreen extends StatefulWidget {
  final String goal;

  const GoalTimeScreen({super.key, required this.goal});

  @override
  State<GoalTimeScreen> createState() => _GoalTimeScreenState();
}

class _GoalTimeScreenState extends State<GoalTimeScreen> {
  String _selectedTime = '1month';
  late Color _goalColor;
  late IconData _goalIcon;
  late String _goalTitle;

  @override
  void initState() {
    super.initState();
    _setGoalProperties();
    _checkAuthAndLoadTime();
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
  }

  Future<void> _checkAuthAndLoadTime() async {
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
        _selectedTime = _mapCompletionTimeToTime(provider.studyPlan!.completionTimeMonths);
      });
    }
  }

  String _mapCompletionTimeToTime(int months) {
    switch (months) {
      case 1:
        return '1month';
      case 3:
        return '3months';
      case 6:
        return '6months';
      default:
        return '1month';
    }
  }

  Future<void> _saveTimeAndContinue(String time) async {
    setState(() {
      _selectedTime = time;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => StudyTimeScreen(goal: widget.goal, time: time)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = (size.width / 375).clamp(0.8, 1.2);
    final provider = Provider.of<StudyPlansProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Thời gian mục tiêu'),
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
              _buildGoalHeader(pix),
              SizedBox(height: 24 * pix),
              Text(
                'Chọn khoảng thời gian bạn muốn đạt được mục tiêu này',
                style: TextStyle(
                  fontSize: 16 * pix,
                  color: Colors.grey[800],
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
              SizedBox(height: 20 * pix),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTimeCard(
                        '1month',
                        '1 tháng',
                        'Tiến độ nhanh, học tập chuyên sâu mỗi ngày',
                        Icons.speed,
                        pix,
                      ),
                      SizedBox(height: 16 * pix),
                      _buildTimeCard(
                        '3months',
                        '3 tháng',
                        'Tiến độ vừa phải, phù hợp với lịch trình bận rộn',
                        Icons.calendar_month,
                        pix,
                      ),
                      SizedBox(height: 16 * pix),
                      _buildTimeCard(
                        '6months',
                        '6 tháng',
                        'Tiến độ chậm, học dần dần và duy trì đều đặn',
                        Icons.slow_motion_video,
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

  Widget _buildGoalHeader(double pix) {
    return Container(
      padding: EdgeInsets.all(16 * pix),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * pix),
        boxShadow: [
          BoxShadow(
            color: _goalColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48 * pix,
            height: 48 * pix,
            decoration: BoxDecoration(
              color: _goalColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _goalIcon,
              color: _goalColor,
              size: 26 * pix,
            ),
          ),
          SizedBox(width: 16 * pix),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mục tiêu đã chọn:',
                  style: TextStyle(
                    fontSize: 14 * pix,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4 * pix),
                Text(
                  _goalTitle,
                  style: TextStyle(
                    fontSize: 18 * pix,
                    fontWeight: FontWeight.bold,
                    color: _goalColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: _goalColor,
            size: 24 * pix,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard(
    String value,
    String title,
    String description,
    IconData icon,
    double pix,
  ) {
    final isSelected = _selectedTime == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTime = value;
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
                width: 50 * pix,
                height: 50 * pix,
                decoration: BoxDecoration(
                  color: _goalColor.withOpacity(isSelected ? 0.2 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: _goalColor,
                  size: 24 * pix,
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
                    SizedBox(height: 12 * pix),
                    _buildTimelineVisualization(value, pix),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineVisualization(String timeValue, double pix) {
    int weeks;
    switch (timeValue) {
      case '1month':
        weeks = 4;
        break;
      case '3months':
        weeks = 12;
        break;
      case '6months':
        weeks = 24;
        break;
      default:
        weeks = 4;
    }

    return Row(
      children: List.generate(
        weeks > 10 ? 10 : weeks,
        (index) => Expanded(
          child: Container(
            height: 6 * pix,
            margin: EdgeInsets.symmetric(horizontal: 1 * pix),
            decoration: BoxDecoration(
              color: _goalColor
                  .withOpacity(0.2 + (index * 0.08 > 0.8 ? 0.8 : index * 0.08)),
              borderRadius: BorderRadius.circular(3 * pix),
            ),
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
          onTap: () => _saveTimeAndContinue(_selectedTime),
          borderRadius: BorderRadius.circular(12 * pix),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tiếp tục',
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