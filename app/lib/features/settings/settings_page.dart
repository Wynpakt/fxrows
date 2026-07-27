import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/rates/rates_provider.dart';
import '../convert/currency_flag.dart';
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
  final _eraKey = TextEditingController();
  final _oerAppId = TextEditingController();
  Map<String, double> _customRates = {};
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
    final era = await widget.settings.exchangeRateApiKey();
    final oer = await widget.settings.openExchangeRatesAppId();
    final custom = await widget.settings.customRates();
    setState(() {
      _provider = provider;
      _aggUrl.text = url;
      _eraKey.text = era ?? '';
      _oerAppId.text = oer ?? '';
      _customRates = custom;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _aggUrl.dispose();
    _eraKey.dispose();
    _oerAppId.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await widget.settings.setProviderId(_provider);
    await widget.settings.setAggBaseUrl(_aggUrl.text);
    // Persist both keys when non-empty so switching providers keeps credentials.
    if (_eraKey.text.trim().isNotEmpty) {
      await widget.settings.setExchangeRateApiKey(_eraKey.text);
    }
    if (_oerAppId.text.trim().isNotEmpty) {
      await widget.settings.setOpenExchangeRatesAppId(_oerAppId.text);
    }
    widget.onChanged();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _editCustom({String? existingCode}) async {
    final codeCtrl = TextEditingController(text: existingCode ?? '');
    final rateCtrl = TextEditingController(
      text: existingCode != null
          ? (_customRates[existingCode]?.toString() ?? '')
          : '',
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existingCode == null ? 'Add custom currency' : 'Edit rate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeCtrl,
              enabled: existingCode == null,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Code',
                border: OutlineInputBorder(),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                LengthLimitingTextInputFormatter(8),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: rateCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Units per 1 base (usually EUR)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok != true) {
      codeCtrl.dispose();
      rateCtrl.dispose();
      return;
    }
    final code = codeCtrl.text.trim().toUpperCase();
    final rate = double.tryParse(rateCtrl.text.trim().replaceAll(',', '.'));
    codeCtrl.dispose();
    rateCtrl.dispose();
    if (!RegExp(r'^[A-Z]{3,8}$').hasMatch(code) || rate == null || rate <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Need a 3–8 letter code and positive rate')),
        );
      }
      return;
    }
    await widget.settings.upsertCustomRate(code, rate);
    final next = await widget.settings.customRates();
    setState(() => _customRates = next);
    widget.onChanged();
  }

  Future<void> _deleteCustom(String code) async {
    await widget.settings.removeCustomRate(code);
    final next = await widget.settings.customRates();
    setState(() => _customRates = next);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final customCodes = _customRates.keys.toList()..sort();
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
          if (_provider == RatesProviderId.exchangeRateApi)
            TextField(
              controller: _eraKey,
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
          if (_provider == RatesProviderId.openExchangeRates)
            TextField(
              controller: _oerAppId,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Open Exchange Rates App ID',
                helperText:
                    'Stored only on this device. Free plan uses USD as base. '
                    'Never sent to the fxboard server.',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Custom currencies',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton.icon(
                onPressed: () => _editCustom(),
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          Text(
            'Self-maintained rates as units per 1 provider base '
            '(ECB: usually EUR; Open Exchange Rates free: USD). '
            'They merge with live rates and stay on this device.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          if (customCodes.isEmpty)
            Text(
              'None yet — use Add or the convert screen’s Custom… button.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            )
          else
            ...customCodes.map(
              (code) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(currencyLabel(code)),
                subtitle: Text('${_customRates[code]} per base'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      onPressed: () => _editCustom(existingCode: code),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      onPressed: () => _deleteCustom(code),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            'Default path uses ECB reference rates via your self-hosted '
            'aggregator (free reuse with attribution). Optional BYO providers '
            '(ExchangeRate-API or Open Exchange Rates) call their APIs directly '
            'from the device for a wider currency set.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
