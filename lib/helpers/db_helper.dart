import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class DBHelper with ChangeNotifier {
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'woofdatabase.db'),
        onCreate: (db, version) => _createDb(db), version: 1);
  }

  static void _createDb(Database db) {
    db.execute(
        'CREATE TABLE location_infos(id TEXT PRIMARY KEY, distance INTEGER, latitude TEXT, longitude TEXT, locale TEXT)');
    db.execute(
        'CREATE TABLE notification_infos(id TEXT PRIMARY KEY, userName TEXT, action TEXT, createdAt TEXT, animalId TEXT, uid TEXT)');
    db.execute(
        'CREATE TABLE notification_counter(id TEXT PRIMARY KEY, notificationNumber INTEGER)');
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    db.insert(
      table,
      data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  static Future<bool> isEmptyTable() async {
    final db = await DBHelper.database();
    var count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM location_infos'));
    if (count! > 0) {
      return false;
    }
    return true;
  }

  static Future<void> deleteNotification(String id) async {
    final db = await DBHelper.database();
    await db.rawQuery('DELETE FROM notification_infos WHERE id = $id');
  }

  static Future<Map<String, dynamic>?> getData(String table, String id) async {
    final db = await DBHelper.database();
    final List<Map<String, dynamic>> maps = await db.query(table);
    final item = maps.firstWhereOrNull((element) => element['id'] == id);
    return item;
  }

  static Future<List<Map<String, dynamic>>> getAllDataSQL(String table) async {
    final db = await DBHelper.database();
    final List<Map<String, dynamic>> maps = await db.query(table);
    return maps;
  }
}
