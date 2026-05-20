// ignore_for_file: avoid_print

import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_plus_linux_portal/connectivity_plus_linux_portal.dart';
import 'package:flutter/material.dart';

void main() {
  if (Platform.isLinux && shouldUsePortal()) {
    print('Using org.freedesktop.portal.NetworkMonitor for connectivity_plus');
    ConnectivityPlusLinuxPortalPlugin.registerWith();
  }

  final connectivity = Connectivity();
  runApp(MainApp(connectivity: connectivity));
}

bool get isFlatpak =>
    Platform.environment.containsKey('FLATPAK_ID') ||
    Platform.environment['container'] == 'flatpak';

bool shouldUsePortal() {
  if (Platform.environment['CONNECTIVITY_BACKEND'] == 'portal') {
    return true;
  }
  return isFlatpak;
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this._connectivity});
  final Connectivity _connectivity;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              CheckConnectivityButton(connectivity: _connectivity),
              OnConnectivityChanged(connectivity: _connectivity),
            ],
          ),
        ),
      ),
    );
  }
}

class CheckConnectivityButton extends StatelessWidget {
  const CheckConnectivityButton({super.key, required this._connectivity});

  final Connectivity _connectivity;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);
        final result = await _connectivity.checkConnectivity();
        messenger.showSnackBar(SnackBar(content: Text('Result: $result')));
      },
      child: const Text('Check Connectivity'),
    );
  }
}

class OnConnectivityChanged extends StatefulWidget {
  const OnConnectivityChanged({super.key, required this._connectivity});
  final Connectivity _connectivity;

  @override
  State<OnConnectivityChanged> createState() => _OnConnectivityChangedState();
}

class _OnConnectivityChangedState extends State<OnConnectivityChanged> {
  late Stream<List<ConnectivityResult>> _stream;
  @override
  void initState() {
    _stream = widget._connectivity.onConnectivityChanged;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _stream,
      builder: (context, result) {
        if (result.connectionState == .waiting) {
          return const CircularProgressIndicator();
        }
        final error = result.error;
        if (error != null) {
          return Text('Error: $error');
        }

        return Text('Result: ${result.data}');
      },
    );
  }
}
