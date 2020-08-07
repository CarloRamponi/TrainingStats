import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:training_stats/datatypes/team.dart';
import 'package:training_stats/utils/db.dart';

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
    teams = TeamProvider.getAll()..then((value) {
      value.forEach((element) {print(element.teamName); });
    });
    super.initState();
  }

  void _handleDropDownMenu(int teamIndex, TeamAction action) async {
    switch(action) {
      case TeamAction.edit:

        scaffoldKey.currentState.removeCurrentSnackBar();
        scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Not yet implemented"), duration: Duration(milliseconds: 700),));

        break;
      case TeamAction.delete:
        var result = await showDialog(
            context: context,
            builder: (_) => _confirmDeleteDialog()
        );

        if(result == true) {
          scaffoldKey.currentState.removeCurrentSnackBar();
          scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Not yet implemented"), duration: Duration(milliseconds: 700),));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text("Your teams"),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            scaffoldKey.currentState.removeCurrentSnackBar();
            scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text("Not yet implemented"),
              duration: Duration(milliseconds: 700),));
          },
        ),
        body: SafeArea(
          child: ListView.separated(
              itemBuilder: (context, index) {

                GlobalKey<PopupMenuButtonState> menuKey = GlobalKey<PopupMenuButtonState>();

                return ListTile(
                  title: Text("Team $index"),
                  subtitle: Text(
                      'some player1, some player2, some player3, some player4, some player 5',
                      overflow: TextOverflow.ellipsis),
                  trailing: PopupMenuButton<TeamAction>(
                    key: menuKey,
                    onSelected: (selectedDropDownItem) => _handleDropDownMenu(index, selectedDropDownItem),
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
                  onTap: () {

                  },
                  onLongPress: () {
                    menuKey.currentState.showButtonMenu();
                  },
                );
              },
              separatorBuilder: (_, __) =>
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Divider(),
                  ),
              itemCount: 10
          ),
        )
    );
  }
}
