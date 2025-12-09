import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/run_data.dart';

class RunLocalDB {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'runs.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE runs (
            id TEXT PRIMARY KEY,
            distance REAL,
            route TEXT,
            timestamp TEXT,
            endTime TEXT,
            targetDistance REAL,
            duration INTEGER,
            synced INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE runs ADD COLUMN endTime TEXT');
          await db.execute('ALTER TABLE runs ADD COLUMN duration INTEGER');
        }
      },
    );
  }

  static Future<void> insertRun(RunData run) async {
    final db = await database;
    await db.insert(
      'runs',
      run.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Print to console after saving
    // RunLocalDB.getAllRuns().then((runs) {
    //   print("=== LOCAL RUNS (SQLite) ===");
    //   for (var r in runs) {
    //     print(r.toMap());
    //   }
    // });
  }

  static Future<List<RunData>> getAllRuns() async {
    final db = await database;
    final result = await db.query('runs', orderBy: 'timestamp DESC');
    return result.map((map) => RunData.fromMap(map)).toList();
  }

  static Future<RunData?> getRunById(String id) async {
    final db = await database;
    final result = await db.query('runs', where: 'id = ?', whereArgs: [id]);

    if (result.isEmpty) return null;
    return RunData.fromMap(result.first);
  }

  static Future<List<RunData>> getUnsyncedRuns() async {
    final db = await database;
    final result = await db.query('runs', where: 'synced = ?', whereArgs: [0]);
    return result.map((map) => RunData.fromMap(map)).toList();
  }

  static Future<void> markAsSynced(String id) async {
    final db = await database;
    await db.update('runs', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> updateRun(RunData run) async {
    final db = await database;
    await db.update('runs', run.toMap(), where: 'id = ?', whereArgs: [run.id]);
  }

  static Future<void> deleteRun(String id) async {
    final db = await database;
    await db.delete('runs', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteAllRuns() async {
    final db = await database;
    await db.delete('runs');
  }

  static Future<int> getRunCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM runs');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  static Future<double> getTotalDistance() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(distance) as total FROM runs');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  static Future<List<RunData>> getRunsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final result = await db.query(
      'runs',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => RunData.fromMap(map)).toList();
  }
}
