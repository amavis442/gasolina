// ABOUTME: Core domain entity representing a fuel entry with calculated properties
// ABOUTME: Provides pricePerLiter, efficiency (km/l), and costPerKilometer calculations

import 'package:equatable/equatable.dart';

class FuelEntry extends Equatable {
  final String id;
  final DateTime date;
  final double liters;
  final double kilometers;
  final double totalCost;
  final DateTime? deletedAt;

  const FuelEntry({
    required this.id,
    required this.date,
    required this.liters,
    required this.kilometers,
    required this.totalCost,
    this.deletedAt,
  });

  double get pricePerLiter => totalCost / liters;

  double get efficiency => kilometers / liters;

  double get costPerKilometer => totalCost / kilometers;

  @override
  List<Object?> get props => [id, date, liters, kilometers, totalCost, deletedAt];
}
