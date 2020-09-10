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
import 'package:training_stats/utils/functions.dart';
import 'package:training_stats/widgets/drawer.dart';

class PlayersScene extends StatefulWidget {
  PlayersScene({Key key}) : super(key: key);

  @override
  _PlayersSceneState createState() => _PlayersSceneState();
}

enum PlayerAction { edit, delete }

class _PlayersSceneState extends State<PlayersScene> {

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<Player>> players;

  bool searching = false;
  String searchQuery = "";

  @override
  void initState() {
    players = PlayerProvider.getAll();
    super.initState();
  }

  Future<void> _refresh() {
    setState(() {
      players = PlayerProvider.getAll(query: searchQuery);
    });
    return players;
  }

  void _search() {
    setState(() {
      searching = true;
    });
  }

  void _updateSearch(String value) {
    searchQuery = value;
    _refresh();
  }

  void _stopSearching() {
    searching = false;
    searchQuery = "";
    _refresh();
  }

  void _handleDropDownMenu(Player player, PlayerAction action) async {
    switch (action) {

      case PlayerAction.edit:
        await Navigator.of(context).pushNamed('/editPlayer', arguments: player);
        _refresh();
        break;

      case PlayerAction.delete:
        var result = await showDialog(
            context: context, builder: (_) => _confirmDeleteDialog());

        if (result == true) {
          PlayerProvider.delete(player.id).then((num) {
            if (num == 1) {
              scaffoldKey.currentState.removeCurrentSnackBar();
              scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text("Player deleted correctly."),
                duration: Duration(milliseconds: 700),
              ));
            } else {
              scaffoldKey.currentState.removeCurrentSnackBar();
              scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text("Error while deleting player."),
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

  void _createPlayer() async {
    await Navigator.of(context).pushNamed('/createPlayer');
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      //if the searchbar is visible the back button will hide that instead of popping the scene
      onWillPop: () async {
        if(searching) {
          _stopSearching();
          return false;
        }
        return true;
      },
      child: Scaffold(
          key: scaffoldKey,
          drawer: MyDrawer(activeSection: DrawerSection.PLAYERS,),
          appBar: AppBar(
            leading: searching ? IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                _stopSearching();
              },
            ) : null,
            title: searching ? TextField(
              autofocus: true,
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  .copyWith(fontSize: 20.0, color: Colors.white),
              onChanged: _updateSearch,
            ) : Text("Your players"),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    _search();
                  });
                },
              )
            ],
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              _createPlayer();
            },
          ),
          body: SafeArea(
              child: FutureBuilder(
                builder: (context, AsyncSnapshot<List<Player>> playersSnap) {
                  if (playersSnap.hasData) {
                    if (playersSnap.data.length > 0) {
                      return RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView.separated(
                            itemBuilder: (context, index) {
                              GlobalKey<PopupMenuButtonState> menuKey =
                              GlobalKey<PopupMenuButtonState>();
                              Player current = playersSnap.data[index];
                              return ListTile(
                                leading: current.photo != null
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
                                trailing: PopupMenuButton<PlayerAction>(
                                  key: menuKey,
                                  onSelected: (selectedDropDownItem) =>
                                      _handleDropDownMenu(
                                          current, selectedDropDownItem),
                                  itemBuilder: (_) {
                                    return <PopupMenuEntry<PlayerAction>>[
                                      PopupMenuItem<PlayerAction>(
                                        value: PlayerAction.edit,
                                        child: Row(
                                          children: <Widget>[
                                            Icon(Icons.edit),
                                            Padding(
                                              padding: EdgeInsets.only(left: 10.0),
                                              child: Text("Edit"),
                                            )
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem<PlayerAction>(
                                        value: PlayerAction.delete,
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
                                onTap: () async {
                                  await Navigator.of(context).pushNamed('/editPlayer', arguments: current);
                                  _refresh();
                                },
                                onLongPress: () {
                                  menuKey.currentState.showButtonMenu();
                                },
                              );
                            },
                            separatorBuilder: (_, __) => Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Divider(),
                            ),
                            itemCount: playersSnap.data.length
                        ),
                      );
                    } else {
                      return Center(
                        child: Text(searching ? "Nothing here!" : "Start by creating a player!"),
                      );
                    }
                  } else {
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
                  }
                },
                future: players,
              ))));
  }
}
