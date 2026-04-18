// ABOUTME: Screen displaying price per liter trend chart over time
// ABOUTME: Uses fl_chart to visualize fuel price data from all entries

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../fuel_entries/presentation/providers/fuel_entry_providers.dart';
import '../../../../generated/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class PriceChartScreen extends ConsumerWidget {
  const PriceChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(fuelEntriesProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.screenPriceChart),
      ),
      body: entriesAsync.when(
        data: (entries) {
          if (entries.length < 2) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart,
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
              entry.value.pricePerLiter,
            );
          }).toList();

          final minPrice = sortedEntries
              .map((e) => e.pricePerLiter)
              .reduce((a, b) => a < b ? a : b);
          final maxPrice = sortedEntries
              .map((e) => e.pricePerLiter)
              .reduce((a, b) => a > b ? a : b);

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
                          value: '€${minPrice.toStringAsFixed(2)}',
                          color: Colors.green,
                        ),
                        _StatTile(
                          label: l10n.chartStatMax,
                          value: '€${maxPrice.toStringAsFixed(2)}',
                          color: Colors.red,
                        ),
                        _StatTile(
                          label: l10n.chartStatEntries,
                          value: '${entries.length}',
                          color: Colors.blue,
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
                                '€${value.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                          axisNameWidget: Text(l10n.chartLabelPricePerLiter),
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
                          color: Colors.blue,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                      minY: minPrice * 0.95,
                      maxY: maxPrice * 1.05,
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
