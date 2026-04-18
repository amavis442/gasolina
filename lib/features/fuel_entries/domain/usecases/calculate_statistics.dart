// ABOUTME: Use case for calculating aggregate statistics from all fuel entries
// ABOUTME: Returns Either<Failure, FuelStatistics> with totals and averages

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/fuel_statistics.dart';
import '../repositories/fuel_entry_repository.dart';

class CalculateStatistics {
  final FuelEntryRepository repository;

  CalculateStatistics(this.repository);

  Future<Either<Failure, FuelStatistics>> call() async {
    final result = await repository.getAllEntries();

    return result.fold(
      (failure) => Left(failure),
      (entries) {
        if (entries.isEmpty) {
          return const Right(FuelStatistics(
            totalEntries: 0,
            totalLiters: 0.0,
            totalKilometers: 0.0,
            totalCost: 0.0,
            averagePricePerLiter: 0.0,
            averageEfficiency: 0.0,
          ));
        }

        final totalLiters = entries.fold<double>(
          0.0,
          (sum, entry) => sum + entry.liters,
        );

        final totalKilometers = entries.fold<double>(
          0.0,
          (sum, entry) => sum + entry.kilometers,
        );

        final totalCost = entries.fold<double>(
          0.0,
          (sum, entry) => sum + entry.totalCost,
        );

        final averagePricePerLiter = totalCost / totalLiters;
        final averageEfficiency = totalKilometers / totalLiters;

        return Right(FuelStatistics(
          totalEntries: entries.length,
          totalLiters: totalLiters,
          totalKilometers: totalKilometers,
          totalCost: totalCost,
          averagePricePerLiter: averagePricePerLiter,
          averageEfficiency: averageEfficiency,
        ));
      },
    );
  }
}
