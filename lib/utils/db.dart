import 'dart:io';

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:typed_data';

class DB {

  static DB _instance;
  static final _ASSET_FILE = "schema.db";
  static final _DB_FILE = "training_stats.db";

  Database db;

  static get instance {
    if(_instance == null) {
      _instance = DB._();
    }
    return _instance;
  }

  DB._() {
    _init();
  }

  void _init() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, _DB_FILE);

    // Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", _ASSET_FILE));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);

    } else {
      print("Opening existing database");
    }
    // open the database
    db = await openDatabase(path);
  }

}