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

  void _addPlayer() {
    scaffoldKey.currentState.removeCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Not yet implemented."),
      duration: Duration(milliseconds: 700),
    ));
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
                      Player current = playerSnap.data[index];
                      return ListTile(
                        leading: current.photo != null ? CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: FileImage(File(current.photo)),
                        ) : CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Icon(Icons.account_circle, color: Colors.grey, size: 50.0,),
                        ),
                        title: Text(current.name),
                        subtitle: Text(current.shortName),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {},
                        ),
                        onTap: () {
                          scaffoldKey.currentState.removeCurrentSnackBar();
                          scaffoldKey.currentState.showSnackBar(SnackBar(
                            content: Text("Not yet implemented."),
                            duration: Duration(milliseconds: 700),
                          ));
                        },
                        onLongPress: null,
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
                    return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Icon(Icons.account_circle, color: Colors.grey, size: 50.0,),
                        ),
                        title: Container(
                          height: 10.0,
                          width: double.infinity,
                          margin: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width / 3.0),
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.6)),
                          child: null,
                        ),
                        subtitle: Container(
                          height: 10.0,
                          margin: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width / 2.0),
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.4)),
                          child: null,
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {},
                        ));
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
