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

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:training_stats/datatypes/player.dart';
import 'package:training_stats/datatypes/team.dart';
import 'package:training_stats/datatypes/training.dart';
import 'package:training_stats/routes/players_scenes/players_selection_scene.dart';
import 'package:training_stats/routes/teams_scenes/team_selection.dart';
import 'package:training_stats/widgets/drawer.dart';
import 'package:training_stats/datatypes/action.dart' as TrainingStatsAction;
import 'package:intl/intl.dart';

import 'actions_selection_scene.dart';

class SimpleScoutTrainingsScene extends StatefulWidget {
  SimpleScoutTrainingsScene({Key key}) : super(key: key);

  @override
  _SimpleScoutTrainingsSceneState createState() => _SimpleScoutTrainingsSceneState();
}

enum TrainingAction { clone, delete }

class _SimpleScoutTrainingsSceneState extends State<SimpleScoutTrainingsScene> {

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<Training>> trainings;

  @override
  void initState() {
    trainings = TrainingProvider.getAll();
    super.initState();
  }

  Future<void> _refresh() {
    setState(() {
      trainings = TrainingProvider.getAll();
    });
    return trainings;
  }

  Future<bool> _confirmDelete() {
    return showDialog(context: context, builder: (_) => _confirmDeleteDialog());
  }

  void _handleDropDownMenu(Training training, TrainingAction action) async {
    switch (action) {

      case TrainingAction.clone:

        Training tt = Training(
          team: training.team,
          players: training.players,
          actions: training.actions
        );

        await Navigator.of(context).pushNamed('/simple_scout/scout', arguments: tt);
        _refresh();
        break;

      case TrainingAction.delete:

        if (await _confirmDelete()) {
          TrainingProvider.delete(training.id).then((num) {
            _refresh();
            if (num == 1) {
              scaffoldKey.currentState.removeCurrentSnackBar();
              scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text("Training deleted correctly."),
                duration: Duration(milliseconds: 700),
              ));
            } else {
              scaffoldKey.currentState.removeCurrentSnackBar();
              scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text("Error while deleting training."),
                duration: Duration(milliseconds: 700),
              ));
            }
          });

          _refresh();
        }

        break;
    }
  }

  AlertDialog _confirmDeleteDialog() {
    return AlertDialog(
      title: Text("Are you sure?"),
      content: Text("This action can't be undone!"),
      actions: <Widget>[
        FlatButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        FlatButton(
          child: Text("Delete"),
          onPressed: () {
            Navigator.pop(context, true);
          },
        )
      ],
    );
  }

  void _newTraining() async {

    Team team = await Navigator.push(context, MaterialPageRoute<Team>(
        builder: (context) => SelectTeam()
    ));

    if(team != null) {
      List<Player> players = await Navigator.push(
          context, MaterialPageRoute<List<Player>>(
          builder: (context) => PlayersSelectionScene(team: team)
      ));

      if(players != null) {
        List<TrainingStatsAction.Action> actions = await Navigator.of(
            context).push(
            MaterialPageRoute<List<TrainingStatsAction.Action>>(
                builder: (context) => ActionsSelectionScene()
            ));

        if(actions != null) {
          Training training = Training(
              team: team,
              players: players,
              actions: actions
          );

          await Navigator.of(context).pushNamed(
              "/simple_scout/scout", arguments: training);
        }
      }
    }
    _refresh();
  }

  void _showReport(Training t) async {
    await Navigator.pushNamed(context, '/simple_scout/report', arguments: t);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            key: scaffoldKey,
            drawer: MyDrawer(),
            appBar: AppBar(
              title: Text("Trainings"),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: _newTraining,
            ),
            body: SafeArea(
                child: FutureBuilder(
                  builder: (context, AsyncSnapshot<List<Training>> snap) {
                    if (snap.hasData) {
                      if (snap.data.length > 0) {
                        return RefreshIndicator(
                          onRefresh: _refresh,
                          child: ListView.separated(
                              itemBuilder: (context, index) {
                                GlobalKey<PopupMenuButtonState> menuKey =
                                GlobalKey<PopupMenuButtonState>();
                                Training current = snap.data[index];
                                return ListTile(
                                  title: Text(
                                    DateFormat("d/M/y").format(current.ts_start) + " - " + current.team.teamName,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        current.actions.map((e) => e.name).join(", "),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        current.players.map((e) => e.shortName).join(", "),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Builder(
                                        builder: (context) {
                                          Duration difference = current.ts_end.difference(current.ts_start);
                                          String text = "From ${DateFormat("H:m:s").format(current.ts_start)} to ${DateFormat("H:m:s").format(current.ts_end)} (${difference.inHours}h ${difference.inMinutes}m ${difference.inSeconds}s)";
                                          return Text(
                                            text,
                                            overflow: TextOverflow.ellipsis,
                                          );
                                        },
                                      )
                                    ],
                                  ),
                                  isThreeLine: true,
                                  trailing: PopupMenuButton<TrainingAction>(
                                    key: menuKey,
                                    onSelected: (selectedDropDownItem) =>
                                        _handleDropDownMenu(
                                            current, selectedDropDownItem),
                                    itemBuilder: (_) {
                                      return <PopupMenuEntry<TrainingAction>>[
                                        PopupMenuItem<TrainingAction>(
                                          value: TrainingAction.clone,
                                          child: Row(
                                            children: <Widget>[
                                              Icon(Icons.content_copy),
                                              Padding(
                                                padding: EdgeInsets.only(left: 10.0),
                                                child: Text("Clone"),
                                              )
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem<TrainingAction>(
                                          value: TrainingAction.delete,
                                          child: Row(
                                            children: <Widget>[
                                              Icon(Icons.delete),
                                              Padding(
                                                padding: EdgeInsets.only(left: 10.0),
                                                child: Text("Delete"),
                                              )
                                            ],
                                          ),
                                        )
                                      ];
                                    },
                                  ),
                                  onTap: () => _showReport(current),
                                  onLongPress: () {
                                    menuKey.currentState.showButtonMenu();
                                  },
                                );
                              },
                              separatorBuilder: (_, __) => Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                child: Divider(),
                              ),
                              itemCount: snap.data.length
                          ),
                        );
                      } else {
                        return Center(
                          child: Text("Start by creating a new training!"),
                        );
                      }
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                  future: trainings,
                )));
  }
}
