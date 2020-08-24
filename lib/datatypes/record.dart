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

  Record({this.player, this.action, this.evaluation, this.timestamp}) {
    if(this.timestamp == null) {
      this.timestamp = DateTime.now();
    }
  }

  Player player;
  TrainingStatsAction.Action action;
  int evaluation;
  DateTime timestamp;

}