import 'package:flutter/material.dart';
import 'package:linux_application_id/linux_application_id.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Linux application ID: ${linuxApplicationId()}'),
        ),
      ),
    );
  }
}
