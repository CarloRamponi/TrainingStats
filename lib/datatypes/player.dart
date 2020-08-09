import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:training_stats/utils/db.dart';

class Player {
  int id;
  String name;
  String shortName;
  String photo;

  Player({this.id, this.name, this.shortName, this.photo});

  static Player fromMap(Map<String, dynamic> m) {
    return Player(
        id: m['id'],
        name: m['name'],
        shortName: m['short_name'],
        photo: m['photo']);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> ret = {
      'name': this.name,
      'short_name': this.shortName,
      'photo': this.photo
    };

    if (id != null) {
      ret['id'] = this.id;
    }

    return ret;
  }
}

class PlayerProvider {
  static Future<Player> create(Player player) async {
    player.id = await (await DB.instance).db.insert('Player', player.toMap());
    return player;
  }

  static Future<List<Player>> getAll() async {
    List<Map<String, dynamic>> teams = await (await DB.instance)
        .db
        .query('Player', columns: ['id', 'name', 'short_name', 'photo']);
    return teams.map((m) => Player.fromMap(m)).toList();
  }

  static Future<int> delete(int id) async {
    return await (await DB.instance)
        .db
        .delete('Player', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> update(Player player) async {
    return await (await DB.instance).db.update(
        'Player', player.toMap().remove('id'),
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
              child: Icon(
                Icons.account_circle,
                color: Colors.grey,
                size: 50.0,
              ),
            ),
      title: Text(player.name),
      subtitle: Text(player.shortName),
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
          child: Icon(
            Icons.account_circle,
            color: Colors.grey,
            size: 50.0,
          ),
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
              EdgeInsets.only(right: MediaQuery.of(context).size.width / 2.0),
          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.4)),
          child: null,
        ));
  }
}
