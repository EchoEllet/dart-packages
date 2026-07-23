import 'package:flutter/material.dart';
import 'package:is_ios_simulator/is_ios_simulator.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: _Button())),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);

        final result = await isIosSimulator();
        messenger.showSnackBar(
          SnackBar(content: Text('iOS simulator: $result')),
        );
      },
      child: const Text('Detect'),
    );
  }
}
