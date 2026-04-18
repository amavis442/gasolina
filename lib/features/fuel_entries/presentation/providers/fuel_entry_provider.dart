// ABOUTME: Riverpod providers for fuel entry state management and dependency injection
// ABOUTME: Sets up database service, repository, use cases, and UI state providers

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/database/sqflite_database_service.dart';
import '../../data/datasources/fuel_entry_local_datasource.dart';
import '../../data/repositories/fuel_entry_repository_impl.dart';
import '../../domain/entities/fuel_entry.dart';
import '../../domain/repositories/fuel_entry_repository.dart';
import '../../domain/usecases/add_fuel_entry.dart';
import '../../domain/usecases/delete_fuel_entry.dart';
import '../../domain/usecases/get_all_fuel_entries.dart';
import '../../domain/usecases/update_fuel_entry.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return SqfliteDatabaseService();
});

final fuelEntryDataSourceProvider = FutureProvider<FuelEntryLocalDataSource>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  final db = await dbService.database;
  return FuelEntryLocalDataSource(db);
});

final fuelEntryRepositoryProvider = FutureProvider<FuelEntryRepository>((ref) async {
  final dataSource = await ref.watch(fuelEntryDataSourceProvider.future);
  return FuelEntryRepositoryImpl(dataSource);
});

final getAllFuelEntriesProvider = FutureProvider<GetAllFuelEntries>((ref) async {
  final repository = await ref.watch(fuelEntryRepositoryProvider.future);
  return GetAllFuelEntries(repository);
});

final addFuelEntryProvider = FutureProvider<AddFuelEntry>((ref) async {
  final repository = await ref.watch(fuelEntryRepositoryProvider.future);
  return AddFuelEntry(repository);
});

final updateFuelEntryProvider = FutureProvider<UpdateFuelEntry>((ref) async {
  final repository = await ref.watch(fuelEntryRepositoryProvider.future);
  return UpdateFuelEntry(repository);
});

final deleteFuelEntryProvider = FutureProvider<DeleteFuelEntry>((ref) async {
  final repository = await ref.watch(fuelEntryRepositoryProvider.future);
  return DeleteFuelEntry(repository);
});

final fuelEntriesProvider = FutureProvider<List<FuelEntry>>((ref) async {
  final getAllEntries = await ref.watch(getAllFuelEntriesProvider.future);
  final result = await getAllEntries();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (entries) => entries,
  );
});
