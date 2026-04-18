// ABOUTME: Riverpod providers for the sync feature — config, state, and use case wiring
// ABOUTME: syncStateProvider drives the sync status indicator in the UI

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../features/fuel_entries/presentation/providers/fuel_entry_providers.dart';
import '../../data/datasources/sync_config_datasource.dart';
import '../../data/datasources/sync_remote_datasource.dart';
import '../../data/repositories/sync_repository_impl.dart';
import '../../domain/entities/sync_config.dart';
import '../../domain/usecases/sync_fuel_entries.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main');
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final syncConfigDataSourceProvider = Provider<SyncConfigDataSource>((ref) {
  return SyncConfigDataSource(
    prefs: ref.watch(sharedPreferencesProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

final syncRemoteDataSourceProvider = Provider<SyncRemoteDataSource>((ref) {
  return SyncRemoteDataSource(
    httpClient: http.Client(),
    configDataSource: ref.watch(syncConfigDataSourceProvider),
  );
});

final syncRepositoryProvider = Provider<SyncRepositoryImpl>((ref) {
  return SyncRepositoryImpl(
    localDataSource: ref.watch(dataSourceProvider),
    remoteDataSource: ref.watch(syncRemoteDataSourceProvider),
    configDataSource: ref.watch(syncConfigDataSourceProvider),
  );
});

final syncUseCaseProvider = Provider<SyncFuelEntries>((ref) {
  return SyncFuelEntries(ref.watch(syncRepositoryProvider));
});

/// Loads the persisted sync configuration for display and use.
final syncConfigProvider = FutureProvider<SyncConfig>((ref) async {
  return ref.watch(syncConfigDataSourceProvider).loadConfig();
});

/// Holds the current sync operation state: null = idle, true = syncing, false = last sync failed.
final syncStateProvider =
    StateNotifierProvider<SyncStateNotifier, AsyncValue<DateTime?>>((ref) {
  return SyncStateNotifier(
    syncUseCase: ref.watch(syncUseCaseProvider),
    configDataSource: ref.watch(syncConfigDataSourceProvider),
  );
});

class SyncStateNotifier extends StateNotifier<AsyncValue<DateTime?>> {
  final SyncFuelEntries syncUseCase;
  final SyncConfigDataSource configDataSource;

  SyncStateNotifier({
    required this.syncUseCase,
    required this.configDataSource,
  }) : super(const AsyncValue.data(null));

  Future<void> triggerSync(SyncConfig config) async {
    if (!config.isConfigured) return;
    state = const AsyncValue.loading();
    final result = await syncUseCase(config);
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (_) => state = AsyncValue.data(DateTime.now()),
    );
  }
}
