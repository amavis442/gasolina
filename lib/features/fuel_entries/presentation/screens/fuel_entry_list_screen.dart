// ABOUTME: Screen displaying fuel entries grouped by month and year with add/edit/delete actions
// ABOUTME: Uses Riverpod for state management and navigation to form screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/fuel_entry.dart';
import '../providers/fuel_entry_providers.dart';
import 'fuel_entry_form_screen.dart';
import '../widgets/fuel_entry_card.dart';
import '../../../../generated/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class FuelEntryListScreen extends ConsumerWidget {
  const FuelEntryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(fuelEntriesProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.screenFuelEntries),
      ),
      body: entriesAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_gas_station_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.emptyNoEntries,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.emptyNoEntriesHint,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                  ),
                ],
              ),
            );
          }

          final items = _buildGroupedList(entries);

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return switch (item) {
                _MonthGroupHeader() => _MonthHeaderWidget(header: item),
                _EntryListItem() => FuelEntryCard(
                    entry: item.entry,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FuelEntryFormScreen(entry: item.entry),
                        ),
                      );
                    },
                    onDelete: () =>
                        _showDeleteConfirmation(context, ref, item.entry.id),
                  ),
              };
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                l10n.errorGeneric(error.toString()),
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(fuelEntriesProvider.notifier).loadEntries();
                },
                child: Text(l10n.btnRetry),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FuelEntryFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    String entryId,
  ) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dialogDeleteTitle),
        content: Text(l10n.dialogDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.btnCancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(fuelEntriesProvider.notifier).delete(entryId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.snackbarEntryDeleted)),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.btnDelete),
          ),
        ],
      ),
    );
  }
}

// ── Grouping logic ────────────────────────────────────────────────────────────

List<_ListItem> _buildGroupedList(List<FuelEntry> entries) {
  final sorted = [...entries]..sort((a, b) => b.date.compareTo(a.date));

  final Map<(int, int), List<FuelEntry>> groups = {};
  for (final entry in sorted) {
    final key = (entry.date.year, entry.date.month);
    groups.putIfAbsent(key, () => []).add(entry);
  }

  // Keys are already in descending order because entries are sorted, but sort
  // explicitly to be safe.
  final sortedKeys = groups.keys.toList()
    ..sort((a, b) {
      if (a.$1 != b.$1) return b.$1.compareTo(a.$1);
      return b.$2.compareTo(a.$2);
    });

  final items = <_ListItem>[];
  for (final key in sortedKeys) {
    final monthEntries = groups[key]!;
    items.add(_MonthGroupHeader(
      year: key.$1,
      month: key.$2,
      entries: monthEntries,
    ));
    items.addAll(monthEntries.map(_EntryListItem.new));
  }
  return items;
}

// ── List item types ───────────────────────────────────────────────────────────

sealed class _ListItem {}

class _MonthGroupHeader extends _ListItem {
  final int year;
  final int month;
  final List<FuelEntry> entries;

  _MonthGroupHeader({
    required this.year,
    required this.month,
    required this.entries,
  });

  double get totalLiters => entries.fold(0, (s, e) => s + e.liters);
  double get totalCost => entries.fold(0, (s, e) => s + e.totalCost);
}

class _EntryListItem extends _ListItem {
  final FuelEntry entry;
  _EntryListItem(this.entry);
}

// ── Month header widget ───────────────────────────────────────────────────────

class _MonthHeaderWidget extends StatelessWidget {
  final _MonthGroupHeader header;

  const _MonthHeaderWidget({required this.header});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final monthLabel = DateFormat('MMMM yyyy').format(
      DateTime(header.year, header.month),
    );
    final litersLabel = NumberFormat('#0.0').format(header.totalLiters);
    final costLabel =
        NumberFormat.currency(symbol: '€').format(header.totalCost);
    final count = header.entries.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                monthLabel,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              '$count tankbeurt${count == 1 ? '' : 'en'}  ·  $litersLabel L  ·  $costLabel',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.outlineVariant,
          ),
        ],
      ),
    );
  }
}
