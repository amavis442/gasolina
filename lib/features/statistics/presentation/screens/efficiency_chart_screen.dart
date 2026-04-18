// ABOUTME: Screen displaying fuel efficiency (km/L) trend chart over time
// ABOUTME: Uses fl_chart to visualize efficiency data from all entries

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../fuel_entries/presentation/providers/fuel_entry_providers.dart';
import '../../../../generated/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class EfficiencyChartScreen extends ConsumerWidget {
  const EfficiencyChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(fuelEntriesProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.screenEfficiencyChart),
      ),
      body: entriesAsync.when(
        data: (entries) {
          if (entries.length < 2) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.emptyNotEnoughData,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.emptyNotEnoughDataHint,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final sortedEntries = [...entries]
            ..sort((a, b) => a.date.compareTo(b.date));

          final spots = sortedEntries.asMap().entries.map((entry) {
            return FlSpot(
              entry.key.toDouble(),
              entry.value.efficiency,
            );
          }).toList();

          final minEfficiency = sortedEntries
              .map((e) => e.efficiency)
              .reduce((a, b) => a < b ? a : b);
          final maxEfficiency = sortedEntries
              .map((e) => e.efficiency)
              .reduce((a, b) => a > b ? a : b);
          final avgEfficiency = sortedEntries
                  .map((e) => e.efficiency)
                  .reduce((a, b) => a + b) /
              sortedEntries.length;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatTile(
                          label: l10n.chartStatMin,
                          value: '${minEfficiency.toStringAsFixed(1)} km/L',
                          color: Colors.red,
                        ),
                        _StatTile(
                          label: l10n.chartStatAvg,
                          value: '${avgEfficiency.toStringAsFixed(1)} km/L',
                          color: Colors.blue,
                        ),
                        _StatTile(
                          label: l10n.chartStatMax,
                          value: '${maxEfficiency.toStringAsFixed(1)} km/L',
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toStringAsFixed(1)} km/L',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                          axisNameWidget: Text(l10n.chartLabelEfficiency),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < sortedEntries.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    DateFormat('MMM dd')
                                        .format(sortedEntries[index].date),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                          axisNameWidget: Text(l10n.chartLabelDate),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.green.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                      minY: minEfficiency * 0.95,
                      maxY: maxEfficiency * 1.05,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(l10n.errorGeneric(error.toString())),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
