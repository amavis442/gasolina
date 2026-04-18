// ABOUTME: Local datasource implementation for fuel entries using SQLite
// ABOUTME: Handles CRUD operations and database interactions with error handling

import '../../../../core/errors/exceptions.dart';
import '../models/fuel_entry_model.dart';
import 'package:sqflite/sqflite.dart';

class FuelEntryLocalDataSource {
  final Database database;

  FuelEntryLocalDataSource(this.database);

  Future<FuelEntryModel> addEntry(FuelEntryModel entry) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      await database.insert(
        'fuel_entries',
        {
          ...entry.toJson(),
          'created_at': now,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return entry;
    } catch (e) {
      throw DataException('Failed to add entry: $e');
    }
  }

  Future<List<FuelEntryModel>> getAllEntries() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'fuel_entries',
        where: 'deleted_at IS NULL',
        orderBy: 'date DESC',
      );

      return maps.map((map) => FuelEntryModel.fromJson(map)).toList();
    } catch (e) {
      throw DataException('Failed to get entries: $e');
    }
  }

  Future<FuelEntryModel> getEntryById(String id) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'fuel_entries',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        throw DataException('Entry not found with id: $id');
      }

      return FuelEntryModel.fromJson(maps.first);
    } catch (e) {
      if (e is DataException) rethrow;
      throw DataException('Failed to get entry: $e');
    }
  }

  Future<FuelEntryModel> updateEntry(FuelEntryModel entry) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final rowsAffected = await database.update(
        'fuel_entries',
        {
          ...entry.toJson(),
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [entry.id],
      );

      if (rowsAffected == 0) {
        throw DataException('Entry not found with id: ${entry.id}');
      }

      return entry;
    } catch (e) {
      if (e is DataException) rethrow;
      throw DataException('Failed to update entry: $e');
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      final rowsAffected = await database.delete(
        'fuel_entries',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        throw DataException('Entry not found with id: $id');
      }
    } catch (e) {
      if (e is DataException) rethrow;
      throw DataException('Failed to delete entry: $e');
    }
  }

  /// Returns entries modified after [lastSyncAtMs] plus any soft-deleted entries.
  /// Used by the sync layer to determine what to push to the server.
  Future<List<FuelEntryModel>> getEntriesDirty(int lastSyncAtMs) async {
    try {
      final List<Map<String, dynamic>> maps = await database.rawQuery(
        'SELECT * FROM fuel_entries WHERE updated_at > ? OR deleted_at IS NOT NULL',
        [lastSyncAtMs],
      );
      return maps.map((map) => FuelEntryModel.fromJson(map)).toList();
    } catch (e) {
      throw DataException('Failed to get dirty entries: $e');
    }
  }

  /// Inserts or replaces an entry received from the server.
  /// Preserves server-provided timestamps; sets created_at only on first insert.
  Future<void> upsertEntry(FuelEntryModel entry, DateTime serverUpdatedAt) async {
    try {
      final existing = await database.query(
        'fuel_entries',
        columns: ['created_at'],
        where: 'id = ?',
        whereArgs: [entry.id],
      );

      final createdAt = existing.isNotEmpty
          ? existing.first['created_at'] as int
          : DateTime.now().millisecondsSinceEpoch;

      await database.insert(
        'fuel_entries',
        {
          ...entry.toJson(),
          'created_at': createdAt,
          'updated_at': serverUpdatedAt.millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DataException('Failed to upsert entry: $e');
    }
  }
}
