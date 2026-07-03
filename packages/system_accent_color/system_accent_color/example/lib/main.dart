// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:system_accent_color/system_accent_color.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final accentColor = await SystemAccentColor().getAccentColor();
  print('Accent color: $accentColor');

  runApp(MainApp(accentColor: accentColor));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.accentColor});

  final Color? accentColor;
  static const Color _fallbackColor = Colors.redAccent;

  @override
  Widget build(BuildContext context) {
    final seed = accentColor ?? _fallbackColor;

    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: Home(accentColor: accentColor),
    );
  }
}

// Disclaimer: This widget is AI-generated for demonstration purposes to
// provide an example quickly.
class Home extends StatelessWidget {
  const Home({super.key, required this._accentColor});

  final Color? _accentColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accent color demo'),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: cs.primaryContainer,
              child: ListTile(
                title: const Text('System accent color'),
                subtitle: Text(_accentColor.toString()),
                trailing: Icon(Icons.palette, color: cs.primary),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Material surface',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This uses ColorScheme.fromSeed derived colors across surfaces, text, and accents.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilledButton(
                          onPressed: () {},
                          child: const Text('Button'),
                        ),
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text('Outline'),
                        ),
                        TextButton(onPressed: () {}, child: const Text('Text')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 90,
                    decoration: BoxDecoration(
                      color: cs.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Secondary',
                        style: TextStyle(color: cs.onSecondaryContainer),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 90,
                    decoration: BoxDecoration(
                      color: cs.tertiaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Tertiary',
                        style: TextStyle(color: cs.onTertiaryContainer),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
