import 'package:flutter/material.dart';

import 'features/convert/convert_controller.dart';
import 'features/convert/convert_page.dart';
import 'features/settings/app_settings.dart';
import 'features/settings/settings_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FxboardApp());
}

class FxboardApp extends StatefulWidget {
  const FxboardApp({super.key});

  @override
  State<FxboardApp> createState() => _FxboardAppState();
}

class _FxboardAppState extends State<FxboardApp> {
  final AppSettings _settings = AppSettings();
  late final ConvertController _controller =
      ConvertController(settings: _settings);
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await _controller.init();
    if (mounted) setState(() => _ready = true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fxboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B4D3E),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B4D3E),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routes: {
        '/': (_) => _ready
            ? ConvertPage(controller: _controller)
            : const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
        '/settings': (_) => SettingsPage(
              settings: _settings,
              onChanged: () => _controller.refreshRates(),
            ),
      },
    );
  }
}
