/*
 *
 * statistics.training Stats: mobile app that helps collecting data during
 * statistics.trainings of team sports.
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
import 'dart:ui';
import 'package:charts_flutter/flutter.dart' as Charts;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:training_stats/datatypes/player.dart';
import 'package:training_stats/datatypes/statistics.dart';
import 'exportable_chart_state.dart';



class EfficiencyChart extends StatefulWidget {

  final Statistics statistics;

  EfficiencyChart({
    Key key,
    this.statistics
  }) : super(key: key);

  @override
  _EfficiencyChartState createState() => _EfficiencyChartState();

}

class _EfficiencyChartState extends ExportableChartState<EfficiencyChart> {

  bool showLongNames = false;

  Iterable<Player> players;
  Map<Color, Map<String, Map<Player, int>>> values;
  List<Charts.Series<Player, String>> series;
  Future<bool> loading;

  GlobalKey _chartKey = GlobalKey();

  @override
  void initState() {
    _refresh();
    super.initState();
  }

  void _refresh() {
    loading = _computeValues();
  }


  Future<bool> _computeValues() async {

    players = widget.statistics.players;
    values = widget.statistics.efficiencyChartData;

    series = [
      Charts.Series<Player, String>(
        id: 'Points',
        colorFn: (__, _) => Charts.Color(r: Colors.green.red, g: Colors.green.green, b: Colors.green.blue),
        domainFn: (Player p, _) => p.shortName,
        measureFn: (Player p, _) => widget.statistics.training.actionsSums[p].entries.where((entry) => entry.key.winning).map((entry) => entry.value[3]).reduce((e1, e2) => e1+e2), ///sum of all perfect winning actions
        data: widget.statistics.players
      ),
      Charts.Series<Player, String>(
        id: 'Efficiency',
        colorFn: (__, _) => Charts.Color(r: Colors.blue.red, g: Colors.blue.green, b: Colors.blue.blue),
        domainFn: (Player p, _) => p.shortName,
        measureFn: (Player p, _) => widget.statistics.training.actionsSums[p].entries.where((entry) => entry.key.winning).map((entry) => entry.value[3]).reduce((e1, e2) => e1+e2) - widget.statistics.training.actionsSums[p].entries.where((entry) => entry.key.losing).map((entry) => entry.value[-3]).reduce((e1, e2) => e1+e2), ///sum of all perfect winning actions minus sum of all terrible losing actions
        data: widget.statistics.players
      ),
      Charts.Series<Player, String>(
        id: 'Errors',
        colorFn: (__, _) => Charts.Color(r: Colors.red.red, g: Colors.red.green, b: Colors.red.blue),
        domainFn: (Player p, _) => p.shortName,
        measureFn: (Player p, _) => widget.statistics.training.actionsSums[p].entries.where((entry) => entry.key.losing).map((entry) => entry.value[-3]).reduce((e1, e2) => e1+e2), ///sum of all terrible losing actions
        data: widget.statistics.players
      ),
    ];

    return true;

  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loading,
      builder: (context, snap) => snap.hasData ? Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (OverscrollIndicatorNotification overScroll) {
              overScroll.disallowGlow();
              return false;
            },
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Table(
                      defaultColumnWidth: IntrinsicColumnWidth(),
                      border: TableBorder.all(
                        color: Colors.grey.withOpacity(.2),
                      ),
                      children: [
                        TableRow(
                          children: [
                            GestureDetector(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child: Text("Player", style: Theme.of(context).textTheme.button,),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5.0),
                                      child: Icon(
                                        showLongNames? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                                        size: 15.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  showLongNames = !showLongNames;
                                });
                              },
                            ),
                          ]
                        )
                      ] + players.map((player) => TableRow(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(3.0),
                            child: Row(
                                children: [
                                  Tooltip(
                                    message: player.role.name,
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 10.0),
                                      child: Container(
                                        height: 20.0,
                                        width: 20.0,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: player.role.color
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(showLongNames ? player.name : player.shortName),
                                ]
                            ),
                          )
                        ]
                      )).toList()
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Table(
                        defaultColumnWidth: IntrinsicColumnWidth(),
                        border: TableBorder.all(
                          color: Colors.grey.withOpacity(.2),
                        ),
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          TableRow(
                            children: values.entries.map((entry) => entry.value.keys.map((columnName) => Container(
                              padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                              color: entry.key,
                              child: Text(
                                columnName,
                                maxLines: 1,
                                style: Theme.of(context).textTheme.button,
                                textAlign: TextAlign.center,
                              ),
                            ))).expand((element) => element).toList(),
                          )
                        ] + players.map((player) => TableRow(
                          children: values.entries.map((entry) => entry.value.values.map((value) => Container(
                            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                            color: entry.key,
                            child: Text(
                              value[player].toString(),
                              textAlign: TextAlign.center,
                            ),
                          ))).expand((element) => element).toList(),
                        ),
                        ).toList()
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Divider(),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints box) => Scrollbar(
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (OverscrollIndicatorNotification overScroll) {
                  overScroll.disallowGlow();
                  return false;
                },
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: RepaintBoundary(
                    key: _chartKey,
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      width: max(60.0 + 50.0 * widget.statistics.training.players.where((element) => widget.statistics.training.records.map<Player>((e) => e.player).contains(element)).length, box.maxWidth),
                      height: 370.0,
                      child: Charts.BarChart(
                        series,
                        barGroupingType: Charts.BarGroupingType.grouped,
                        animate: true,
                        behaviors: [
                          Charts.SeriesLegend(
                              desiredMaxColumns: 3
                          )
                        ],
                      ),
                    ),
                  )
                ),
              )
            ),
          )
        ],
      ) : Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: CircularProgressIndicator(),
        ),
      )
    );
  }

  @override
  Future<ExportedChart> getImage() async {
    RenderRepaintBoundary boundary = _chartKey.currentContext.findRenderObject();
    return ExportedChart(
        title: "Points, errors and efficiency",
        image: await (await boundary.toImage(pixelRatio: 8.0)).toByteData(format: ImageByteFormat.png)
    );
  }

}