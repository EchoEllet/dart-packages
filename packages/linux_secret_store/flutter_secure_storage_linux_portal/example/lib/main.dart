import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_linux_portal/flutter_secure_storage_linux_portal.dart';

void main() {
  FlutterSecureStorageLinuxPortal.registerWith();

  runApp(const MainApp(secureStorage: FlutterSecureStorage()));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key, required this.secureStorage});

  final FlutterSecureStorage secureStorage;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  FlutterSecureStorage get storage => widget.secureStorage;

  final keyController = TextEditingController();
  final valueController = TextEditingController();

  String result = '';

  Future<void> write() async {
    await storage.write(key: keyController.text, value: valueController.text);

    setState(() => result = 'Written');
  }

  Future<void> read() async {
    final value = await storage.read(key: keyController.text);

    setState(() => result = 'Value: $value');
  }

  Future<void> containsKey() async {
    final exists = await storage.containsKey(key: keyController.text);

    setState(() => result = 'Contains: $exists');
  }

  Future<void> delete() async {
    await storage.delete(key: keyController.text);

    setState(() => result = 'Deleted');
  }

  Future<void> readAll() async {
    final values = await storage.readAll();

    setState(() => result = values.toString());
  }

  Future<void> deleteAll() async {
    await storage.deleteAll();

    setState(() => result = 'Deleted all');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Secure Storage Portal Example')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: keyController,
                decoration: const InputDecoration(labelText: 'Key'),
              ),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(labelText: 'Value'),
              ),
              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton(onPressed: write, child: const Text('Write')),
                  ElevatedButton(onPressed: read, child: const Text('Read')),
                  ElevatedButton(
                    onPressed: containsKey,
                    child: const Text('Contains'),
                  ),
                  ElevatedButton(
                    onPressed: delete,
                    child: const Text('Delete'),
                  ),
                  ElevatedButton(
                    onPressed: readAll,
                    child: const Text('Read All'),
                  ),
                  ElevatedButton(
                    onPressed: deleteAll,
                    child: const Text('Delete All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(result),
            ],
          ),
        ),
      ),
    );
  }
}
