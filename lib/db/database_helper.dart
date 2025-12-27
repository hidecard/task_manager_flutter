import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static bool _isInitialized = false;

  DatabaseHelper._init();

  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      // Initialize database factory based on platform
      if (kIsWeb) {
        databaseFactory = databaseFactoryFfiWeb;
      } else {
        databaseFactory = databaseFactoryFfi;
      }
      _isInitialized = true;
    }
  }

  static Future<Database> get database async {
    await _ensureInitialized();
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  static Future<Database> _initDB(String filePath) async {
    try {
      if (kIsWeb) {
        // For web, use in-memory database with a unique name
        return await openDatabase(
          'tasks_${DateTime.now().millisecondsSinceEpoch}.db',
          version: 1,
          onCreate: _createDB,
        );
      } else {
        // For other platforms, use file-based database
        final dbPath = await getDatabasesPath();
        final path = join(dbPath, filePath);
        return await openDatabase(path, version: 1, onCreate: _createDB);
      }
    } catch (e) {
      // Fallback: try in-memory database if file-based fails
      return await openDatabase(':memory:', version: 1, onCreate: _createDB);
    }
  }

  static Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE tasks(
id INTEGER PRIMARY KEY AUTOINCREMENT,
title TEXT NOT NULL,
description TEXT NOT NULL,
isCompleted INTEGER NOT NULL
)
''');
  }

  // CRUD operations
  static Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  static Future<List<Task>> getTasks() async {
    final db = await database;
    final result = await db.query('tasks');
    return result.map((e) => Task.fromMap(e)).toList();
  }

  static Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  static Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
