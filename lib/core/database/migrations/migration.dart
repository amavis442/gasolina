// ABOUTME: Abstract interface defining the contract for database migrations
// ABOUTME: Provides version tracking, description, and up/down migration methods

import 'package:sqflite/sqflite.dart';

abstract class Migration {
  /// The target version number for this migration
  int get version;

  /// Human-readable description of what this migration does
  String get description;

  /// Execute the migration (upgrade schema)
  Future<void> up(DatabaseExecutor db);

  /// Rollback the migration (downgrade schema)
  Future<void> down(DatabaseExecutor db);
}
