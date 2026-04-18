// ABOUTME: Domain entity representing aggregate statistics across all fuel entries
// ABOUTME: Contains totals and averages for reporting and analytics

import 'package:equatable/equatable.dart';

class FuelStatistics extends Equatable {
  final int totalEntries;
  final double totalLiters;
  final double totalKilometers;
  final double totalCost;
  final double averagePricePerLiter;
  final double averageEfficiency;

  const FuelStatistics({
    required this.totalEntries,
    required this.totalLiters,
    required this.totalKilometers,
    required this.totalCost,
    required this.averagePricePerLiter,
    required this.averageEfficiency,
  });

  @override
  List<Object?> get props => [
        totalEntries,
        totalLiters,
        totalKilometers,
        totalCost,
        averagePricePerLiter,
        averageEfficiency,
      ];
}
