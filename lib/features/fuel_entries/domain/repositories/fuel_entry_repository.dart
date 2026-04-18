// ABOUTME: Abstract repository contract for fuel entry data operations
// ABOUTME: Defines CRUD operations returning Either<Failure, Result> for clean error handling

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/fuel_entry.dart';

abstract class FuelEntryRepository {
  Future<Either<Failure, List<FuelEntry>>> getAllEntries();
  Future<Either<Failure, FuelEntry>> getEntryById(String id);
  Future<Either<Failure, FuelEntry>> addEntry(FuelEntry entry);
  Future<Either<Failure, FuelEntry>> updateEntry(FuelEntry entry);
  Future<Either<Failure, Unit>> deleteEntry(String id);
}
