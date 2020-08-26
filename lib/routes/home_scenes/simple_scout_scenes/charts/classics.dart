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

class Stats {

  double total;
  Map<TSA.Action, double> perAction;

  Stats({
    this.total,
    this.perAction
  });

}

class ClassicCharts extends StatefulWidget {

  final List<TSA.Action> actions;
  final List<Player> players;
  final List<Record> records;

  final Map<Player, Stats> positivity;
  final Map<Player, Stats> efficiency;
  final Map<Player, Stats> perfection;
  final Map<Player, Stats> touches;

  ClassicCharts({
    Key key,
    this.actions,
    this.players,
    this.records
  }) : positivity = Map.fromEntries(
    players.map<MapEntry<Player, Stats>>(
        (p) {
          Iterable<Record> filtered = records.where((element) => element.player == p && actions.contains(element.action));

          Stats s = Stats(
            total: filtered.isEmpty ? 0.0 : (filtered.where((element) => element.evaluation > 0).length / filtered.length) * 100,
            perAction: Map.fromEntries(actions.map<MapEntry<TSA.Action, double>>((action) {
              Iterable<Record> aa = filtered.where((element) => element.action == action);
              return MapEntry(
                action,
                aa.isEmpty ? 0.0 : (aa.where((element) => element.evaluation > 0).length / aa.length) * 100
              );
            }))
          );

          return MapEntry(p, s);
        }
    )
  ), efficiency = Map.fromEntries(
      players.map<MapEntry<Player, Stats>>(
          (p) {
            Iterable<Record> filtered = records.where((element) => element.player == p && actions.contains(element.action));

            Stats s = Stats(
                total: filtered.isEmpty ? 0.0 : max(0, ((filtered.where((element) => element.evaluation > 0).length - filtered.where((element) => element.evaluation < 0).length) / filtered.length) * 100),
                perAction: Map.fromEntries(actions.map<MapEntry<TSA.Action, double>>((action) {
                  Iterable<Record> aa = filtered.where((element) => element.action == action);
                  return MapEntry(
                      action,
                      aa.isEmpty ? 0.0 : max(0, ((aa.where((element) => element.evaluation > 0).length - aa.where((element) => element.evaluation < 0).length) / aa.length) * 100)
                  );
                }))
            );

            return MapEntry(p, s);
          }
      )
  ), perfection = Map.fromEntries(
      players.map<MapEntry<Player, Stats>>(
          (p) {
            Iterable<Record> filtered = records.where((element) => element.player == p && actions.contains(element.action));

            Stats s = Stats(
                total: filtered.isEmpty ? 0.0 : max(0, ((filtered.where((element) => element.evaluation == 3).length - filtered.where((element) => element.evaluation < 0).length) / filtered.length) * 100),
                perAction: Map.fromEntries(actions.map<MapEntry<TSA.Action, double>>((action) {
                  Iterable<Record> aa = filtered.where((element) => element.action == action);
                  return MapEntry(
                      action,
                      aa.isEmpty ? 0.0 : max(0, ((aa.where((element) => element.evaluation == 3).length - aa.where((element) => element.evaluation < 0).length) / aa.length) * 100)
                  );
                }))
            );

            return MapEntry(p, s);
          }
      )
  ),
  touches = Map.fromEntries(
      players.map<MapEntry<Player, Stats>>(
              (p) {
            Iterable<Record> filtered = records.where((element) => element.player == p && actions.contains(element.action));

            Stats s = Stats(
                total: filtered.length.toDouble(),
                perAction: Map.fromEntries(actions.map<MapEntry<TSA.Action, double>>((action) {
                  Iterable<Record> aa = filtered.where((element) => element.action == action);
                  return MapEntry(
                      action,
                      aa.length.toDouble()
                  );
                }))
            );

            return MapEntry(p, s);
          }
      )
  ), super(key: key);

  @override
  _ClassicChartsState createState() => _ClassicChartsState();

}

class _ClassicChartsState extends State<ClassicCharts> {

  Map<Player, bool> selected;

  @override
  void initState() {
    selected = Map.fromEntries(widget.players.map((e) => MapEntry(e, false)));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                        Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Text("Player", style: Theme.of(context).textTheme.headline6,),
                        ),
                        Padding(
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
                                      style: Theme.of(context).textTheme.headline6,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 2.0),
                                child: Text("%", style: Theme.of(context).textTheme.headline6,),
                              )
                            ],
                          ),
                        ),
                        Padding(
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
                                      style: Theme.of(context).textTheme.headline6,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 2.0),
                                child: Text("%", style: Theme.of(context).textTheme.headline6,),
                              )
                            ],
                          ),
                        ),
                        Padding(
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
                                      style: Theme.of(context).textTheme.headline6,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 2.0),
                                child: Text("%", style: Theme.of(context).textTheme.headline6,),
                              )
                            ],
                          ),
                        ),
                        Padding(
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
                                      style: Theme.of(context).textTheme.headline6,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 2.0),
                                child: Text("#", style: Theme.of(context).textTheme.headline6,),
                              )
                            ],
                          ),
                        ),
                      ]
                  )
                ] + widget.players.map((player) => [
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
                            widget.positivity[player].total.toStringAsFixed(2),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Text(
                            widget.efficiency[player].total.toStringAsFixed(2),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Text(
                            widget.perfection[player].total.toStringAsFixed(2),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Text(
                            widget.touches[player].total.toInt().toString(),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ]
                  ), ] + widget.actions.map((action) => TableRow(
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
                            widget.positivity[player].perAction[action].toStringAsFixed(2),
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
                            widget.efficiency[player].perAction[action].toStringAsFixed(2),
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
                            widget.perfection[player].perAction[action].toStringAsFixed(2),
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
                            widget.touches[player].perAction[action].toInt().toString(),
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
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    width: max(60.0 + 50.0 * widget.players.where((element) => widget.records.map<Player>((e) => e.player).contains(element)).length, box.maxWidth),
                    height: 300.0,
                    child: Charts.BarChart(
                      [
                        Charts.Series<Player, String>(
                          id: 'Positivity',
                          domainFn: (Player p, _) => p.shortName,
                          measureFn: (Player p, _) => widget.positivity[p].total,
                          data: widget.players.where((element) => widget.records.map<Player>((e) => e.player).contains(element)).toList(), ///select only players which have at least on record
                        ),
                        Charts.Series<Player, String>(
                          id: 'Efficiency',
                          domainFn: (Player p, _) => p.shortName,
                          measureFn: (Player p, _) => widget.efficiency[p].total,
                          data: widget.players.where((element) => widget.records.map<Player>((e) => e.player).contains(element)).toList(), ///select only players which have at least on record
                        ),
                        Charts.Series<Player, String>(
                          id: 'Perfection',
                          domainFn: (Player p, _) => p.shortName,
                          measureFn: (Player p, _) => widget.perfection[p].total,
                          data: widget.players.where((element) => widget.records.map<Player>((e) => e.player).contains(element)).toList(), ///select only players which have at least on record
                        )
                      ],
                      barGroupingType: Charts.BarGroupingType.grouped,
                      animate: true,
                      behaviors: [
                        Charts.SeriesLegend()
                      ],
                    ),
                  ),
                ),
              )
          ),
        )
      ],
    );
  }

}