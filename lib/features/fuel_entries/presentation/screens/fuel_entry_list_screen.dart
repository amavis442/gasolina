// ABOUTME: Screen displaying fuel entries grouped by calendar month or wage period (25th–24th)
// ABOUTME: Uses Riverpod for state management and navigation to form screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/fuel_entry.dart';
import '../providers/fuel_entry_providers.dart';
import 'fuel_entry_form_screen.dart';
import '../widgets/fuel_entry_card.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/utils/wage_period.dart';
import '../providers/wage_day_provider.dart';
import 'package:intl/intl.dart';

enum _PeriodMode { calendar, wage }

class FuelEntryListScreen extends ConsumerStatefulWidget {
  const FuelEntryListScreen({super.key});

  @override
  ConsumerState<FuelEntryListScreen> createState() =>
      _FuelEntryListScreenState();
}

class _FuelEntryListScreenState extends ConsumerState<FuelEntryListScreen> {
  _PeriodMode _mode = _PeriodMode.calendar;

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(fuelEntriesProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.screenFuelEntries)),
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

          final wageDay = ref.watch(wageDayProvider);
          final items = _mode == _PeriodMode.calendar
              ? _buildCalendarGroupedList(entries)
              : _buildWageGroupedList(entries, wageDay);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: SegmentedButton<_PeriodMode>(
                  segments: [
                    ButtonSegment(
                      value: _PeriodMode.calendar,
                      icon: Icon(Icons.calendar_month_outlined),
                      label: Text(l10n.monthly),
                    ),
                    ButtonSegment(
                      value: _PeriodMode.wage,
                      icon: Icon(Icons.payments_outlined),
                      label: Text(l10n.wagePeriod),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) => setState(() => _mode = s.first),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return switch (item) {
                      _PeriodHeader() => _PeriodHeaderWidget(header: item),
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
                        onDelete: () => _showDeleteConfirmation(
                          context,
                          ref,
                          item.entry.id,
                        ),
                      ),
                    };
                  },
                ),
              ),
            ],
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

List<_ListItem> _buildCalendarGroupedList(List<FuelEntry> entries) {
  final sorted = [...entries]..sort((a, b) => b.date.compareTo(a.date));

  final Map<(int, int), List<FuelEntry>> groups = {};
  for (final entry in sorted) {
    final key = (entry.date.year, entry.date.month);
    groups.putIfAbsent(key, () => []).add(entry);
  }

  final sortedKeys = groups.keys.toList()
    ..sort((a, b) {
      if (a.$1 != b.$1) return b.$1.compareTo(a.$1);
      return b.$2.compareTo(a.$2);
    });

  final items = <_ListItem>[];
  for (final key in sortedKeys) {
    final monthEntries = groups[key]!;
    items.add(
      _PeriodHeader(
        label: DateFormat('MMMM yyyy').format(DateTime(key.$1, key.$2)),
        icon: Icons.calendar_month_outlined,
        entries: monthEntries,
      ),
    );
    items.addAll(monthEntries.map(_EntryListItem.new));
  }
  return items;
}

List<_ListItem> _buildWageGroupedList(List<FuelEntry> entries, int wageDay) {
  final sorted = [...entries]..sort((a, b) => b.date.compareTo(a.date));

  final Map<DateTime, List<FuelEntry>> groups = {};
  for (final entry in sorted) {
    final key = wagePeriodStart(entry.date, wageDay);
    groups.putIfAbsent(key, () => []).add(entry);
  }

  final sortedKeys = groups.keys.toList()..sort((a, b) => b.compareTo(a));

  final items = <_ListItem>[];
  for (final key in sortedKeys) {
    final periodEntries = groups[key]!;
    items.add(
      _PeriodHeader(
        label: wagePeriodLabel(key, wageDay),
        icon: Icons.payments_outlined,
        entries: periodEntries,
      ),
    );
    items.addAll(periodEntries.map(_EntryListItem.new));
  }
  return items;
}

// ── List item types ───────────────────────────────────────────────────────────

sealed class _ListItem {}

class _PeriodHeader extends _ListItem {
  final String label;
  final IconData icon;
  final List<FuelEntry> entries;

  _PeriodHeader({
    required this.label,
    required this.icon,
    required this.entries,
  });

  double get totalLiters => entries.fold(0, (s, e) => s + e.liters);
  double get totalCost => entries.fold(0, (s, e) => s + e.totalCost);
}

class _EntryListItem extends _ListItem {
  final FuelEntry entry;
  _EntryListItem(this.entry);
}

// ── Period header widget ──────────────────────────────────────────────────────

class _PeriodHeaderWidget extends StatelessWidget {
  final _PeriodHeader header;

  const _PeriodHeaderWidget({required this.header});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final litersLabel = NumberFormat('#0.0').format(header.totalLiters);
    final costLabel = NumberFormat.currency(
      symbol: '€',
    ).format(header.totalCost);
    final count = header.entries.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(header.icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                header.label,
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
          Divider(height: 1, thickness: 1, color: colorScheme.outlineVariant),
        ],
      ),
    );
  }
}
