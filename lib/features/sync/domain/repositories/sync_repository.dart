// ABOUTME: Abstract contract for the sync repository
// ABOUTME: Defines the sync operation boundary between domain and data layers

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/sync_config.dart';

abstract class SyncRepository {
  Future<Either<Failure, Unit>> sync(SyncConfig config);
}
