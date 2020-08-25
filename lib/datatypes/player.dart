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
 
 
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:training_stats/utils/db.dart';

import 'role.dart';

class Player {
  int id;
  String name;
  String shortName;
  String photo;
  Role role;

  Player({this.id, this.name, this.shortName, this.photo, this.role});

  static Future<Player> fromMap(Map<String, dynamic> m) async {
    return Player(
        id: m['id'],
        name: m['name'],
        shortName: m['short_name'],
        photo: m['photo'],
        role: m['role'] == null ? null : await RoleProvider.get(m['role'])
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> ret = {
      'name': this.name,
      'short_name': this.shortName,
      'photo': this.photo
    };

    if(role != null) {
      ret['role'] = role.id;
    }

    if (id != null) {
      ret['id'] = this.id;
    }

    return ret;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Player && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id;
}

class PlayerProvider {

  static Future<Player> get(int id) async {
    Map<String, dynamic> m = (await (await DB.instance).db.query('Player', where: 'id = ?', whereArgs: [id])).first ?? null;
    return m == null ? null : Player.fromMap(m);
  }

  static Future<Player> create(Player player) async {
    player.id = await (await DB.instance).db.insert('Player', player.toMap());
    return player;
  }

  static Future<List<Player>> getAll({query = ""}) async {
    List<Map<String, dynamic>> maps = await (await DB.instance).db.query('Player', orderBy: "role", where: "name LIKE ?", whereArgs: ["%"+query+"%"]);

    List<Player> players = [];
    for(int i = 0; i < maps.length; i++) {
      players.add(await Player.fromMap(maps[i]));
    }

    return players;
  }

  static Future<int> delete(int id) async {
    return await (await DB.instance)
        .db
        .delete('Player', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> update(Player player) async {
    return await (await DB.instance).db.update(
        'Player', player.toMap()..remove('id'),
        where: 'id = ?', whereArgs: [player.id]);
  }
}

class PlayerListTile extends StatelessWidget {
  final Player player;
  final void Function() onTap;
  final void Function() onLongPress;
  final void Function() onDelete;

  PlayerListTile({this.player, this.onTap, this.onLongPress, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: player.photo != null
          ? CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: FileImage(File(player.photo)),
            )
          : CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Center(
                child: Icon(
                  Icons.account_circle,
                  color: Colors.grey,
                  size: 40.0,
                ),
              )
            ),
      title: Text(player.name),
      subtitle: Text(player.shortName + (player.role == null ? "" : " - " + player.role.name)),
      trailing: onDelete == null ? null : IconButton(
        icon: Icon(
          Icons.delete,
          color: Colors.red,
        ),
        onPressed: onDelete,
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}

class PlayerListTilePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Icon(
              Icons.account_circle,
              color: Colors.grey,
              size: 40.0,
            ),
          )
        ),
        title: Container(
          height: 10.0,
          width: double.infinity,
          margin:
              EdgeInsets.only(right: MediaQuery.of(context).size.width / 3.0),
          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.6)),
          child: null,
        ),
        subtitle: Container(
          height: 10.0,
          margin:
              EdgeInsets.only(right: MediaQuery.of(context).size.width / 2.5),
          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.4)),
          child: null,
        ));
  }
}
