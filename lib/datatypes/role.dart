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

class Role {
  int id;
  String name;
  Color color;

  Role({this.id, this.name, this.color});

  static Role fromMap(Map<String, dynamic> m) {
    return Role(
        id: m['id'],
        name: m['name'],
        color: m['color'] == null ? null : Color(m['color'])
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> ret = {
      'name': this.name,
      'color': this.color.value
    };

    if (id != null) {
      ret['id'] = this.id;
    }

    return ret;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Role && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id;
}

class RoleProvider {
  static Future<Role> create(Role role) async {
    role.id = await (await DB.instance).db.insert('Role', role.toMap());
    return role;
  }

  static Future<List<Role>> getAll() async {
    List<Map<String, dynamic>> roles = await (await DB.instance).db.query('Role', columns: ['id', 'name', 'color']);
    return roles.map((m) => Role.fromMap(m)).toList();
  }

  static Future<Role> get(int id) async {
    Map<String, dynamic> m = (await (await DB.instance).db.query('Role', columns: ['id', 'name', 'color'], where: 'id = ?', whereArgs: [id])).first ?? null;
    return m == null ? null : Role.fromMap(m);
  }

  static Future<int> delete(int id) async {
    return await (await DB.instance)
        .db
        .delete('Role', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> update(Role role) async {
    return await (await DB.instance).db.update(
        'Role', role.toMap()..remove('id'),
        where: 'id = ?', whereArgs: [role.id]);
  }
}