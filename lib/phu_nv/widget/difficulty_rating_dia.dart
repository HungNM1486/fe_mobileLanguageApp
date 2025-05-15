import 'package:flutter/material.dart';

class DifficultyRatingDialog extends StatelessWidget {
  final Function(int) onRatingSelected;

  const DifficultyRatingDialog({
    Key? key,
    required this.onRatingSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Đánh giá độ khó từ'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDifficultyButton(
            context,
            1,
            'Dễ',
            Colors.green,
          ),
          SizedBox(height: 10),
          _buildDifficultyButton(
            context,
            2,
            'Trung bình',
            Colors.blue,
          ),
          SizedBox(height: 10),
          _buildDifficultyButton(
            context,
            3,
            'Khó',
            Colors.orange,
          ),
          SizedBox(height: 10),
          _buildDifficultyButton(
            context,
            4,
            'Rất khó',
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyButton(
    BuildContext context,
    int difficulty,
    String label,
    Color color,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: Size(double.infinity, 50),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        onRatingSelected(difficulty);
      },
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
