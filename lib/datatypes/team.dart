
import 'package:training_stats/datatypes/player.dart';
import 'package:training_stats/utils/db.dart';

import 'role.dart';

class Team {

  int id;
  String teamName;

  Team({this.id, this.teamName});

  static Team fromMap(Map<String, dynamic> m) {
    return Team(id: m['id'], teamName: m['name']);
  }

  Map<String, dynamic> toMap() {

    Map<String, dynamic> ret = {
      'name' : this.teamName
    };


    if(id != null) {
      ret['id'] = this.id;
    }

    return ret;
  }

}

class TeamProvider {

  static Future<Team> create({String teamName = ""}) async {
    Team t = Team(teamName: teamName);
    t.id = await (await DB.instance).db.insert('Team', t.toMap());
    return t;
  }

  static Future<List<Team>> getAll() async {
    List<Map<String, dynamic>> teams = await (await DB.instance).db.query('Team', columns: ['id', 'name']);
    return teams.map((m) => Team.fromMap(m)).toList();
  }

  static Future<int> delete(int id) async {
    return await (await DB.instance).db.delete('Team', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> insertPlayer({int teamId, int playerId}) async {
    return await (await DB.instance).db.insert('PlayerTeam', {
      'team' : teamId,
      'player' : playerId
    });
  }

  static Future<int> removePlayer({int teamId, int playerId}) async {
    return await (await DB.instance).db.delete('PlayerTeam', where: "team = ? AND player = ?", whereArgs: [teamId, playerId]);
  }

  static Future<List<Player>> getPlayers(int teamId) async {
    List<Map<String, dynamic>> maps =  await (await DB.instance).db.query('Player', where: 'id IN (SELECT player FROM PlayerTeam WHERE team = ?)', whereArgs: [teamId]);
    List<Player> players =  maps.map((e) => Player.fromMap(e)).toList();

    for(int i = 0; i < players.length; i++) {
      if(players[i].role != null) {
        players[i].role = await RoleProvider.get(players[i].role.id);
      }
    }

    return players;
  }

  static Future<List<Player>> getPlayersNotInTeam(int teamId, {String query = ""}) async {
    List<Map<String, dynamic>> maps =  await (await DB.instance).db.query('Player', where: 'id NOT IN (SELECT player FROM PlayerTeam WHERE team = ?) AND name LIKE ?', whereArgs: [teamId, "%"+query+"%"]);
    List<Player> players =  maps.map((e) => Player.fromMap(e)).toList();

    for(int i = 0; i < players.length; i++) {
      if(players[i].role != null) {
        players[i].role = await RoleProvider.get(players[i].role.id);
      }
    }

    return players;
  }

}