// ABOUTME: Repository implementation wrapping datasource with Either error handling
// ABOUTME: Converts DataException to DatabaseFailure for domain layer

import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/fuel_entry_local_datasource.dart';
import '../models/fuel_entry_model.dart';
import '../../domain/entities/fuel_entry.dart';
import '../../domain/repositories/fuel_entry_repository.dart';

class FuelEntryRepositoryImpl implements FuelEntryRepository {
  final FuelEntryLocalDataSource dataSource;

  FuelEntryRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<FuelEntry>>> getAllEntries() async {
    try {
      final entries = await dataSource.getAllEntries();
      return Right(entries);
    } on DataException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, FuelEntry>> getEntryById(String id) async {
    try {
      final entry = await dataSource.getEntryById(id);
      return Right(entry);
    } on DataException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, FuelEntry>> addEntry(FuelEntry entry) async {
    try {
      final model = FuelEntryModel.fromEntity(entry);
      final addedEntry = await dataSource.addEntry(model);
      return Right(addedEntry);
    } on DataException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, FuelEntry>> updateEntry(FuelEntry entry) async {
    try {
      final model = FuelEntryModel.fromEntity(entry);
      final updatedEntry = await dataSource.updateEntry(model);
      return Right(updatedEntry);
    } on DataException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteEntry(String id) async {
    try {
      await dataSource.deleteEntry(id);
      return const Right(unit);
    } on DataException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }
}
