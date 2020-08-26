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

import 'package:charts_flutter/flutter.dart' as Charts;
import 'package:flutter/material.dart';
import 'package:training_stats/datatypes/player.dart';
import 'package:training_stats/datatypes/record.dart';
import 'package:training_stats/datatypes/action.dart' as TSA;

class EvalAverageChart extends StatelessWidget {

  final List<TSA.Action> actions;
  final List<Player> players;
  final List<Record> records;

  final List<Charts.Series<Player, String>> data;

  EvalAverageChart({
    Key key,
    this.actions,
    this.players,
    this.records
  }) : data = actions.map<Charts.Series<Player, String>>((action) => Charts.Series<Player, String>(
    id: action.name,
    domainFn: (Player p, _) => p.shortName,
    measureFn: (Player p, _) {
      Iterable<Record> filtered = records.where((element) => element.player == p && element.action == action);
      return filtered.length > 0 ? filtered.map<int>((e) => e.evaluation).reduce((a, b) => a + b) / filtered.length : 0;
    },
    data: players.where((element) => records.map<Player>((e) => e.player).contains(element)).toList(),
  )).toList(), super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.0 + 50.0*players.length,
      child: Card(
        child: Charts.BarChart(
          data,
          barGroupingType: Charts.BarGroupingType.grouped,
          animate: true,
          vertical: false,
          behaviors: [
            Charts.SeriesLegend()
          ],
        ),
      ),
    );
  }

}