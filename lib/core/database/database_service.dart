// ABOUTME: Abstract database service interface for data persistence operations
// ABOUTME: Defines contract for database initialization and access

import 'package:sqflite/sqflite.dart';

abstract class DatabaseService {
  Future<Database> get database;
  Future<void> initialize();
  Future<void> close();
}
