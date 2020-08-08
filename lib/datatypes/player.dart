
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
      photo: m['photo']
    );
  }

  Map<String, dynamic> toMap() {

    Map<String, dynamic> ret = {
      'name' : this.name,
      'short_name' : this.shortName,
      'photo' : this.photo
    };


    if(id != null) {
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
    List<Map<String, dynamic>> teams = await (await DB.instance).db.query('Player', columns: ['id', 'name', 'short_name', 'photo']);
    return teams.map((m) => Player.fromMap(m)).toList();
  }

  static Future<int> delete(int id) async {
    return await (await DB.instance).db.delete('Player', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> update(Player player) async {
    return await (await DB.instance).db.update('Player', player.toMap().remove('id'), where: 'id = ?', whereArgs: [player.id]);
  }

}