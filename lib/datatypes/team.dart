
import 'package:training_stats/utils/db.dart';

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
    t.id = await (await DB.instance.db).insert('Team', t.toMap());
    return t;
  }

  static Future<List<Team>> getAll() async {
    List<Map<String, dynamic>> teams = await (await DB.instance.db).query('Team', columns: ['id', 'name']);
    return teams.map((m) => Team.fromMap(m)).toList();
  }

}