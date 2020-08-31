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

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:training_stats/datatypes/action.dart';
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

  Map<Player, Map<Action, double>> _positivityPerAction;
  Map<Player, Map<Action, double>> _efficiencyPerAction;
  Map<Player, Map<Action, double>> _perfectionPerAction;
  Map<Player, Map<Action, int>> _touchesPerAction;

  int _maxTime;
  int _minTime;

  List<Map<Player, List<int>>> _touchesAverage;

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

  Map<Player, Map<Action, double>> get positivityPerAction {
    if(_positivityPerAction == null) {
      _computePositivity();
    }
    return _positivityPerAction;
  }

  Map<Player, Map<Action, double>> get efficiencyPerAction {
    if(_efficiencyPerAction == null) {
      _computeEfficiency();
    }
    return _efficiencyPerAction;
  }

  Map<Player, Map<Action, double>> get perfectionPerAction {
    if(_perfectionPerAction == null) {
      _computePerfection();
    }
    return _perfectionPerAction;
  }

  Map<Player, Map<Action, int>> get touchesPerAction {
    if(_touchesPerAction == null) {
      _computeTouches();
    }
    return _touchesPerAction;
  }

  void _computePositivity() {

    _positivity = Map.fromEntries(
        training.players.map<MapEntry<Player, double>>(
            (p) => MapEntry(p, _touches[p] > 0 ? (training.actionsSums[p].values.map<int>((e) => (e.entries.where((element) => element.key > 0).map((e) => e.value).reduce((a, b) => a + b))).reduce((a, b) => a + b) / _touches[p])*100 : 0.0)
        )
    );

    _positivityPerAction = Map.fromEntries(
      training.players.map<MapEntry<Player, Map<Action, double>>>((player) => MapEntry(
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

    _efficiencyPerAction = Map.fromEntries(training.players.map<MapEntry<Player, Map<Action, double>>>((player) => MapEntry(
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

    _perfectionPerAction = Map.fromEntries(training.players.map<MapEntry<Player, Map<Action, double>>>((player) => MapEntry(
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

    _touchesPerAction = Map.fromEntries(training.players.map<MapEntry<Player, Map<Action, int>>>((player) => MapEntry(
        player,
        Map.fromEntries(
            training.actions.map((action) => MapEntry(
                action,
                training.actionsSums[player][action].values.reduce((a, b) => a + b)
            ))
        )
    )));

  }

  void _calculateTouchesAverage(int index) {
    _touchesAverage[index] = Map.fromEntries(training.players.map<MapEntry<Player, List<int>>>((player) => MapEntry(
      player,
      List.generate((_maxTime - _minTime) ~/ touchesAverageIntervals[index] + 1, (i) =>
        training.records.where((record) => record.player == player && (record.timestamp.millisecondsSinceEpoch ~/ 1000.0) >= _minTime + (i * touchesAverageIntervals[index]) && _minTime + ((i+1) * touchesAverageIntervals[index]) > (record.timestamp.millisecondsSinceEpoch  ~/ 1000.0) && training.actions.contains(record.action)).length)
    )).toList());
  }

  Future<Uint8List> generateReport(List<ExportedChart> charts) async {

    const tableHeaders = ['', 'Player', 'Positivity', 'Efficiency', 'Perfection', 'Total actions'];

    List<List<dynamic>> dataTable = (training.players).map<List<dynamic>>((player) => [
      player.shortName,
      player.name,
      this.positivity[player],
      this.efficiency[player],
      this.perfection[player],
      this.touches[player],
    ]).toList();

    final baseColor = PdfColors.deepOrange;

    // Create a PDF document.
    final document = Document();

    final PdfImage icon = PdfImage.file(
      document.document,
      bytes: (await rootBundle.load('assets/img/icon.png')).buffer.asUint8List(),
    );

    final tables = chunk(training.players, 4).map((dataChunk) => Table(
      border: null,
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: baseColor,
          ),
          children: tableHeaders.map((header) => SizedBox(
            height: 30.0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    header,
                    style: TextStyle(
                        color: PdfColors.white,
                        fontWeight: FontWeight.bold
                    ),
                  )
              )
            )
          )).toList()
        )
      ] + dataChunk.map((player) => [
        TableRow(
          decoration: BoxDecoration(
              border: BoxBorder(bottom: true, top: true, color: baseColor, width: 1.0)
          ),
          children: [
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
            Container(
              alignment: Alignment.centerRight,
              child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                      positivity[player].toStringAsFixed(2) + " %",
                  )
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                      efficiency[player].toStringAsFixed(2) + " %",
                  )
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                      perfection[player].toStringAsFixed(2) + " %",
                  )
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                      touches[player].toString(),
                  )
              ),
            ),
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
            Container(
              alignment: Alignment.centerRight,
              child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    positivityPerAction[player][action].toStringAsFixed(2) + " %",
                  )
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    efficiencyPerAction[player][action].toStringAsFixed(2) + " %",
                  )
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    perfectionPerAction[player][action].toStringAsFixed(2) + " %",
                  )
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    touchesPerAction[player][action].toString(),
                  )
              ),
            ),
          ]
    )).toList()).expand((e) => e).toList())).toList();
    // Add page to the PDF

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

    for(var chart in charts) {
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