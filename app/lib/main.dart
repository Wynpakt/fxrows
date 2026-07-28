import 'package:flutter/material.dart';

import 'features/convert/convert_controller.dart';
import 'features/convert/convert_page.dart';
import 'features/settings/app_settings.dart';
import 'features/settings/settings_page.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FxrowsApp());
}

class FxrowsApp extends StatefulWidget {
  const FxrowsApp({super.key});

  @override
  State<FxrowsApp> createState() => _FxrowsAppState();
}

class _FxrowsAppState extends State<FxrowsApp> {
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
      title: 'fxrows',
      theme: buildFxrowsTheme(Brightness.light),
      darkTheme: buildFxrowsTheme(Brightness.dark),
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
