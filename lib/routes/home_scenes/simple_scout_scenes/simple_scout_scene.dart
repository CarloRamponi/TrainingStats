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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:training_stats/datatypes/board_type.dart';
import 'package:training_stats/datatypes/evaluation.dart';
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

  bool onPlayerChanged(Player player) {
    setState(() {
      currentRecord.player = player;
    });
    return true;
  }

  bool onActionChanged(TSA.Action action) {
    if(currentRecord.player != null) {
      setState(() {
        currentRecord.action = action;
      });
      return true;
    } else {
      scaffoldKey.currentState.removeCurrentSnackBar();
      scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("You should select the player first."), duration: Duration(seconds: 1)));
      return false;
    }
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Simple scout"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.stop),
            tooltip: "Stop the current training session",
            onPressed: () {
              scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Not yet implemented"), duration: Duration(milliseconds: 700)));
            },
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          SafeArea(
            minimum: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
            child: Column(
              children: <Widget>[
                GridSegmentedControl<Player>(
                  title: "Player",
                  rowCount: 6,
                  elements: widget.training.players.map((value) => GridSegmentedControlElement(value: value, name: value.shortName, color: value.role.color, tooltip: value.name)).toList(),
                  onPressed: (player) => onPlayerChanged(player),
                ),
                GridSegmentedControl<TSA.Action>(
                  title: "Action",
                  rowCount: max(min(6, widget.training.actions.length), 4),
                  elements: widget.training.actions.map((value) => GridSegmentedControlElement(value: value, name: value.shortName, color: value.color, tooltip: value.name)).toList(),
                  onPressed: onActionChanged,
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
    );
  }
}
