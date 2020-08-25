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

  @override
  bool operator ==(Object other) => identical(this, other) || other is Team && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id;

}

class TeamProvider {

  static Future<Team> create({String teamName = ""}) async {
    Team t = Team(teamName: teamName);
    t.id = await (await DB.instance).db.insert('Team', t.toMap());
    return t;
  }

  static Future<Team> get(int id) async {
    return Team.fromMap((await (await DB.instance).db.query('Team', where: 'id = ?', whereArgs: [id])).first);
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
    List<Map<String, dynamic>> maps =  await (await DB.instance).db.query('Player', where: 'id IN (SELECT player FROM PlayerTeam WHERE team = ?)', whereArgs: [teamId], orderBy: "role");
    List<Player> players = [];
    for(int i = 0; i < maps.length; i++) {
      players.add(await Player.fromMap(maps[i]));
    }

    return players;
  }

  static Future<List<Player>> getPlayersNotInTeam(int teamId, {String query = ""}) async {
    List<Map<String, dynamic>> maps =  await (await DB.instance).db.query('Player', where: 'id NOT IN (SELECT player FROM PlayerTeam WHERE team = ?) AND name LIKE ?', whereArgs: [teamId, "%"+query+"%"], orderBy: "role");
    List<Player> players = [];
    for(int i = 0; i < maps.length; i++) {
      players.add(await Player.fromMap(maps[i]));
    }

    return players;
  }

}