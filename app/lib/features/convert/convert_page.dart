import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'convert_controller.dart';
import 'currency_flag.dart';

class ConvertPage extends StatefulWidget {
  const ConvertPage({super.key, required this.controller});

  final ConvertController controller;

  @override
  State<ConvertPage> createState() => _ConvertPageState();
}

class _ConvertPageState extends State<ConvertPage> {
  final Map<String, TextEditingController> _fields = {};
  final Map<String, FocusNode> _focus = {};

  ConvertController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    c.addListener(_onController);
  }

  @override
  void dispose() {
    c.removeListener(_onController);
    for (final f in _fields.values) {
      f.dispose();
    }
    for (final f in _focus.values) {
      f.dispose();
    }
    super.dispose();
  }

  void _onController() {
    if (!mounted) return;
    for (final code in c.currencies) {
      final field = _ensureField(code);
      if (c.editingCode == code) continue;
      final formatted = c.formatAmount(c.amounts[code] ?? 0);
      if (field.text != formatted) {
        field.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
    setState(() {});
  }

  TextEditingController _ensureField(String code) {
    return _fields.putIfAbsent(code, () {
      final amount = c.amounts[code] ?? 0;
      return TextEditingController(text: c.formatAmount(amount));
    });
  }

  FocusNode _ensureFocus(String code) {
    return _focus.putIfAbsent(code, () {
      final node = FocusNode();
      node.addListener(() {
        if (!node.hasFocus) return;
        if (c.editingCode != code) c.setEditing(code);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!node.hasFocus) return;
          final field = _fields[code];
          if (field == null || field.text.isEmpty) return;
          field.selection = TextSelection(
            baseOffset: 0,
            extentOffset: field.text.length,
          );
        });
      });
      return node;
    });
  }

  Future<void> _pickCurrency() async {
    final snap = c.snapshot;
    if (snap == null) return;
    final available = snap.rates.keys
        .where((k) => !c.currencies.contains(k))
        .toList()
      ..sort();

    final chosen = await showDialog<String>(
      context: context,
      builder: (ctx) {
        var query = '';
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            final filtered = available
                .where((k) => k.toLowerCase().contains(query.toLowerCase()))
                .toList();
            return AlertDialog(
              title: const Text('Add currency'),
              content: SizedBox(
                width: 360,
                height: 420,
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Filter…',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (v) => setLocal(() => query = v),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(
                                available.isEmpty
                                    ? 'No more currencies from this source.\nAdd a custom rate instead.'
                                    : 'No matches',
                                textAlign: TextAlign.center,
                                style: Theme.of(ctx).textTheme.bodyMedium,
                              ),
                            )
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (_, i) {
                                final code = filtered[i];
                                final custom = c.isCustom(code);
                                return ListTile(
                                  title: Text(currencyLabel(code)),
                                  subtitle: custom
                                      ? const Text('Custom rate')
                                      : null,
                                  onTap: () => Navigator.pop(ctx, code),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _addCustomCurrency();
                  },
                  child: const Text('Custom…'),
                ),
              ],
            );
          },
        );
      },
    );
    if (chosen != null) c.addCurrency(chosen);
  }

  Future<void> _addCustomCurrency({String? existingCode}) async {
    final codeCtrl = TextEditingController(text: existingCode ?? '');
    final rateCtrl = TextEditingController(
      text: existingCode != null
          ? (c.customRates[existingCode]?.toString() ?? '')
          : '',
    );
    final base = c.snapshot?.base ?? 'EUR';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(existingCode == null ? 'Custom currency' : 'Edit rate'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeCtrl,
                enabled: existingCode == null,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Code',
                  hintText: 'e.g. BTC or POINTS',
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
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Units per 1 $base',
                  helperText:
                      'How many units of this currency equal one $base',
                  border: const OutlineInputBorder(),
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
        );
      },
    );
    if (ok != true || !mounted) return;
    final rate = double.tryParse(rateCtrl.text.trim().replaceAll(',', '.'));
    try {
      await c.addCustomCurrency(codeCtrl.text, rate ?? 0);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved ${codeCtrl.text.toUpperCase()}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      codeCtrl.dispose();
      rateCtrl.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('fxboard'),
        actions: [
          IconButton(
            tooltip: 'Refresh rates',
            onPressed: c.loading ? null : c.refreshRates,
            icon: c.loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickCurrency,
        tooltip: 'Add currency',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (c.errorMessage != null)
            MaterialBanner(
              content: Text(c.errorMessage!),
              leading: const Icon(Icons.warning_amber),
              actions: [
                TextButton(
                  onPressed: c.refreshRates,
                  child: const Text('Retry'),
                ),
              ],
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
              itemCount: c.currencies.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final code = c.currencies[index];
                final field = _ensureField(code);
                final focus = _ensureFocus(code);
                final flag = currencyFlag(code);
                return Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 88,
                          child: Row(
                            children: [
                              if (flag.isNotEmpty) ...[
                                Text(flag, style: const TextStyle(fontSize: 22)),
                                const SizedBox(width: 6),
                              ],
                              Flexible(
                                child: Text(
                                  code,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: field,
                            focusNode: focus,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9+\-*/().,\s]'),
                              ),
                            ],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '0 · or 100+50',
                            ),
                            style: theme.textTheme.headlineSmall,
                            onTap: () {
                              if (c.editingCode != code) c.setEditing(code);
                              field.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: field.text.length,
                              );
                            },
                            onChanged: (raw) => c.liveAmount(code, raw),
                            onEditingComplete: () {
                              c.commitAmount(code, field.text);
                              c.setEditing(null);
                              focus.unfocus();
                            },
                            onSubmitted: (raw) {
                              c.commitAmount(code, raw);
                              c.setEditing(null);
                            },
                          ),
                        ),
                        if (c.isCustom(code))
                          IconButton(
                            tooltip: 'Edit custom rate',
                            onPressed: () => _addCustomCurrency(existingCode: code),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                        if (c.currencies.length > 2)
                          IconButton(
                            tooltip: 'Remove',
                            onPressed: () => c.removeCurrency(code),
                            icon: const Icon(Icons.close),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (c.statusMessage != null)
                    Text(
                      c.statusMessage!,
                      style: theme.textTheme.bodySmall,
                    ),
                  if (c.snapshot != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      c.snapshot!.attribution,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      c.snapshot!.disclaimer,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
