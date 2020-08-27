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

import 'dart:math';

import 'package:charts_flutter/flutter.dart' as Charts;
import 'package:flutter/material.dart';
import 'package:training_stats/datatypes/player.dart';
import 'package:training_stats/datatypes/record.dart';
import 'package:training_stats/datatypes/action.dart' as TSA;

class TouchesAverage extends StatefulWidget {

  final List<TSA.Action> actions;
  final List<Player> players;
  final List<Record> records;

  TouchesAverage({
    Key key,
    this.actions,
    this.players,
    this.records
  }): super(key: key);

  @override
  _TouchesAverageState createState() => _TouchesAverageState();

}

class _TouchesAverageState extends State<TouchesAverage> {

  final List<int> intervals = [10, 20, 40, 60, 90, 180, 270];
  int timeInterval;

  List<Charts.Series<int, num>> series;
  Map<Player, List<int>> values;

  int minTime, maxTime;

  Future<bool> loading;

  @override
  void initState() {
    timeInterval = intervals.length ~/ 2; ///select the mean one
    minTime = (widget.records.map((e) => e.timestamp.millisecondsSinceEpoch).reduce(min) / 1000.0).floor();
    maxTime = (widget.records.map((e) => e.timestamp.millisecondsSinceEpoch).reduce(max) / 1000.0).ceil();
    _refresh();
    super.initState();
  }

  void _refresh() {
    setState(() {
      loading = _computeValues();
    });
  }

  Future<bool> _computeValues() async {

    values = Map.fromEntries(widget.players.where((player) => widget.records.map((record) => record.player).contains(player)).map<MapEntry<Player, List<int>>>((player) {
      List<int> list = [];
      for(int i = 0; i <= (maxTime - minTime) ~/ intervals[timeInterval]; i++) {
        list.add(
          widget.records.where((record) => record.player == player && (record.timestamp.millisecondsSinceEpoch ~/ 1000.0) >= minTime + (i * intervals[timeInterval]) && minTime + ((i+1) * intervals[timeInterval]) > (record.timestamp.millisecondsSinceEpoch  ~/ 1000.0) && widget.actions.contains(record.action)).length
        );
      }
      return MapEntry(player, list);
    }).toList());

    series = widget.players.where((player) => widget.records.map((record) => record.player).contains(player)).map<Charts.Series<int, num>>((player) => Charts.Series<int, num>(
      id: player.shortName,
      domainFn: (int n, _) => (n * intervals[timeInterval]),
      measureFn: (int n, _) => values[player][n],
      data: List.generate((maxTime - minTime) ~/ intervals[timeInterval], (index) => index)
    )).toList();

    return true;

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Slider(
            value: timeInterval.toDouble(),
            onChanged: (value) {
              setState(() {
                timeInterval = value.toInt();
                _refresh();
              });
            },
            min: 0.0,
            max: intervals.length.toDouble() - 1,
            divisions: intervals.length - 1,
            label: intervals[timeInterval].toString(),
          ),
        ),
        Container(
          padding: EdgeInsets.all(10.0),
          height: 300.0,
          child: FutureBuilder(
            builder: (context, snap) => snap.hasData ? Charts.LineChart(
              series,
              animate: true,
              behaviors: [
                Charts.SeriesLegend(
                  position: Charts.BehaviorPosition.top,
                  outsideJustification: Charts.OutsideJustification.endDrawArea,
                  horizontalFirst: true,
                  desiredMaxColumns: 6,
                )
              ],
            ) : Center(
              child: CircularProgressIndicator(),
            ),
            future: loading,
          ),
        ),
      ],
    );
  }

}