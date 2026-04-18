// ABOUTME: StateNotifier for managing fuel entries list state
// ABOUTME: Handles loading, adding, updating, and deleting entries with AsyncValue

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/fuel_entry.dart';
import '../../domain/usecases/add_fuel_entry.dart';
import '../../domain/usecases/delete_fuel_entry.dart';
import '../../domain/usecases/get_all_fuel_entries.dart';
import '../../domain/usecases/update_fuel_entry.dart';

class FuelEntriesNotifier extends StateNotifier<AsyncValue<List<FuelEntry>>> {
  final GetAllFuelEntries getAllEntries;
  final AddFuelEntry addEntry;
  final UpdateFuelEntry updateEntry;
  final DeleteFuelEntry deleteEntry;

  FuelEntriesNotifier({
    required this.getAllEntries,
    required this.addEntry,
    required this.updateEntry,
    required this.deleteEntry,
  }) : super(const AsyncValue.loading()) {
    loadEntries();
  }

  Future<void> loadEntries() async {
    state = const AsyncValue.loading();

    final result = await getAllEntries();

    result.fold(
      (failure) => state = AsyncValue.error(
        failure.message,
        StackTrace.current,
      ),
      (entries) => state = AsyncValue.data(entries),
    );
  }

  Future<void> add(FuelEntry entry) async {
    final result = await addEntry(entry);

    result.fold(
      (failure) => state = AsyncValue.error(
        failure.message,
        StackTrace.current,
      ),
      (_) => loadEntries(),
    );
  }

  Future<void> update(FuelEntry entry) async {
    final result = await updateEntry(entry);

    result.fold(
      (failure) => state = AsyncValue.error(
        failure.message,
        StackTrace.current,
      ),
      (_) => loadEntries(),
    );
  }

  Future<void> delete(String id) async {
    final result = await deleteEntry(id);

    result.fold(
      (failure) => state = AsyncValue.error(
        failure.message,
        StackTrace.current,
      ),
      (_) => loadEntries(),
    );
  }
}
