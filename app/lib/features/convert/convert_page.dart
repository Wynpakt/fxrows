import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'convert_controller.dart';

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
    return _focus.putIfAbsent(code, FocusNode.new);
  }

  Future<void> _pickCurrency() async {
    final snap = c.snapshot;
    if (snap == null) return;
    final available = snap.rates.keys
        .where((k) => !c.currencies.contains(k))
        .toList()
      ..sort();
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No more currencies from this source')),
      );
      return;
    }
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
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final code = filtered[i];
                          return ListTile(
                            title: Text(code),
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
              ],
            );
          },
        );
      },
    );
    if (chosen != null) c.addCurrency(chosen);
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
                          width: 64,
                          child: Text(
                            code,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
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
                            onTap: () => c.setEditing(code),
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
