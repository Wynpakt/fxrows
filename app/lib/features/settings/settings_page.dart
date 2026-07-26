import 'package:flutter/material.dart';

import '../../data/rates/rates_provider.dart';
import 'app_settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final AppSettings settings;
  final VoidCallback onChanged;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  RatesProviderId _provider = RatesProviderId.aggServer;
  final _aggUrl = TextEditingController();
  final _apiKey = TextEditingController();
  bool _loading = true;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final provider = await widget.settings.providerId();
    final url = await widget.settings.aggBaseUrl();
    final key = await widget.settings.exchangeRateApiKey();
    setState(() {
      _provider = provider;
      _aggUrl.text = url;
      _apiKey.text = key ?? '';
      _loading = false;
    });
  }

  @override
  void dispose() {
    _aggUrl.dispose();
    _apiKey.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await widget.settings.setProviderId(_provider);
    await widget.settings.setAggBaseUrl(_aggUrl.text);
    await widget.settings.setExchangeRateApiKey(
      _provider == RatesProviderId.exchangeRateApi ? _apiKey.text : null,
    );
    // Keep key if user switches back later — actually plan says store key locally.
    // Always persist key when non-empty so switching providers is painless.
    if (_apiKey.text.trim().isNotEmpty) {
      await widget.settings.setExchangeRateApiKey(_apiKey.text);
    }
    widget.onChanged();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Rate source', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...RatesProviderId.values.map(
            (id) => ListTile(
              title: Text(id.label),
              leading: Icon(
                _provider == id
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
              ),
              selected: _provider == id,
              onTap: () => setState(() => _provider = id),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _aggUrl,
            decoration: const InputDecoration(
              labelText: 'fxboard server URL',
              helperText: 'Used when “fxboard server (ECB)” is selected',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _apiKey,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'ExchangeRate-API key',
              helperText:
                  'Stored only on this device. Never sent to the fxboard server.',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Default path uses ECB reference rates via your self-hosted '
            'aggregator (free reuse with attribution). Optional BYO key calls '
            'ExchangeRate-API directly from the app for a wider currency set.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
