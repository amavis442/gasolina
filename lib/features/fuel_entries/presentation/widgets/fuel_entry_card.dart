// ABOUTME: Widget displaying a single fuel entry in a card format
// ABOUTME: Shows date, liters, kilometers, cost, and calculated metrics

import 'package:flutter/material.dart';
import '../../domain/entities/fuel_entry.dart';
import '../../../../generated/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class FuelEntryCard extends StatelessWidget {
  final FuelEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const FuelEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '€');
    final decimalFormat = NumberFormat('#0.00');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateFormat.format(entry.date),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: l10n.tooltipDeleteEntry,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.local_gas_station,
                      label: l10n.cardLabelLiters,
                      value: '${decimalFormat.format(entry.liters)} L',
                    ),
                  ),
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.route,
                      label: l10n.cardLabelDistance,
                      value: '${decimalFormat.format(entry.kilometers)} km',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.euro,
                      label: l10n.cardLabelTotalCost,
                      value: currencyFormat.format(entry.totalCost),
                    ),
                  ),
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.speed,
                      label: l10n.cardLabelEfficiency,
                      value: '${decimalFormat.format(entry.efficiency)} km/L',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.attach_money, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      l10n.cardLabelPricePerLiter(currencyFormat.format(entry.pricePerLiter)),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
