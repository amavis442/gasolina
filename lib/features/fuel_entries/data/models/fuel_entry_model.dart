// ABOUTME: Data layer model for fuel entries with JSON serialization
// ABOUTME: Extends FuelEntry entity and provides fromJson/toJson methods for SQLite

import '../../domain/entities/fuel_entry.dart';

class FuelEntryModel extends FuelEntry {
  // updatedAt is populated when reading from DB; null when constructed outside DB context
  final DateTime? updatedAt;

  const FuelEntryModel({
    required super.id,
    required super.date,
    required super.liters,
    required super.kilometers,
    required super.totalCost,
    super.deletedAt,
    this.updatedAt,
  });

  factory FuelEntryModel.fromJson(Map<String, dynamic> json) {
    return FuelEntryModel(
      id: json['id'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
      liters: (json['liters'] as num).toDouble(),
      kilometers: (json['kilometers'] as num).toDouble(),
      totalCost: (json['total_cost'] as num).toDouble(),
      deletedAt: json['deleted_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['deleted_at'] as int)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updated_at'] as int)
          : null,
    );
  }

  factory FuelEntryModel.fromEntity(FuelEntry entity) {
    return FuelEntryModel(
      id: entity.id,
      date: entity.date,
      liters: entity.liters,
      kilometers: entity.kilometers,
      totalCost: entity.totalCost,
      deletedAt: entity.deletedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'liters': liters,
      'kilometers': kilometers,
      'total_cost': totalCost,
      'deleted_at': deletedAt?.millisecondsSinceEpoch,
    };
  }
}
