// ABOUTME: Use case that triggers a bidirectional sync with the remote API
// ABOUTME: Delegates to SyncRepository and passes SyncConfig from caller

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/sync_config.dart';
import '../repositories/sync_repository.dart';

class SyncFuelEntries {
  final SyncRepository repository;

  SyncFuelEntries(this.repository);

  Future<Either<Failure, Unit>> call(SyncConfig config) {
    return repository.sync(config);
  }
}
