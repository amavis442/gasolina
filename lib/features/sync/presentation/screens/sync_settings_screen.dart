// ABOUTME: Screen for entering the API base URL and device secret for sync
// ABOUTME: Persists credentials via SyncConfigDataSource on save

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/fuel_entries/presentation/providers/wage_day_provider.dart';
import '../../domain/entities/sync_config.dart';
import '../providers/sync_providers.dart';
import 'qr_scanner_screen.dart';

class SyncSettingsScreen extends ConsumerStatefulWidget {
  const SyncSettingsScreen({super.key});

  @override
  ConsumerState<SyncSettingsScreen> createState() => _SyncSettingsScreenState();
}

class _SyncSettingsScreenState extends ConsumerState<SyncSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _urlController;
  late TextEditingController _secretController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
    _secretController = TextEditingController();

    // Pre-fill saved values once the provider resolves
    ref.listenManual(syncConfigProvider, (_, next) {
      next.whenData((config) {
        if (_urlController.text.isEmpty) {
          _urlController.text = config.apiBaseUrl;
        }
        if (_secretController.text.isEmpty) {
          _secretController.text = config.deviceSecret;
        }
      });
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  Future<void> _scanQr() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (result != null && result.isNotEmpty) {
      _secretController.text = result;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final config = SyncConfig(
      apiBaseUrl: _urlController.text.trim(),
      deviceSecret: _secretController.text.trim(),
    );

    await ref.read(syncConfigDataSourceProvider).saveConfig(config);
    ref.invalidate(syncConfigProvider);

    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sync settings saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sync Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'API Base URL',
                  hintText: 'http://192.168.1.x:8080',
                ),
                keyboardType: TextInputType.url,
                autocorrect: false,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _secretController,
                      decoration: const InputDecoration(
                        labelText: 'Device Secret',
                      ),
                      obscureText: true,
                      autocorrect: false,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: IconButton.filled(
                      icon: const Icon(Icons.qr_code_scanner),
                      tooltip: 'Scan QR code',
                      onPressed: _scanQr,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Display preferences',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(
                    child: Text('Wage day'),
                  ),
                  DropdownButton<int>(
                    value: ref.watch(wageDayProvider),
                    items: List.generate(
                      28,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text('${i + 1}'),
                      ),
                    ),
                    onChanged: (day) {
                      if (day != null) {
                        ref.read(wageDayProvider.notifier).setWageDay(day);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
