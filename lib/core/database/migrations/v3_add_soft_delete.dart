// ABOUTME: Migration v3 adds deleted_at column to fuel_entries for soft-delete sync support
// ABOUTME: Soft-deleted entries are hidden from queries but retained for server propagation

import 'package:sqflite/sqflite.dart';
import 'migration.dart';

class V3AddSoftDelete implements Migration {
  @override
  int get version => 3;

  @override
  String get description => 'Add deleted_at column to fuel_entries for soft-delete sync';

  @override
  Future<void> up(DatabaseExecutor db) async {
    await db.execute('''
      ALTER TABLE fuel_entries ADD COLUMN deleted_at INTEGER
    ''');
  }

  @override
  Future<void> down(DatabaseExecutor db) async {
    // SQLite does not support DROP COLUMN on older versions; recreate table without it
    await db.execute('''
      CREATE TABLE fuel_entries_backup (
        id TEXT PRIMARY KEY,
        date INTEGER NOT NULL,
        liters REAL NOT NULL CHECK(liters > 0),
        kilometers REAL NOT NULL CHECK(kilometers > 0),
        total_cost REAL NOT NULL CHECK(total_cost > 0),
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      INSERT INTO fuel_entries_backup
        SELECT id, date, liters, kilometers, total_cost, created_at, updated_at
        FROM fuel_entries
    ''');
    await db.execute('DROP TABLE fuel_entries');
    await db.execute('ALTER TABLE fuel_entries_backup RENAME TO fuel_entries');
    await db.execute(
      'CREATE INDEX idx_fuel_entries_date ON fuel_entries(date DESC)',
    );
  }
}
