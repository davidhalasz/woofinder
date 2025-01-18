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
        'CREATE TABLE location_info(id TEXT PRIMARY KEY, distance INTEGER, latitude TEXT, longitude TEXT)');
    db.execute(
        'CREATE TABLE notification_info(id TEXT PRIMARY KEY, notificationNumber INTEGER)');
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    db.insert(
      table,
      data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  notifyListeners();

  static Future<bool> isEmptyTable() async {
    final db = await DBHelper.database();
    var count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM location_info'));
    if (count! > 0) {
      return false;
    }

    return true;
  }

  static Future<Map<String, dynamic>?> getData(String table, String id) async {
    final db = await DBHelper.database();
    final List<Map<String, dynamic>> maps = await db.query(table);
    final item = maps.firstWhereOrNull((element) => element['id'] == id);

    return item;
  }
}
