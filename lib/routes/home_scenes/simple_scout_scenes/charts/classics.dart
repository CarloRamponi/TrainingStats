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

class _ClassicChartsState extends ExportableChartState<ClassicCharts> {

  Map<Player, bool> selected;
  List<Charts.Series<Player, String>> series;
  Future<bool> loading;

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

    series = [
      Charts.Series<Player, String>(
        id: 'Positivity',
        domainFn: (Player p, _) => p.shortName,
        measureFn: (Player p, _) => widget.statistics.positivity[p],
        data: widget.statistics.training.players.where((element) => widget.statistics.training.records.map<Player>((e) => e.player).contains(element)).toList(), ///select only players which have at least on record
      ),
      Charts.Series<Player, String>(
        id: 'Efficiency',
        domainFn: (Player p, _) => p.shortName,
        measureFn: (Player p, _) => widget.statistics.efficiency[p],
        data: widget.statistics.training.players.where((element) => widget.statistics.training.records.map<Player>((e) => e.player).contains(element)).toList(), ///select only players which have at least on record
      ),
      Charts.Series<Player, String>(
        id: 'Perfection',
        domainFn: (Player p, _) => p.shortName,
        measureFn: (Player p, _) => widget.statistics.perfection[p],
        data: widget.statistics.training.players.where((element) => widget.statistics.training.records.map<Player>((e) => e.player).contains(element)).toList(), ///select only players which have at least on record
      ),
      Charts.Series<Player, String>(
        id: 'Total actions',
        domainFn: (Player p, _) => p.shortName,
        measureFn: (Player p, _) => widget.statistics.touches[p],
        data: widget.statistics.training.players.where((element) => widget.statistics.training.records.map<Player>((e) => e.player).contains(element)).toList(), ///select only players which have at least on record
      )
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
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: Table(
                  columnWidths: {
                    0: FixedColumnWidth(80.0),
                    1: FixedColumnWidth(65.0),
                    2: FixedColumnWidth(65.0),
                    3: FixedColumnWidth(65.0),
                    4: FixedColumnWidth(60.0),

                  },
                  border: TableBorder.all(
                    color: Colors.grey.withOpacity(.2),
                  ),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                        children: [
                          Tooltip(
                            message: "Player's role color and player name. Tap on a player to see more specific statistics",
                            child: Padding(
                              padding: EdgeInsets.all(3.0),
                              child: Text("Player", style: Theme.of(context).textTheme.button,),
                            ),
                          ),
                          Tooltip(
                            message: "Positivity: (number of positive actions / total number of actions) * 100",
                            child: Padding(
                              padding: EdgeInsets.all(3.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: NotificationListener<OverscrollIndicatorNotification>(
                                      onNotification: (overscroll) {
                                        overscroll.disallowGlow();
                                        return false;
                                      },
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Text(
                                          "Positivity",
                                          maxLines: 1,
                                          style: Theme.of(context).textTheme.button,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 2.0),
                                    child: Text("%", style: Theme.of(context).textTheme.button,),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Tooltip(
                            message: "Efficiency: ((number of perfect actions - number of terrible actions) / total number of actions) * 100",
                            child: Padding(
                              padding: EdgeInsets.all(3.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: NotificationListener<OverscrollIndicatorNotification>(
                                      onNotification: (overscroll) {
                                        overscroll.disallowGlow();
                                        return false;
                                      },
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Text(
                                          "Efficiency",
                                          maxLines: 1,
                                          style: Theme.of(context).textTheme.button,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 2.0),
                                    child: Text("%", style: Theme.of(context).textTheme.button,),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Tooltip(
                            message: "Perfection: (number of perfect actions / total number of actions) * 100",
                            child: Padding(
                              padding: EdgeInsets.all(3.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: NotificationListener<OverscrollIndicatorNotification>(
                                      onNotification: (overscroll) {
                                        overscroll.disallowGlow();
                                        return false;
                                      },
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Text(
                                          "Perfection",
                                          maxLines: 1,
                                          style: Theme.of(context).textTheme.button,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 2.0),
                                    child: Text("%", style: Theme.of(context).textTheme.button,),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Tooltip(
                            message: "Total number of actions",
                            child: Padding(
                              padding: EdgeInsets.all(3.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: NotificationListener<OverscrollIndicatorNotification>(
                                      onNotification: (overscroll) {
                                        overscroll.disallowGlow();
                                        return false;
                                      },
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Text(
                                          "Total actions",
                                          maxLines: 1,
                                          style: Theme.of(context).textTheme.button,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 2.0),
                                    child: Text("#", style: Theme.of(context).textTheme.button,),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ]
                    )
                  ] + widget.statistics.training.players.map((player) => [
                    TableRow(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selected[player] = !selected[player];
                              });
                            },
                            child: Padding(
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
                                  Tooltip(
                                    message: player.name,
                                    child: Text(player.shortName),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(3.0),
                            child: Text(
                              widget.statistics.positivity[player].toStringAsFixed(2),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(3.0),
                            child: Text(
                              widget.statistics.efficiency[player].toStringAsFixed(2),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(3.0),
                            child: Text(
                              widget.statistics.perfection[player].toStringAsFixed(2),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(3.0),
                            child: Text(
                              widget.statistics.touches[player].toString(),
                              textAlign: TextAlign.right,
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
                              padding: EdgeInsets.all(3.0),
                              child: Text(
                                action.name,
                                textAlign: TextAlign.right,
                              )
                          ),
                        ),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                          height: selected[player] ? 25.0 : 0.0,
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: Text(
                              widget.statistics.positivityPerAction[player][action].toStringAsFixed(2),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                          height: selected[player] ? 25.0 : 0.0,
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: Text(
                              widget.statistics.efficiencyPerAction[player][action].toStringAsFixed(2),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                          height: selected[player] ? 25.0 : 0.0,
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: Text(
                              widget.statistics.perfectionPerAction[player][action].toStringAsFixed(2),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                          height: selected[player] ? 25.0 : 0.0,
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: Text(
                              widget.statistics.touchesPerAction[player][action].toString(),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                      ]
                  )).toList()).expand((e) => e).toList(),
                ),
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
        title: "Common indicators for each player (all actions)",
        image: await (await boundary.toImage(pixelRatio: 8.0)).toByteData(format: ImageByteFormat.png)
    );
  }

}