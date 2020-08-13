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
import 'package:training_stats/utils/db.dart';

class EditTeamScene extends StatefulWidget {
  EditTeamScene({Key key, this.team}) : super(key: key);

  final Team team;

  @override
  _EditTeamSceneState createState() => _EditTeamSceneState();
}

class _EditTeamSceneState extends State<EditTeamScene> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<Player>> players;

  @override
  void initState() {
    players = TeamProvider.getPlayers(widget.team.id);

    super.initState();
  }

  void _addPlayer() async {
    var result = await Navigator.of(context).pushNamed("/editTeam/addPlayer", arguments: widget.team);
    if(result == true) {
      players = TeamProvider.getPlayers(widget.team.id)..then((value) {
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text(widget.team.teamName),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            _addPlayer();
          },
        ),
        body: SafeArea(
            child: FutureBuilder(
          builder: (context, playerSnap) {
            if (playerSnap.hasData) {
              if (playerSnap.data.length > 0) {
                return ListView.separated(
                    itemBuilder: (context, index) {
                      return PlayerListTile(
                        player: playerSnap.data[index],
                        onTap: () {
                          scaffoldKey.currentState.removeCurrentSnackBar();
                          scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Not yet implemented."), duration: Duration(milliseconds: 700),));
                        },
                        onDelete: () {
                          TeamProvider.removePlayer(teamId: widget.team.id, playerId: playerSnap.data[index].id).then((value) {
                            players = TeamProvider.getPlayers(widget.team.id)..then((value) {
                              setState(() {});
                            });
                          });
                        },
                      );
                    },
                    separatorBuilder: (_, __) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Divider(),
                        ),
                    itemCount: playerSnap.data.length);
              } else {
                return Center(
                  child: Text("Start by adding a player!"),
                );
              }
            } else {
              return ListView.separated(
                  itemBuilder: (context, index) {
                    return PlayerListTilePlaceholder();
                  },
                  separatorBuilder: (_, __) => Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Divider(),
                      ),
                  itemCount: 3);
            }
          },
          future: players,
        )));
  }
}
