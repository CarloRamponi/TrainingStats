/*
 *
 * Training Stats: mobile app that helps collecting data during
 * trainings of team sports.
 * Copyright (C) 2020 Carlo Ramponi, magocarlos1999@gmail.com
  * This program is free software: you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
  * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
  * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 * 
 */
 
 
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class DB {

  static DB _instance;
  static final _DB_FILE = "training_stats.db";

  static final _CURRENT_VERSION = 1;

  Database db;

  static Future<DB> get instance async {
    if(_instance == null) {
      _instance = DB._();
      await _instance._init();
    }
    return _instance;
  }

  DB._();

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDbStructure(Database db, int version) async {

    await db.execute('''
        CREATE TABLE `Role` (
          `id` INTEGER PRIMARY KEY AUTOINCREMENT,
          `name` VARCHAR(128) NOT NULL,
          `color` INTEGER NULL)
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

    await db.execute('''
        CREATE TABLE `Action` (
          `id` INTEGER PRIMARY KEY AUTOINCREMENT,
          `name` VARCHAR(128) NOT NULL,
          `short_name` CHAR(2) NOT NULL,
          `color` INTEGER NULL)
      ''');

    await db.execute('''
        CREATE TABLE `Training` (
          `id` INTEGER PRIMARY KEY AUTOINCREMENT,
          `ts_start` TIMESTAMP NOT NULL,
          `ts_end` TIMESTAMP NOT NULL,
          `team` INTEGER NOT NULL,
          CONSTRAINT `fk_Training_1`
            FOREIGN KEY (`team`)
            REFERENCES `Team` (`id`)
            ON DELETE CASCADE
            ON UPDATE CASCADE)
    ''');

    await db.execute('''
        CREATE TABLE `PlayerTraining` (
          `player` INTEGER,
          `training` INTEGER,
          PRIMARY KEY (`player`, `training`),
          CONSTRAINT `fk_PlayerTraining_1`
            FOREIGN KEY (`player`)
            REFERENCES `Player` (`id`)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
          CONSTRAINT `fk_PlayerTraining_2`
            FOREIGN KEY (`training`)
            REFERENCES `Training` (`id`)
            ON DELETE CASCADE
            ON UPDATE CASCADE)
    ''');

    await db.execute('''
        CREATE TABLE `Record` (
          `id` INTEGER PRIMARY KEY AUTOINCREMENT,
          `ts` TIMESTAMP NOT NULL,
          `player` INTEGER NOT NULL,
          `action` INTEGER NOT NULL,
          `training` INTEGER NOT NULL,
          `evaluation` INTEGER NOT NULL,
          CONSTRAINT `fk_Record_1`
            FOREIGN KEY (`action`)
            REFERENCES `Action` (`id`)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
          CONSTRAINT `fk_Record_2`
            FOREIGN KEY (`player`)
            REFERENCES `Player` (`id`)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
          CONSTRAINT `fk_Record_3`
            FOREIGN KEY (`training`)
            REFERENCES `Training` (`id`)
            ON DELETE CASCADE
            ON UPDATE CASCADE)
    ''');

    await db.execute('''
      CREATE TABLE `ActionTraining` (
        `action` INTEGER NOT NULL,
        `training` INTEGER NOT NULL,
        PRIMARY KEY (`action`, `training`),
        CONSTRAINT `fk_ActionTraining_1`
          FOREIGN KEY (`action`)
          REFERENCES `Action` (`id`)
          ON DELETE CASCADE
          ON UPDATE CASCADE,
        CONSTRAINT `fk_ActionTraining_2`
          FOREIGN KEY (`training`)
          REFERENCES `Training` (`id`)
          ON DELETE CASCADE
          ON UPDATE CASCADE)
    ''');

  }

  Future<void> _insertDefaults(Database db, int version) async {

    await db.execute('''
        INSERT INTO `Role` (name, color) VALUES
        ('Setter', ${0xff4caf50}),
        ('Libero', ${0xffffc107}),
        ('Middle hitter', ${0xff2196f3}),
        ('Outside hitter', ${0xff9c27b0}),
        ('Opposite hitter', ${0xff009688})
      ''');

    await db.execute('''
        INSERT INTO `Action` (name, short_name, color) VALUES
          ('Serve', 'SR', ${0xff9c27b0}),
          ('Reception', 'R', ${0xffffc107}),
          ('Block', 'B', ${0xff009688}),
          ('Attack', 'A', ${0xff2196f3}),
          ('Set', 'ST', ${0xff4caf50})
      ''');

  }

  Future<Database> _init() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, _DB_FILE);
    // open the database
    db = await openDatabase(path, version: _CURRENT_VERSION, onConfigure: _onConfigure, onCreate: (db, version) async {

      await _createDbStructure(db, version);
      await _insertDefaults(db, version);

    }, onUpgrade: (db, oldversion, newversion) async {

      print("Database upgraded, old version: $oldversion, new version: $newversion");
      switch(oldversion) {

        default:
          print("WARNING DB version not supported: $oldversion");

      }
    });
  }

  Future<String> exportDB() async {

    String date = DateFormat("y-M-d_H:m:s").format(DateTime.now());
    String path = join((await getTemporaryDirectory()).path, "training_stats_data_$date.json");

    Map<String, dynamic> export = {
      "Role" : await db.query('Role'),
      "Player" : (await db.query('Player')).map((e) => Map.from(e)..remove("photo")).toList(),
      "Team" : await db.query('Team'),
      "PlayerTeam" : await db.query('PlayerTeam'),
      "Action" : await db.query('Action'),
      "Training" : await db.query('Training'),
      "PlayerTraining" : await db.query('PlayerTraining'),
      "Record" : await db.query('Record'),
      "ActionTraining" : await db.query('ActionTraining'),
    };

    String exportJson = jsonEncode(export);

    File(path).writeAsStringSync(exportJson);

    return path;

  }

  /// this function will import an external file as the database overwriting the existing one.
  Future<bool> importData(String path) async {

    await db.close();

    var databasesPath = await getDatabasesPath();
    var dbPath = join(databasesPath, _DB_FILE);

    await deleteDatabase(dbPath);
    db = await openDatabase(dbPath, version: _CURRENT_VERSION, onConfigure: _onConfigure);
    await _createDbStructure(db, _CURRENT_VERSION);

    try {

      /*

      json object will be like this:

      {
        "key" : [array],
        "key" : [array],
        ...
      }

      where "key" is the name of a table and array is the content of that table in this format:
      [
        {
          "attr1" : value1,
          "attr2" : value2,
          ...
        },
        ...
      ]

      where attrN is the name of the column and valueN is the value.

       */


      Map<String, dynamic> jsonData = jsonDecode(File(path).readAsStringSync());

      jsonData.forEach((tableName, tableContent) {
        tableContent.forEach((tableRow) async {
          await db.insert(tableName, tableRow);
        });
      });

      return true;

    } catch (e) {

      print(e);

      //close the corrupted database
      db.close();

      //delete it
      deleteDatabase(dbPath);

      //delete the reference to this instance so that the next db.instance call will create a new one
      _instance = null;

      return false;
    }

  }

}