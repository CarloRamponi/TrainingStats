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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:training_stats/datatypes/board_type.dart';
import 'package:training_stats/datatypes/evaluation.dart';
import 'package:training_stats/datatypes/role.dart';
import 'package:training_stats/routes/settings_pages/evaluations_names_scene.dart';
import 'package:training_stats/widgets/evaluation_board.dart';

class EvaluationsScene extends StatefulWidget {

  @override
  _EvaluationsSceneState createState() => _EvaluationsSceneState();

}

class _EvaluationsSceneState extends State<EvaluationsScene> {

  BoardType boardType;
  bool showLabels;
  GlobalKey<EvaluationBoardState> _boardState = GlobalKey();

  @override
  void initState() {

    BoardTypeProvider.get().then((value) {
      setState(() {
        boardType = value;
      });
    });

    BoardTypeProvider.showLabels().then((value) {
      setState(() {
        showLabels = value;
      });
    });

    super.initState();
  }

  void _refreshLabels() {
    _boardState.currentState.refreshLabels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Evaluation board'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.dashboard),
                    title: Text("Board type"),
                    trailing: DropdownButton<BoardType>(
                      value: boardType ?? BoardType.COMPLETE,
                      icon: Icon(Icons.arrow_downward),
                      iconSize: 24,
                      onChanged: (BoardType newValue) {
                        setState(() {
                          boardType = newValue;
                        });
                        BoardTypeProvider.set(boardType);
                      },
                      items: BoardType.values.map<DropdownMenuItem<BoardType>>((BoardType type) {
                        return DropdownMenuItem<BoardType>(
                            value: type,
                            child: Text(BoardTypeProvider.getName(type))
                        );
                      }).toList(),
                    ),
                  ),
                  SwitchListTile(
                    secondary: Icon(Icons.text_fields),
                    title: Text("Show labels"),
                    onChanged: (value) {
                      setState(() {
                        showLabels = value;
                      });
                      BoardTypeProvider.setShowLabels(showLabels);
                    },
                    value: showLabels ?? true,
                  ),
                  ListTile(
                    leading: Icon(Icons.edit_attributes),
                    title: Text("Edit evaluation labels"),
                    enabled: showLabels ?? true,
                    onTap: () async {
                      await Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => EvaluationsNamesScene()
                      ));
                      _refreshLabels();
                    },
                  )
                ],
              ),
            ),
          ),
          Center(
              child: Text("Preview"),
          ),
          Container(
            padding: EdgeInsets.all(20.0),
            child: Builder(
              builder: (context) => boardType != null && showLabels != null ? EvaluationBoard(
                key: _boardState,
                boardType: boardType,
                showLabels: showLabels,
                onPressed: (_) => true,
              ) : Container(
                height: 50.0,
                child: Center(
                  child: LinearProgressIndicator(),
                ),
              ),
            ),
          )
        ],
      )
    );
  }

}