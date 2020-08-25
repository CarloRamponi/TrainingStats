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
 
 
import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:training_stats/datatypes/board_type.dart';
import 'package:training_stats/datatypes/player.dart';
import 'package:training_stats/datatypes/record.dart';
import 'package:training_stats/datatypes/training.dart';
import 'package:training_stats/widgets/evaluation_board.dart';
import 'package:training_stats/widgets/evaluation_history_board.dart';
import 'package:training_stats/widgets/grid_segmented_control.dart';
import 'package:training_stats/datatypes/action.dart' as TSA;

class SimpleScoutScene extends StatefulWidget {
  SimpleScoutScene({Key key, this.training}) : super(key: key);

  final Training training;

  @override
  _SimpleScoutSceneState createState() => _SimpleScoutSceneState();
}

class _SimpleScoutSceneState extends State<SimpleScoutScene> {

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<EvaluationHistoryBoardState> evalHistoryKey = GlobalKey<EvaluationHistoryBoardState>();

  List<Record> records = [];
  Record currentRecord = Record();

  Duration timer;
  Timer _timerObj;

  @override
  void initState() {
    timer = Duration.zero;

    _timerObj = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        timer += Duration(seconds: 1);
      });
    });

    super.initState();
  }

  @override
  void dispose() {

    _timerObj.cancel();

    super.dispose();
  }

  void _stop() async {

    Training training = widget.training;
    training.ts_end = DateTime.now();
    training.records = records;

    training = await TrainingProvider.create(training);

    Navigator.pushReplacementNamed(context, '/simple_scout/report', arguments: training);

  }

  void onPlayerChanged(Player player) {
    setState(() {
      if(player == currentRecord.player)
        currentRecord.player = null;
      else
        currentRecord.player = player;
    });
  }

  void onActionChanged(TSA.Action action) {
    setState(() {
      if(action == currentRecord.action)
        currentRecord.action = null;
      else
        currentRecord.action = action;
    });
  }

  bool onEvaluationChanged(int eval) {

    if(currentRecord.player != null && currentRecord.action != null) {

      setState(() {

        records.add(Record(
            player: currentRecord.player,
            action: currentRecord.action,
            evaluation: eval
        ));

        evalHistoryKey.currentState.addRecord(records.last);

      });

      return true;
    } else {
      scaffoldKey.currentState.removeCurrentSnackBar();
      scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("You should select the player and the action first."), duration: Duration(milliseconds: 700),));
      return false;
    }
  }

  bool undoBtnEnabled() {
    return records.length > 0;
  }

  void undo() {
    setState(() {
      records.removeLast();
      evalHistoryKey.currentState.removeLastRecord();
    });
  }

  Future<bool> _confirmExit() async {
    var result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Confirm exit"),
          content: Text("Are you sure you want to exit?\nThis training will be discarded and you won't be able to recover it."),
          actions: [
            FlatButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            FlatButton(
              child: Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            )
          ],
        ));

    return result == true;
  }

  Future<bool> _confirmStop() async {
    var result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Confirm stop"),
          content: Text("Are you sure you want to stop this training?"),
          actions: [
            FlatButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            FlatButton(
              child: Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            )
          ],
        ));

    return result == true;
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: _confirmExit,
      child: Scaffold(
          key: scaffoldKey,
          body: Stack(
            children: <Widget>[
              SafeArea(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 60.0,
                      child: Stack(
                        fit: StackFit.expand,
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Simple Scout",
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                                Text(
                                  "${timer.inMinutes.toString().padLeft(2, '0')}:${(timer.inSeconds % 60).toString().padLeft(2, '0')}",
                                  style: Theme.of(context).textTheme.caption,
                                )
                              ],
                            ),
                          ),
                          Positioned(
                            right: 0.0,
                            child: FlatButton(
                              padding: EdgeInsets.zero,
                              child: Text("Stop"),
                              onPressed: () async {
                                if(await _confirmStop()) {
                                  _stop();
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    Divider(
                      height: 0.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                      child: Column(
                        children: [
                          GridSegmentedControl<Player>(
                            title: "Player",
                            rowCount: 6,
                            elements: widget.training.players.map((value) => GridSegmentedControlElement(value: value, name: value.shortName, color: value.role.color, tooltip: value.name)).toList(),
                            onPressed: (player) => onPlayerChanged(player),
                            selected: currentRecord.player,
                          ),
                          GridSegmentedControl<TSA.Action>(
                            title: "Action",
                            rowCount: max(min(6, widget.training.actions.length), 4),
                            elements: widget.training.actions.map((value) => GridSegmentedControlElement(value: value, name: value.shortName, color: value.color, tooltip: value.name)).toList(),
                            onPressed: onActionChanged,
                            selected: currentRecord.action,
                          ),
                          FutureBuilder(
                            future: BoardTypeProvider.get(),
                            builder: (context, AsyncSnapshot<BoardType> boardType) => FutureBuilder(
                              future: BoardTypeProvider.showLabels(),
                              builder: (_, AsyncSnapshot<bool> showLabels) => boardType.hasData ? EvaluationBoard(
                                boardType: boardType.data,
                                showLabels: showLabels.hasData ? showLabels.data : false,
                                onPressed: onEvaluationChanged,
                              ) : LinearProgressIndicator(),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: EvaluationHistoryBoard(
                  key: evalHistoryKey,
                ),
              ),
              Positioned(
                bottom: 5.0,
                right: 8.0,
                child: IconButton(
                  icon: Icon(
                    Icons.backspace,
                    color: Colors.grey,
                    size: 25.0,
                  ),
                  onPressed: undoBtnEnabled() ? () { undo(); } : null,
                ),
              )
            ],
          )
      ),
    );
  }
}
