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

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:training_stats/datatypes/player.dart';
import 'package:training_stats/datatypes/team.dart';

class PlayersSelectionScene extends StatefulWidget {

  PlayersSelectionScene({
    @required this.team,
  });

  final Team team;

  _PlayersSelectionSceneState createState() => _PlayersSelectionSceneState();

}

enum Actions {
  CHECK_ALL,
  UNCHECK_ALL
}

class _PlayersSelectionSceneState extends State<PlayersSelectionScene> {

  List<Player> players;
  List<bool> checked;

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();

  void _checkAll() {
    setState(() {
      checked = checked.map((e) => true).toList();
    });
  }

  void _uncheckAll() {
    setState(() {
      checked = checked.map((e) => false).toList();
    });
  }

  void _nextPage() {
    List<Player> selected = [];
    for(int i = 0; i < players.length; i++) {
      if(checked[i]){
        selected.add(players[i]);
      }
    }

    if(selected.length == 0) {
      _scaffoldState.currentState.showSnackBar(
        SnackBar(
          content: Text("You should select some players"),
          duration: Duration(seconds: 3),
        )
      );
    } else {
      Navigator.of(context).pop(selected);
    }
  }

  @override
  void initState() {
    TeamProvider.getPlayers(widget.team.id).then((value) {
      setState(() {
        players = value;
        checked = List.filled(players.length, true);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("Select players"),
        actions: [
          PopupMenuButton<Actions>(
            itemBuilder: (context) {
              return <PopupMenuEntry<Actions>>[
                PopupMenuItem<Actions>(
                  value: Actions.CHECK_ALL,
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child: Icon(
                          Icons.check_box,
                          color: Colors.black,
                        ),
                      ),
                      Text("Check all")
                    ],
                  ),
                ),
                PopupMenuItem<Actions>(
                  value: Actions.UNCHECK_ALL,
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child: Icon(
                          Icons.check_box_outline_blank,
                          color: Colors.black,
                        ),
                      ),
                      Text("Uncheck all")
                    ],
                  ),
                )
              ];
            },
            onSelected: (Actions a) {
              switch(a) {

                case Actions.CHECK_ALL:
                  _checkAll();
                  break;
                case Actions.UNCHECK_ALL:
                  _uncheckAll();
                  break;
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            tooltip: "Next",
            onPressed: _nextPage,
          ),
        ],
      ),
      body: Builder(
        builder: (context) {

          if(players == null) {

            //loading...
            return ListView.separated(
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        Icons.account_circle,
                        color: Colors.grey,
                        size: 50.0,
                      ),
                    ),
                    title: Container(
                      height: 10.0,
                      margin: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width / 2.0),
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.6)),
                      child: null,
                    ),
                    subtitle: Container(
                      height: 10.0,
                      width: double.infinity,
                      margin: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width / 4.0),
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.4)),
                      child: null,
                    ),
                    trailing: PopupMenuButton(itemBuilder: (_) => List(),),
                  );
                },
                separatorBuilder: (_, __) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Divider(),
                ),
                itemCount: 3);

          } else {

            if(players.length == 0) {

              return Center(
                child: Text("You should add some players first"),
              );

            } else {

              return ListView.separated(
                  itemBuilder: (context, index) {
                    Player current = players[index];
                    return CheckboxListTile(
                      value: checked[index],
                      secondary: current.photo != null
                          ? CircleAvatar(
                        backgroundColor: Colors.transparent,
                        backgroundImage: FileImage(File(current.photo)),
                      )
                          : CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Center(
                            child: Icon(
                              Icons.account_circle,
                              color: Colors.grey,
                              size: 40.0,
                            ),
                          )
                      ),
                      title: Text(current.name),
                      subtitle: Text(current.shortName + (current.role == null ? "" : " - " + current.role.name)),
                      onChanged: (value) {
                        setState(() {
                          checked[index] = value;
                        });
                      },
                    );
                  },
                  separatorBuilder: (_, __) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Divider(),
                  ),
                  itemCount: players.length
              );
            }
          }
        },
      ),
    );
  }

}