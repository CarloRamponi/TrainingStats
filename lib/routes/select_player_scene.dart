import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:training_stats/datatypes/player.dart';
import 'package:training_stats/datatypes/team.dart';
import 'package:training_stats/utils/db.dart';

class SelectPlayerScene extends StatefulWidget {
  SelectPlayerScene({Key key, this.team}) : super(key: key);

  final Team team;

  @override
  _SelectPlayerSceneState createState() => _SelectPlayerSceneState();
}

class _SelectPlayerSceneState extends State<SelectPlayerScene> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<Player>> players;
  TextEditingController _textFieldController = TextEditingController();

  void _onTextChanged() {
    players = TeamProvider.getPlayersNotInTeam(widget.team.id,
        query: _textFieldController.text)
      ..then((value) {
        setState(() {});
      });
  }

  @override
  void initState() {
    players = TeamProvider.getPlayersNotInTeam(widget.team.id);
    _textFieldController.addListener(_onTextChanged);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: TextField(
            autofocus: true,
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(fontSize: 20.0, color: Colors.white),
            controller: _textFieldController,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            scaffoldKey.currentState.removeCurrentSnackBar();
            scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text("Not yet implemented."),
              duration: Duration(milliseconds: 700),
            ));
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
                        onTap: () async {
                          await TeamProvider.insertPlayer(teamId: widget.team.id, playerId: playerSnap.data[index].id);
                          Navigator.pop(context, true);
                        },
                        onDelete: null,
                      );
                    },
                    separatorBuilder: (_, __) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Divider(),
                        ),
                    itemCount: playerSnap.data.length);
              } else {
                return Center(
                  child: Text("Start by creating a player!"),
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
