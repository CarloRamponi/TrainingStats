import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DB {

  static DB _instance;
  static final _DB_FILE = "training_stats.db";

  Database db;

  static Future<DB> get instance async {
    if(_instance == null) {
      _instance = DB._();
      await _instance._init();
    }
    return _instance;
  }

  DB._();

  Future<Database> _init() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, _DB_FILE);
    // open the database
    db = await openDatabase(path, version: 1, onCreate: (db, version) async {

      await db.execute('''
        CREATE TABLE `Role` (
          `id` INTEGER PRIMARY KEY AUTOINCREMENT,
          `name` VARCHAR(128) NOT NULL,
          `color` INTEGER NULL)
      ''');

      await db.execute('''
        INSERT INTO `Role` (name, color) VALUES
        ('Setter', ${0xff4caf50}),
        ('Libero', ${0xffffc107}),
        ('Middle hitter', ${0xff2196f3}),
        ('Outside hitter', ${0xff9c27b0}),
        ('Opposite hitter', ${0xff009688})
      ''');

      await db.execute('''
        CREATE TABLE `Evaluation` (
          `value` INTEGER PRIMARY KEY,
          `name` CHAR(2) NULL)
      ''');

      await db.execute('''
        INSERT INTO `Evaluation` (value, name) VALUES
        (3, '#'),
        (2, '+'),
        (1, '!'),
        (-1, '/'),
        (-2, '-'),
        (-3, '=')
      ''');

      await db.execute('''
        CREATE TABLE `Player` (
          `id` INTEGER PRIMARY KEY AUTOINCREMENT,
          `name` VARCHAR(128) NULL,
          `short_name` VARCHAR(4) NOT NULL,
          `photo` VARCHAR(128) NULL,
          `role` INTEGER NULL,
          CONSTRAINT `fk_Player_1`
            FOREIGN KEY (`role`)
            REFERENCES `Role` (`id`)
            ON DELETE SET NULL
            ON UPDATE CASCADE)
      ''');

      await db.execute('''
        CREATE TABLE `Team` (
          `id` INTEGER PRIMARY KEY AUTOINCREMENT,
          `name` VARCHAR(128) NOT NULL)
      ''');

      await db.execute('''
        CREATE TABLE `PlayerTeam` (
          `player` INTEGER NOT NULL,
          `team` INTEGER NOT NULL,
          PRIMARY KEY (`player`, `team`),
          CONSTRAINT `fk_PlayerTeam_1`
            FOREIGN KEY (`player`)
            REFERENCES `Player` (`id`)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
          CONSTRAINT `fk_PlayerTeam_2`
            FOREIGN KEY (`team`)
            REFERENCES `Team` (`id`)
            ON DELETE CASCADE
            ON UPDATE CASCADE)
      ''');

    }, onUpgrade: (db, oldversion, newversion) async {
      print("Database upgraded, old version: $oldversion, new version: $newversion");
    });
  }

}