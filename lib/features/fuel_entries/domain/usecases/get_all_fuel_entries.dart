// ABOUTME: Use case for retrieving all fuel entries from repository
// ABOUTME: Returns Either<Failure, List<FuelEntry>> for error handling

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/fuel_entry.dart';
import '../repositories/fuel_entry_repository.dart';

class GetAllFuelEntries {
  final FuelEntryRepository repository;

  GetAllFuelEntries(this.repository);

  Future<Either<Failure, List<FuelEntry>>> call() async {
    return await repository.getAllEntries();
  }
}
