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
 
 
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:training_stats/datatypes/team.dart';
import 'package:training_stats/utils/db.dart';
import 'package:training_stats/widgets/drawer.dart';

class TeamsScene extends StatefulWidget {
  TeamsScene({Key key}) : super(key: key);

  @override
  _TeamsSceneState createState() => _TeamsSceneState();
}

enum TeamAction { edit, delete }

class _TeamsSceneState extends State<TeamsScene> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<Team>> teams;

  @override
  void initState() {
    teams = TeamProvider.getAll();
    super.initState();
  }

  Future<void> _refresh() {
    setState(() {
      teams = TeamProvider.getAll();
    });
    return teams;
  }

  void _handleDropDownMenu(Team team, TeamAction action) async {
    switch (action) {

      case TeamAction.edit:
        await Navigator.of(context).pushNamed('/editTeam', arguments: team);
        _refresh();
        break;

      case TeamAction.delete:
        var result = await showDialog(
            context: context, builder: (_) => _confirmDeleteDialog());

        if (result == true) {
          TeamProvider.delete(team.id).then((num) {
            if (num == 1) {
              scaffoldKey.currentState.removeCurrentSnackBar();
              scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text("Team deleted correctly."),
                duration: Duration(milliseconds: 700),
              ));
            } else {
              scaffoldKey.currentState.removeCurrentSnackBar();
              scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text("Error while deleting team."),
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

  AlertDialog _createTeamDialog() {

    TextEditingController _textFieldController = TextEditingController();
    GlobalKey<FormState> formKey = GlobalKey();

    return AlertDialog(
      title: Text("Create Team"),
      content: Form(
        key: formKey,
        child: TextFormField(
          autofocus: true,
          maxLength: 128,
          controller: _textFieldController,
          validator: (value) => value == "" ? "Please insert some text" : null,
          decoration: InputDecoration(labelText: 'Team name'),
          onEditingComplete: () {
            if(formKey.currentState.validate())
              Navigator.pop(context, _textFieldController.text);
          },
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.pop(context, null);
          },
        ),
        FlatButton(
          child: Text("Create"),
          onPressed: () {
            if(formKey.currentState.validate())
              Navigator.pop(context, _textFieldController.text);
          },
        )
      ],
    );
  }

  void _createTeam() async {
    var result =
        await showDialog(context: context, builder: (_) => _createTeamDialog());

    if (result != null) {
      Team t = await TeamProvider.create(teamName: result);
      _refresh();
      await Navigator.of(context).pushNamed('/editTeam', arguments: t);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        drawer: MyDrawer(),
        appBar: AppBar(
          title: Text("Your teams"),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            _createTeam();
          },
        ),
        body: SafeArea(
            child: FutureBuilder(
          builder: (context, teamSnap) {
            if (teamSnap.hasData) {
              if (teamSnap.data.length > 0) {
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                      itemBuilder: (context, index) {
                        GlobalKey<PopupMenuButtonState> menuKey =
                        GlobalKey<PopupMenuButtonState>();
                        Team current = teamSnap.data[index];
                        return ListTile(
                          title: Text(current.teamName),
                          subtitle: FutureBuilder(
                            builder: (context, playersSnap) {
                              if (playersSnap.hasData) {
                                if (playersSnap.data.length > 0) {
                                  return Text(playersSnap.data.map((p) => p.name).toList().join(", "),
                                      overflow: TextOverflow.ellipsis);
                                } else {
                                  return Text('No players added yet',
                                      overflow: TextOverflow.ellipsis);
                                }
                              } else {
                                return Container(
                                  height: 10.0,
                                  width: double.infinity,
                                  margin: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width / 4.0),
                                  decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.4)),
                                  child: null,
                                );
                              }
                            },
                            future: TeamProvider.getPlayers(current.id),
                          ),
                          trailing: PopupMenuButton<TeamAction>(
                            key: menuKey,
                            onSelected: (selectedDropDownItem) =>
                                _handleDropDownMenu(
                                    current, selectedDropDownItem),
                            itemBuilder: (_) {
                              return <PopupMenuEntry<TeamAction>>[
                                PopupMenuItem<TeamAction>(
                                  value: TeamAction.edit,
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
                                PopupMenuItem<TeamAction>(
                                  value: TeamAction.delete,
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
                            _handleDropDownMenu(current, TeamAction.edit);
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
                      itemCount: teamSnap.data.length
                  ),
                );
              } else {
                return Center(
                  child: Text("Start by creating a team!"),
                );
              }
            } else {
              return ListView.separated(
                  itemBuilder: (context, index) {
                    return ListTile(
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
          future: teams,
        )));
  }
}
