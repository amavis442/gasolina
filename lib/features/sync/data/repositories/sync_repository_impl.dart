// ABOUTME: Implements SyncRepository by orchestrating local dirty read, remote sync, and local upsert
// ABOUTME: Uses last-write-wins: server entries always overwrite if server updated_at is newer

import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../features/fuel_entries/data/datasources/fuel_entry_local_datasource.dart';
import '../../domain/entities/sync_config.dart';
import '../../domain/repositories/sync_repository.dart';
import '../datasources/sync_config_datasource.dart';
import '../datasources/sync_remote_datasource.dart';

class SyncRepositoryImpl implements SyncRepository {
  final FuelEntryLocalDataSource localDataSource;
  final SyncRemoteDataSource remoteDataSource;
  final SyncConfigDataSource configDataSource;

  SyncRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.configDataSource,
  });

  @override
  Future<Either<Failure, Unit>> sync(SyncConfig config) async {
    try {
      final lastSyncAt = await configDataSource.loadLastSyncAt();
      final dirtyEntries = await localDataSource.getEntriesDirty(lastSyncAt);

      final serverEntries = await remoteDataSource.sync(
        apiBaseUrl: config.apiBaseUrl,
        deviceSecret: config.deviceSecret,
        lastSyncAt: lastSyncAt,
        entries: dirtyEntries,
      );

      for (final dto in serverEntries) {
        final model = dto.toModel();
        await localDataSource.upsertEntry(model, dto.updatedAt);
      }

      await configDataSource.saveLastSyncAt(
          DateTime.now().millisecondsSinceEpoch);

      return const Right(unit);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(SyncFailure('Sync failed: $e'));
    }
  }
}
