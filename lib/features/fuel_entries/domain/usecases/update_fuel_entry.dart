// ABOUTME: Use case for updating an existing fuel entry in repository
// ABOUTME: Returns Either<Failure, FuelEntry> for error handling

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/fuel_entry.dart';
import '../repositories/fuel_entry_repository.dart';

class UpdateFuelEntry {
  final FuelEntryRepository repository;

  UpdateFuelEntry(this.repository);

  Future<Either<Failure, FuelEntry>> call(FuelEntry entry) async {
    return await repository.updateEntry(entry);
  }
}
