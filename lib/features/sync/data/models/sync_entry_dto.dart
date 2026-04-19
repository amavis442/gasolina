// ABOUTME: DTO for the sync entry JSON shape exchanged with the gasolina-api
// ABOUTME: Maps between FuelEntryModel (local) and the API's field names/types

import '../../../../features/fuel_entries/data/models/fuel_entry_model.dart';

class SyncEntryDto {
  final String id;
  final double liters;
  final double totalCost;
  final double pricePerL;
  final double kilometers;
  final DateTime fuelledAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const SyncEntryDto({
    required this.id,
    required this.liters,
    required this.totalCost,
    required this.pricePerL,
    required this.kilometers,
    required this.fuelledAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory SyncEntryDto.fromModel(FuelEntryModel model) {
    return SyncEntryDto(
      id: model.id,
      liters: model.liters,
      totalCost: model.totalCost,
      pricePerL: model.pricePerLiter,
      kilometers: model.kilometers,
      fuelledAt: model.date,
      updatedAt: model.updatedAt ?? DateTime.now(),
      deletedAt: model.deletedAt,
    );
  }

  factory SyncEntryDto.fromJson(Map<String, dynamic> json) {
    return SyncEntryDto(
      id: json['id'] as String,
      liters: (json['liters'] as num).toDouble(),
      totalCost: (json['total_cost'] as num).toDouble(),
      pricePerL: (json['price_per_l'] as num).toDouble(),
      kilometers: (json['kilometers'] as num).toDouble(),
      fuelledAt: DateTime.parse(json['fuelled_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'liters': liters,
      'total_cost': totalCost,
      'price_per_l': pricePerL,
      'kilometers': kilometers,
      'fuelled_at': fuelledAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      if (deletedAt != null)
        'deleted_at': deletedAt!.toUtc().toIso8601String(),
    };
  }

  FuelEntryModel toModel() {
    return FuelEntryModel(
      id: id,
      date: fuelledAt.toLocal(),
      liters: liters,
      kilometers: kilometers,
      totalCost: totalCost,
      deletedAt: deletedAt,
      updatedAt: updatedAt,
    );
  }
}
