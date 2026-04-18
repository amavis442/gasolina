// ABOUTME: Use case for adding a new fuel entry to repository
// ABOUTME: Returns Either<Failure, FuelEntry> for error handling

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/fuel_entry.dart';
import '../repositories/fuel_entry_repository.dart';

class AddFuelEntry {
  final FuelEntryRepository repository;

  AddFuelEntry(this.repository);

  Future<Either<Failure, FuelEntry>> call(FuelEntry entry) async {
    return await repository.addEntry(entry);
  }
}
