// ABOUTME: Use case for deleting a fuel entry from repository
// ABOUTME: Returns Either<Failure, Unit> for error handling

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/fuel_entry_repository.dart';

class DeleteFuelEntry {
  final FuelEntryRepository repository;

  DeleteFuelEntry(this.repository);

  Future<Either<Failure, Unit>> call(String id) async {
    return await repository.deleteEntry(id);
  }
}
