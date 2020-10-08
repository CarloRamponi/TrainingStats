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
import 'dart:typed_data';
import 'dart:ui';

import 'package:charts_flutter/flutter.dart' as Charts;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:random_string/random_string.dart';
import 'package:training_stats/datatypes/statistics.dart';
import 'package:path/path.dart' as path;
import 'package:training_stats/routes/home_scenes/simple_scout_scenes/charts/exportable_chart_state.dart';

class TouchesAverage extends StatefulWidget {

  final Statistics statistics;

  TouchesAverage({
    Key key,
    this.statistics,
  }): super(key: key);

  @override
  TouchesAverageState createState() => TouchesAverageState();

}

class TouchesAverageState extends ExportableChartState<TouchesAverage> {

  int intervalIndex;

  Future<bool> loading;

  GlobalKey _chartKey = GlobalKey();

  @override
  void initState() {
    intervalIndex = 1; ///select the second one
    loading = _loadFirstData();
    super.initState();
  }

  Future<bool> _loadFirstData() async {
    widget.statistics.touchesAverage(intervalIndex);
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
            value: intervalIndex.toDouble(),
            onChanged: (value) {
              setState(() {
                intervalIndex = value.toInt();
              });
            },
            min: 0.0,
            max: widget.statistics.touchesAverageIntervals.length.toDouble() - 1,
            divisions: widget.statistics.touchesAverageIntervals.length - 1,
            label: widget.statistics.touchesAverageIntervals[intervalIndex].toString(),
          ),
        ),
        Container(
          padding: EdgeInsets.all(10.0),
          height: 300.0,
          child: FutureBuilder(
            builder: (context, snap) => snap.hasData ? RepaintBoundary(
              key: _chartKey,
              child: Charts.LineChart(
                widget.statistics.training.players.where((player) => widget.statistics.training.records.map((record) => record.player).contains(player)).map<Charts.Series<int, num>>((player) => Charts.Series<int, num>(
                    id: player.shortName,
                    domainFn: (int n, _) => (n * widget.statistics.touchesAverageIntervals[intervalIndex]),
                    measureFn: (int n, _) => widget.statistics.touchesAverage(intervalIndex)[player][n],
                    data: List.generate(widget.statistics.touchesAverage(intervalIndex)[player].length, (index) => index)
                )).toList(),
                animate: true,
                behaviors: [
                  Charts.SeriesLegend(
                    position: Charts.BehaviorPosition.top,
                    outsideJustification: Charts.OutsideJustification.endDrawArea,
                    horizontalFirst: true,
                    desiredMaxColumns: 6,
                  )
                ],
              ),
            ) : Center(
              child: CircularProgressIndicator(),
            ),
            future: loading,
          ),
        ),
      ],
    );
  }

  @override
  Future<ExportedChart> getImage() async {
    RenderRepaintBoundary boundary = _chartKey.currentContext.findRenderObject();
    return ExportedChart(
      title: "Actions every ${widget.statistics.touchesAverageIntervals[intervalIndex]} seconds",
      image: await (await boundary.toImage(pixelRatio: 8.0)).toByteData(format: ImageByteFormat.png)
    );
  }

}