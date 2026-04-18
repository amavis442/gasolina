// ABOUTME: Simplified Riverpod providers for fuel entry dependency injection
// ABOUTME: Sets up single instance of database, repository, use cases, and state notifier

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/sqflite_database_service.dart';
import '../../data/datasources/fuel_entry_local_datasource.dart';
import '../../data/repositories/fuel_entry_repository_impl.dart';
import '../../domain/entities/fuel_entry.dart';
import '../../domain/usecases/add_fuel_entry.dart';
import '../../domain/usecases/delete_fuel_entry.dart';
import '../../domain/usecases/get_all_fuel_entries.dart';
import '../../domain/usecases/update_fuel_entry.dart';
import 'fuel_entries_notifier.dart';
import 'package:sqflite/sqflite.dart';

final databaseProvider = Provider<Future<Database>>((ref) async {
  final dbService = SqfliteDatabaseService();
  await dbService.initialize();
  return dbService.database;
});

final dataSourceProvider = Provider<FuelEntryLocalDataSource>((ref) {
  throw UnimplementedError('dataSourceProvider must be overridden');
});

final repositoryProvider = Provider((ref) {
  final dataSource = ref.watch(dataSourceProvider);
  return FuelEntryRepositoryImpl(dataSource);
});

final getAllEntriesUseCaseProvider = Provider((ref) {
  final repository = ref.watch(repositoryProvider);
  return GetAllFuelEntries(repository);
});

final addEntryUseCaseProvider = Provider((ref) {
  final repository = ref.watch(repositoryProvider);
  return AddFuelEntry(repository);
});

final updateEntryUseCaseProvider = Provider((ref) {
  final repository = ref.watch(repositoryProvider);
  return UpdateFuelEntry(repository);
});

final deleteEntryUseCaseProvider = Provider((ref) {
  final repository = ref.watch(repositoryProvider);
  return DeleteFuelEntry(repository);
});

final fuelEntriesProvider =
    StateNotifierProvider<FuelEntriesNotifier, AsyncValue<List<FuelEntry>>>(
  (ref) {
    return FuelEntriesNotifier(
      getAllEntries: ref.watch(getAllEntriesUseCaseProvider),
      addEntry: ref.watch(addEntryUseCaseProvider),
      updateEntry: ref.watch(updateEntryUseCaseProvider),
      deleteEntry: ref.watch(deleteEntryUseCaseProvider),
    );
  },
);
