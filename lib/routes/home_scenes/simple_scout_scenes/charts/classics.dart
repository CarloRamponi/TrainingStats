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
import 'dart:typed_data';
import 'dart:ui';
import 'package:charts_flutter/flutter.dart' as Charts;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:training_stats/datatypes/evaluation.dart';
import 'package:training_stats/datatypes/player.dart';
import 'package:training_stats/datatypes/statistics.dart';
import 'package:training_stats/routes/home_scenes/simple_scout_scenes/charts/exportable_chart_state.dart';



class ClassicCharts extends StatefulWidget {

  final Statistics statistics;

  ClassicCharts({
    Key key,
    this.statistics
  }) : super(key: key);

  @override
  _ClassicChartsState createState() => _ClassicChartsState();

}

class _ClassicChartsState extends ExportableChartState<ClassicCharts> with TickerProviderStateMixin {

  Map<Player, bool> selected;
  List<Charts.Series<Player, String>> series;
  Future<bool> loading;
  Map<int, String> evaluations;

  bool showLongNames = false;

  GlobalKey _chartKey = GlobalKey();

  @override
  void initState() {
    selected = Map.fromEntries(widget.statistics.training.players.map((e) => MapEntry(e, false)));
    _refresh();
    super.initState();
  }

  void _refresh() {
    loading = _computeValues();
  }


  Future<bool> _computeValues() async {

    evaluations = await EvaluationProvider.getAll();

    series = evaluations.entries.map((entry) => Charts.Series<Player, String>(
      id: entry.value ?? entry.key.toString(),
      domainFn: (Player p, _) => p.shortName,
      measureFn: (Player p, _) => widget.statistics.training.actionsSums[p].values.map((e) => e[entry.key]).reduce((e1, e2) => e1+e2),
      data: widget.statistics.players,
      colorFn: (__, _) => (( Color c ) => Charts.Color(r: c.red, g: c.green, b: c.blue))(Evaluation.getColor(entry.key)),
    )).toList();

    return true;

  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loading,
      builder: (context, snap) => snap.hasData ? Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Row(
              children: [
                AnimatedSize(
                  duration: Duration(milliseconds: 300),
                  vsync: this,
                  alignment: Alignment.centerLeft,
                  child: Table(
                    defaultColumnWidth: IntrinsicColumnWidth(),
                    border: TableBorder.all(
                      color: Colors.grey.withOpacity(.2),
                    ),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
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
                    ] + widget.statistics.players.map((player) => [
                      TableRow(
                          children: [
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
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selected[player] = !selected[player];
                                          });
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 5.0),
                                          child: Icon(
                                            selected[player]? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                            size: 15.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ]
                      ), ] + widget.statistics.training.actions.map((action) => TableRow(
                        children: [
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                            height: selected[player] ? 25.0 : 0.0,
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
                                child: Text(
                                  showLongNames ? action.name : action.shortName,
                                  textAlign: TextAlign.right,
                                )
                            ),
                          ),
                        ]
                    )).toList()).expand((e) => e).toList(),
                  ),
                ),
                Expanded(
                  child: NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (OverscrollIndicatorNotification overScroll) {
                      overScroll.disallowGlow();
                      return false;
                    },
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
                              children: evaluations.entries.map((entry) => Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                                color: Evaluation.getColor(entry.key),
                                child: Text(
                                  entry.value ?? entry.key.toString(),
                                  maxLines: 1,
                                  style: Theme.of(context).textTheme.button.copyWith(color: useWhiteForeground(Evaluation.getColor(entry.key)) ? Colors.white : Colors.black),
                                  textAlign: TextAlign.center,
                                ),
                              )).toList() + [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Total',
                                    maxLines: 1,
                                    style: Theme.of(context).textTheme.button,
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              ]
                          )
                        ] + widget.statistics.players.map((player) => [
                          TableRow(
                              children: evaluations.entries.map((entry) => Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                                color: Evaluation.getColor(entry.key),
                                child: Text(
                                  widget.statistics.training.actionsSums[player].values.map((e) => e[entry.key]).reduce((e1, e2) => e1+e2).toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: useWhiteForeground(Evaluation.getColor(entry.key)) ? Colors.white : Colors.black
                                  ),
                                ),
                              )).toList() + [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                                  child: Text(
                                    widget.statistics.training.actionsSums[player].values.map((e) => e.values.reduce((e1, e2) => e1+e2)).reduce((e1, e2) => e1+e2).toString(),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              ]
                          ), ] + widget.statistics.training.actions.map((action) => TableRow(
                            children: evaluations.keys.map((eval) => AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                              height: selected[player] ? 25.0 : 0.0,
                              child: Container(
                                color: Evaluation.getColor(eval),
                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                                child: Text(
                                  widget.statistics.training.actionsSums[player][action][eval].toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: useWhiteForeground(Evaluation.getColor(eval)) ? Colors.white : Colors.black
                                  ),
                                ),
                              ),
                            )).toList() + [
                              AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                                height: selected[player] ? 25.0 : 0.0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                                  child: Text(
                                    widget.statistics.training.actionsSums[player][action].values.reduce((e1, e2) => e1+e2).toString(),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            ]
                        )).toList()).expand((e) => e).toList(),
                      ),
                    ),
                  ),
                )
              ],
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
                          width: max(60.0 + 50.0 * widget.statistics.players.length, box.maxWidth),
                          height: 370.0,
                          child: Charts.BarChart(
                            series,
                            barGroupingType: Charts.BarGroupingType.grouped,
                            animate: true,
                            behaviors: [
                              Charts.SeriesLegend(
                                desiredMaxColumns: 6
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
        title: "Actions number for each evaluation and action",
        image: await (await boundary.toImage(pixelRatio: 8.0)).toByteData(format: ImageByteFormat.png)
    );
  }

  @override
  Future<ExportedData> getData() async {
    return ExportedData(
      'actions',
      [ <dynamic>['Player', 'Player name', 'Action'] + evaluations.entries.map<dynamic>((eval) => eval.value ?? eval.key.toString()).toList() + <dynamic>['Total'] ] +
        widget.statistics.players.map<List<List<dynamic>>>((player) =>
          [ <dynamic>[player.shortName, player.name, 'All'] + evaluations.keys.map((eval) => widget.statistics.training.actionsSums[player].values.map((e) => e[eval]).reduce((e1, e2) => e1+e2).toString()).toList() ] +
          widget.statistics.training.actions.map<List<dynamic>>((action) =>
            <dynamic>[player.shortName, player.name, action.name] + evaluations.keys.map<dynamic>((eval) => widget.statistics.training.actionsSums[player][action][eval].toString()).toList()
          ).toList()).expand((e) => e).toList()
    );
  }

}