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
 

import 'package:training_stats/datatypes/action.dart' as TrainingStatsAction;
import 'package:training_stats/datatypes/player.dart';

class Record {

  int id;
  Player player;
  TrainingStatsAction.Action action;
  int evaluation;
  DateTime timestamp;

  Record({
    this.id,
    this.player,
    this.action,
    this.evaluation,
    this.timestamp
  }) {
    if(this.timestamp == null) {
      this.timestamp = DateTime.now();
    }
  }

  static Future<Record> fromMap(Map<String, dynamic> m) async {
    return Record(
        id: m['id'],
        player: await PlayerProvider.get(m['player']),
        timestamp: DateTime.parse(m['ts']),
        action: await TrainingStatsAction.ActionProvider.get(m['action']),
        evaluation: m['evaluation']
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> ret = {
      'player': this.player.id,
      'ts': this.timestamp.toIso8601String(),
      'action': this.action.id,
      'evaluation' : this.evaluation
    };

    if (id != null) {
      ret['id'] = this.id;
    }

    return ret;
  }

}