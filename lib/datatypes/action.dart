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




import 'dart:ui';

import 'package:training_stats/utils/db.dart';

class Action {
  int id;
  String name;
  String shortName;
  Color color;
  int index;
  bool winning, losing;

  Action({this.id, this.name, this.shortName, this.color, this.index, this.winning, this.losing});

  static Action fromMap(Map<String, dynamic> m) {
    return Action(
      id: m['id'],
      name: m['name'],
      shortName: m['short_name'],
      color: m['color'] == null ? null : Color(m['color']),
      index: m['orderIndex'],
      winning: m['winning'] == 1,
      losing: m['losing'] == 1
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> ret = {
      'name': this.name,
      'short_name': this.shortName,
      'color': this.color.value,
      'orderIndex' : this.index,
      'winning' : this.winning ? 1 : 0,
      'losing' : this.losing ? 1 : 0
    };

    if (id != null) {
      ret['id'] = this.id;
    }

    return ret;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Action && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id;
}

class ActionProvider {
  static Future<Action> create(Action action) async {
    action.id = await (await DB.instance).db.insert('Action', action.toMap());
    return action;
  }

  static Future<List<Action>> getAll() async {
    List<Map<String, dynamic>> roles = await (await DB.instance).db.query('Action', orderBy: 'orderIndex ASC');
    return roles.map((m) => Action.fromMap(m)).toList();
  }

  static Future<Action> get(int id) async {
    Map<String, dynamic> m = (await (await DB.instance).db.query('Action', where: 'id = ?', whereArgs: [id])).first ?? null;
    return m == null ? null : Action.fromMap(m);
  }

  static Future<int> delete(int id) async {
    return await (await DB.instance).db.delete('Action', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> update(Action action) async {
    return await (await DB.instance).db.update(
        'Action', action.toMap()..remove('id'),
        where: 'id = ?', whereArgs: [action.id]);
  }
}