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

import 'package:flutter/material.dart' as Material;
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:training_stats/datatypes/action.dart' as TSA;
import 'package:training_stats/datatypes/evaluation.dart';
import 'package:training_stats/datatypes/player.dart';
import 'package:training_stats/datatypes/training.dart';
import 'package:training_stats/routes/home_scenes/simple_scout_scenes/charts/exportable_chart_state.dart';
import 'package:training_stats/utils/functions.dart';

class Statistics {

  final Training training;

  final List<int> touchesAverageIntervals = [10, 20, 40, 60, 90, 180, 270];

  Statistics(this.training) {
    _touchesAverage = List.generate(touchesAverageIntervals.length, (index) => null);
    _minTime = training.records.first.timestamp.millisecondsSinceEpoch ~/ 1000;
    _maxTime = training.records.last.timestamp.millisecondsSinceEpoch ~/ 1000;
  }

  Map<Player, double> _positivity;
  Map<Player, double> _efficiency;
  Map<Player, double> _perfection;
  Map<Player, int> _touches;

  Map<Player, Map<TSA.Action, double>> _positivityPerAction;
  Map<Player, Map<TSA.Action, double>> _efficiencyPerAction;
  Map<Player, Map<TSA.Action, double>> _perfectionPerAction;
  Map<Player, Map<TSA.Action, int>> _touchesPerAction;

  List<Player> _players; //players that have at least one record

  Map<Material.Color, Map<String, Map<Player, int>>> _efficiencyChartData;

  int _maxTime;
  int _minTime;

  List<Map<Player, List<int>>> _touchesAverage;

  List<Player> get players {
    if(_players == null) {
      _players = training.players.where((element) => training.records.map<Player>((e) => e.player).contains(element)).toList(); ///select only players which have at least on record
    }
    return _players;
  }

  Map<Player, List<int>> touchesAverage(int intervalIndex) {
    if(_touchesAverage[intervalIndex] == null) {
      _calculateTouchesAverage(intervalIndex);
    }
    return _touchesAverage[intervalIndex];
  }

  Map<Player, double> get positivity {
    if(_positivity == null) {
      if(_touches == null) {
        _computeTouches();
      }
      _computePositivity();
    }
    return _positivity;
  }

  Map<Player, double> get efficiency {
    if(_efficiency == null) {
      if(_touches == null) {
        _computeTouches();
      }
      _computeEfficiency();
    }
    return _efficiency;
  }

  Map<Player, double> get perfection {
    if(_perfection == null) {
      if(_touches == null) {
        _computeTouches();
      }
      _computePerfection();
    }
    return _perfection;
  }

  Map<Player, int> get touches {
    if(_touches == null) {
      _computeTouches();
    }
    return _touches;
  }

  Map<Player, Map<TSA.Action, double>> get positivityPerAction {
    if(_positivityPerAction == null) {
      _computePositivity();
    }
    return _positivityPerAction;
  }

  Map<Player, Map<TSA.Action, double>> get efficiencyPerAction {
    if(_efficiencyPerAction == null) {
      _computeEfficiency();
    }
    return _efficiencyPerAction;
  }

  Map<Player, Map<TSA.Action, double>> get perfectionPerAction {
    if(_perfectionPerAction == null) {
      _computePerfection();
    }
    return _perfectionPerAction;
  }

  Map<Player, Map<TSA.Action, int>> get touchesPerAction {
    if(_touchesPerAction == null) {
      _computeTouches();
    }
    return _touchesPerAction;
  }

  Map<Material.Color, Map<String, Map<Player, int>>> get efficiencyChartData {
    if(_efficiencyChartData == null) {
      _computeEfficiencyChartData();
    }
    return _efficiencyChartData;
  }

  void _computePositivity() {

    _positivity = Map.fromEntries(
        training.players.map<MapEntry<Player, double>>(
            (p) => MapEntry(p, _touches[p] > 0 ? (training.actionsSums[p].values.map<int>((e) => (e.entries.where((element) => element.key > 0).map((e) => e.value).reduce((a, b) => a + b))).reduce((a, b) => a + b) / _touches[p])*100 : 0.0)
        )
    );

    _positivityPerAction = Map.fromEntries(
      training.players.map<MapEntry<Player, Map<TSA.Action, double>>>((player) => MapEntry(
        player,
        Map.fromEntries(
          training.actions.map((action) => MapEntry(
            action,
            _touchesPerAction[player][action] > 0 ? (training.actionsSums[player][action].entries.where((element) => element.key > 0).map((e) => e.value).reduce((a, b) => a + b) / _touchesPerAction[player][action])*100 : 0.0
          ))
        )
      ))
    );

  }

  void _computeEfficiency() {

    _efficiency = Map.fromEntries(
      training.players.map<MapEntry<Player, double>>(
        (p) => MapEntry(
            p,
            _touches[p] > 0 ?
            (
                (
                    training.actionsSums[p].values.map<int>((e) => (e.entries.where((element) => element.key == 3).map((e) => e.value).reduce((a, b) => a + b))).reduce((a, b) => a + b) -
                    training.actionsSums[p].values.map<int>((e) => (e.entries.where((element) => element.key == -3).map((e) => e.value).reduce((a, b) => a + b))).reduce((a, b) => a + b)
                ) /
                training.actionsSums[p].values.map<int>((e) => e.values.reduce((a, b) => a + b)).reduce((a, b) => a + b)
            )*100
            : 0.0
        )
      )
    );

    _efficiencyPerAction = Map.fromEntries(training.players.map<MapEntry<Player, Map<TSA.Action, double>>>((player) => MapEntry(
        player,
        Map.fromEntries(
            training.actions.map((action) => MapEntry(
                action,
                _touchesPerAction[player][action] > 0 ?
                (
                    (
                        training.actionsSums[player][action].entries.where((element) => element.key == 3).map((e) => e.value).reduce((a, b) => a + b) -
                        training.actionsSums[player][action].entries.where((element) => element.key == -3).map((e) => e.value).reduce((a, b) => a + b)
                    ) / training.actionsSums[player][action].values.reduce((a, b) => a + b))*100
                : 0.0
            ))
        )
    )));

  }

  void _computePerfection() {

    _perfection = Map.fromEntries(
        training.players.map<MapEntry<Player, double>>(
          (p) => MapEntry(
            p,
            _touches[p] > 0 ?
            (
              (
                  training.actionsSums[p].values.map<int>((e) => (e.entries.where((element) => element.key == 3).map((e) => e.value).reduce((a, b) => a + b))).reduce((a, b) => a + b) -
                  training.actionsSums[p].values.map<int>((e) => (e.entries.where((element) => element.key < 0).map((e) => e.value).reduce((a, b) => a + b))).reduce((a, b) => a + b)
              ) /
              training.actionsSums[p].values.map<int>((e) => e.values.reduce((a, b) => a + b)).reduce((a, b) => a + b)
            )*100
            : 0.0
          )
        )
    );

    _perfectionPerAction = Map.fromEntries(training.players.map<MapEntry<Player, Map<TSA.Action, double>>>((player) => MapEntry(
        player,
        Map.fromEntries(
            training.actions.map((action) => MapEntry(
                action,
                _touchesPerAction[player][action] > 0 ?
                (
                    (
                        training.actionsSums[player][action].entries.where((element) => element.key == 3).map((e) => e.value).reduce((a, b) => a + b) -
                            training.actionsSums[player][action].entries.where((element) => element.key < 0).map((e) => e.value).reduce((a, b) => a + b)
                    ) / training.actionsSums[player][action].values.reduce((a, b) => a + b))*100
                : 0.0
            ))
        )
    )));

  }

  void _computeTouches() {

    _touches = Map.fromEntries(
        training.players.map<MapEntry<Player, int>>(
          (p) => MapEntry(
            p,
            training.actionsSums[p].values.map<int>((e) => e.values.reduce((a, b) => a + b)).reduce((a, b) => a + b)
          )
        )
    );

    _touchesPerAction = Map.fromEntries(training.players.map<MapEntry<Player, Map<TSA.Action, int>>>((player) => MapEntry(
        player,
        Map.fromEntries(
            training.actions.map((action) => MapEntry(
                action,
                training.actionsSums[player][action].values.reduce((a, b) => a + b)
            ))
        )
    )));

  }
  
  void _computeEfficiencyChartData() {

    _efficiencyChartData = {
      Material.Colors.green: Map.fromEntries(
        training.actions.where((action) => action.winning).map((action) => MapEntry(
            action.shortName,
            Map.fromEntries(
                players.map((player) => MapEntry(
                    player,
                    training.actionsSums[player][action][3]
                ))
            )
        )).toList() + [
          MapEntry(
              'Points',
              Map.fromEntries(
                  players.map((player) => MapEntry(
                      player,
                      training.actionsSums[player].entries.where((entry) => entry.key.winning).map((entry) => entry.value[3]).reduce((e1, e2) => e1+e2) ///sum of all perfect winning actions
                  )
                  ))
          )
        ]
      ),
      Material.Colors.blue: {
        'Efficiency' : Map.fromEntries(
            players.map((player) => MapEntry(
                player,
                training.actionsSums[player].entries.where((entry) => entry.key.winning).map((entry) => entry.value[3]).reduce((e1, e2) => e1+e2) - training.actionsSums[player].entries.where((entry) => entry.key.losing).map((entry) => entry.value[-3]).reduce((e1, e2) => e1+e2) ///sum of all perfect winning actions minus sum of all terrible losing actions
            )
            ))
      },
      Material.Colors.red: Map.fromEntries([
        MapEntry(
            'Errors',
            Map.fromEntries(
                players.map((player) => MapEntry(
                    player,
                    training.actionsSums[player].entries.where((entry) => entry.key.losing).map((entry) => entry.value[-3]).reduce((e1, e2) => e1+e2) ///sum of all perfect winning actions
                )
                ))
        ),
      ] + training.actions.where((action) => action.losing).map((action) => MapEntry(
        'e' + action.shortName,
        Map.fromEntries(
            players.map((player) => MapEntry(
                player,
                training.actionsSums[player][action][-3]
            ))
        )
      )).toList())
    };
  }

  void _calculateTouchesAverage(int index) {
    _touchesAverage[index] = Map.fromEntries(training.players.map<MapEntry<Player, List<int>>>((player) => MapEntry(
      player,
      List.generate((_maxTime - _minTime) ~/ touchesAverageIntervals[index] + 1, (i) =>
        training.records.where((record) => record.player == player && (record.timestamp.millisecondsSinceEpoch ~/ 1000.0) >= _minTime + (i * touchesAverageIntervals[index]) && _minTime + ((i+1) * touchesAverageIntervals[index]) > (record.timestamp.millisecondsSinceEpoch  ~/ 1000.0) && training.actions.contains(record.action)).length)
    )).toList());
  }

  Future<Uint8List> generateReport(List<ExportedChart> charts) async {



    final baseColor = PdfColors.deepOrange;

    // Create a PDF document.
    final document = Document();

    final PdfImage icon = PdfImage.file(
      document.document,
      bytes: (await rootBundle.load('assets/img/icon.png')).buffer.asUint8List(),
    );

    final efficiencyTables = chunk(players, 18).map((dataChunk) => Table(
        border: null,
        children: [
          TableRow(
              decoration: BoxDecoration(
                color: baseColor,
              ),
              children: <Widget>[
                SizedBox(
                    height: 30.0,
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Text(
                              "",
                              style: TextStyle(
                                  color: PdfColors.white,
                                  fontWeight: FontWeight.bold
                              ),
                            )
                        )
                    )
                ),
                SizedBox(
                  height: 30.0,
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Text(
                            "Player",
                            style: TextStyle(
                                color: PdfColors.white,
                                fontWeight: FontWeight.bold
                            ),
                          )
                      )
                  )
                )
              ] + efficiencyChartData.entries.map((entry) => entry.value.keys.map((columnName) => SizedBox(
                  height: 30.0,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Text(
                        columnName,
                        style: TextStyle(
                            color: PdfColors.white,
                            fontWeight: FontWeight.bold,
                        ),
                      )
                    )
                  )
              ))).expand((e) => e).toList()
          )
        ] + dataChunk.map((player) => [
          TableRow(
              decoration: BoxDecoration(
                  border: BoxBorder(bottom: true, top: true, color: baseColor, width: 1.0)
              ),
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                        player.shortName
                    )
                ),
                Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                        player.name,
                        maxLines: 1,
                        tightBounds: true,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        )
                    )
                )
              ] + efficiencyChartData.entries.map((entry) => entry.value.values.map((value) => Container(
                alignment: Alignment.center,
                color: _convertColor(entry.key),
                child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      value[player].toString(),
                    )
                ),
              ))).expand((e) => e).toList()
          )
        ]).expand((e) => e).toList())).toList();

    Map<int, String> evaluations = await EvaluationProvider.getAll();

    final tables = chunk(players, 4).map((dataChunk) => Table(
      border: null,
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: baseColor,
          ),
          children: [
            SizedBox(
                height: 30.0,
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          '',
                          style: TextStyle(
                              color: PdfColors.white,
                              fontWeight: FontWeight.bold
                          ),
                        )
                    )
                )
            ),
            SizedBox(
                height: 30.0,
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          'Player',
                          style: TextStyle(
                              color: PdfColors.white,
                              fontWeight: FontWeight.bold
                          ),
                        )
                    )
                )
            )
          ] + evaluations.entries.map((entry) => SizedBox(
            height: 30.0,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  entry.value ?? entry.key.toString(),
                  style: TextStyle(
                      color: PdfColors.white,
                      fontWeight: FontWeight.bold
                  ),
                )
              )
            )
          )).toList() + [
            SizedBox(
                height: 30.0,
                child: Align(
                    alignment: Alignment.center,
                    child: Container(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          'Total',
                          style: TextStyle(
                              color: PdfColors.white,
                              fontWeight: FontWeight.bold
                          ),
                        )
                    )
                )
            )
          ]
        )
      ] + dataChunk.map((player) => [
        TableRow(
          decoration: BoxDecoration(
              border: BoxBorder(bottom: true, top: true, color: baseColor, width: 1.0)
          ),
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  player.shortName
                )
            ),
            Padding(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  player.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  )
                )
            ),
          ] + evaluations.entries.map((entry) => Container(
            alignment: Alignment.center,
            color: _convertColor(Evaluation.getColor(entry.key)),
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Text(
                training.actionsSums[player].values.map((e) => e[entry.key]).reduce((e1, e2) => e1+e2).toString(),
                style: TextStyle(
                  color: useWhiteForeground(Evaluation.getColor(entry.key)) ? PdfColors.white : PdfColors.black,
                )
              )
            ),
          )).toList() + [
            Container(
              alignment: Alignment.center,
              child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                      training.actionsSums[player].values.map((e) => e.values.reduce((e1, e2) => e1+e2)).reduce((e1, e2) => e1+e2).toString(),
                  )
              ),
            )
          ]
        )
    ] + training.actions.map((action) => TableRow(
          decoration: BoxDecoration(
              border: BoxBorder(bottom: true, color: baseColor, width: .5)
          ),
          children: [
            Container(),
            Container(
              alignment: Alignment.centerRight,
              child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                      action.name,
                  )
              ),
            ),
          ] + evaluations.entries.map((entry) => Container(
            alignment: Alignment.center,
            color: _convertColor(Evaluation.getColor(entry.key)),
            padding: EdgeInsets.all(5.0),
            child: Text(
                training.actionsSums[player][action][entry.key].toString(),
                style: TextStyle(
                  color: useWhiteForeground(Evaluation.getColor(entry.key)) ? PdfColors.white : PdfColors.black,
                )
            )
          )).toList() + [
            Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(5.0),
                child: Text(
                    training.actionsSums[player][action].values.reduce((e1, e2) => e1+e2).toString(),
                )
            )
          ]
    )).toList()).expand((e) => e).toList())).toList();
    // Add page to the PDF

    for(var table in efficiencyTables) {
      document.addPage(
        Page(
          pageTheme: _myPageTheme(icon),
          build: (context) {
            return Column(
              children: [
                Text('${training.team.teamName}, ${training.ts_start.day}/${training.ts_start.month}/${training.ts_start.year}',
                    style: TextStyle(
                      color: baseColor,
                      fontSize: 30,
                    )),
                Divider(),
                Expanded(
                    child: table
                )
              ],
            );
          },
        ),
      );
    }

    document.addPage(Page(
      pageTheme: _myPageTheme(icon),
      build: (context) {
        return Column(
            children: [
              Text('${training.team.teamName}, ${training.ts_start.day}/${training.ts_start.month}/${training.ts_start.year}',
                  style: TextStyle(
                    color: baseColor,
                    fontSize: 30,
                  )),
              Divider(
                  height: 10.0
              ),
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                          charts.first.title,
                          style: TextStyle(
                            fontSize: 20.0,
                          )
                      )
                  )
              ),
              Expanded(
                  child: Image(
                      PdfImage.file(
                        document.document,
                        bytes: charts.first.image.buffer.asUint8List(),
                      )
                  )
              )
            ]
        );
      },
    ));

    for(var table in tables) {
      document.addPage(
        Page(
          pageTheme: _myPageTheme(icon),
          build: (context) {
            return Column(
              children: [
                Text('${training.team.teamName}, ${training.ts_start.day}/${training.ts_start.month}/${training.ts_start.year}',
                    style: TextStyle(
                      color: baseColor,
                      fontSize: 30,
                    )),
                Divider(),
                Expanded(
                    child: table
                )
              ],
            );
          },
        ),
      );
    }

    for(var chart in charts.sublist(1)) {
      document.addPage(Page(
        pageTheme: _myPageTheme(icon),
        build: (context) {
          return Column(
              children: [
                Text('${training.team.teamName}, ${training.ts_start.day}/${training.ts_start.month}/${training.ts_start.year}',
                    style: TextStyle(
                      color: baseColor,
                      fontSize: 30,
                    )),
                Divider(
                  height: 10.0
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                          chart.title,
                          style: TextStyle(
                            fontSize: 20.0,
                          )
                      )
                  )
                ),
                Expanded(
                  child: Image(
                    PdfImage.file(
                      document.document,
                      bytes: chart.image.buffer.asUint8List(),
                    )
                  )
                )
              ]
          );
        },
      ));
    }

    // Return the PDF file content
    return document.save();
    
  }

  PdfColor _convertColor(Material.Color color) {
    return PdfColor(color.red.toDouble() / 255.0, color.green.toDouble() / 255.0, color.blue.toDouble() / 255.0);
  }

  PageTheme _myPageTheme(PdfImage icon) {
    return PageTheme(
      pageFormat: PdfPageFormat.a4,
      buildBackground: (Context context) {
        return FullPage(
          ignoreMargins: true,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                        children: [
                          Image(
                            icon,
                            height: 60.0,
                          ),
                          Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Text("Training Stats", style: TextStyle(fontSize: 20.0))
                          )
                        ]
                    )
                )
              ),
              Positioned(
                  bottom: 0,
                  right: 0,
                  child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        "Please do not print this if not strictly necessary",
                        style: TextStyle(
                          color: PdfColors.grey,
                        )
                      )
                  )
              )
            ]
          )
        );
      },
    );
  }

}