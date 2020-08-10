

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