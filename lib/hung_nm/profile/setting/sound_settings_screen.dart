import 'package:flutter/material.dart';

class SoundSettingsScreen extends StatelessWidget {
  const SoundSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Âm thanh")),
      body: Center(child: Text("Cài đặt âm thanh sẽ được thực hiện ở đây.")),
    );
  }
}
