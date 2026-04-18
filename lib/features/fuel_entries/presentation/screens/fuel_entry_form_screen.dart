// ABOUTME: Screen for creating new or editing existing fuel entries
// ABOUTME: Uses FuelEntryForm widget and StateNotifier for persistence

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/fuel_entry.dart';
import '../providers/fuel_entry_providers.dart';
import '../widgets/fuel_entry_form.dart';
import '../../../../generated/l10n/app_localizations.dart';

class FuelEntryFormScreen extends ConsumerWidget {
  final FuelEntry? entry;

  const FuelEntryFormScreen({super.key, this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(entry == null ? l10n.screenAddEntry : l10n.screenEditEntry),
      ),
      body: FuelEntryForm(
        entry: entry,
        onSubmit: (newEntry) async {
          if (entry == null) {
            await ref.read(fuelEntriesProvider.notifier).add(newEntry);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.snackbarEntryAdded)),
              );
              Navigator.pop(context);
            }
          } else {
            await ref.read(fuelEntriesProvider.notifier).update(newEntry);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.snackbarEntryUpdated)),
              );
              Navigator.pop(context);
            }
          }
        },
      ),
    );
  }
}
