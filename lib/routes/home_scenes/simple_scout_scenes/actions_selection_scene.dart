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
import 'package:training_stats/datatypes/action.dart' as TrainingStatsAction;

class ActionsSelectionScene extends StatefulWidget {
  _ActionsSelectionSceneState createState() => _ActionsSelectionSceneState();
}

enum MenuActions {
  CHECK_ALL,
  UNCHECK_ALL
}

class _ActionsSelectionSceneState extends State<ActionsSelectionScene> {

  List<TrainingStatsAction.Action> actions;
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
    List<TrainingStatsAction.Action> selected = [];
    for(int i = 0; i < actions.length; i++) {
      if(checked[i]){
        selected.add(actions[i]);
      }
    }

    if(selected.length == 0) {
      _scaffoldState.currentState.showSnackBar(
          SnackBar(
            content: Text("You should select some actions"),
            duration: Duration(seconds: 3),
          )
      );
    } else {
      Navigator.of(context).pop(selected);
    }
  }

  @override
  void initState() {
    TrainingStatsAction.ActionProvider.getAll().then((value) {
      setState(() {
        actions = value;
        checked = List.filled(actions.length, true);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("Select actions"),
        actions: [
          PopupMenuButton<MenuActions>(
            itemBuilder: (context) {
              return <PopupMenuEntry<MenuActions>>[
                PopupMenuItem<MenuActions>(
                  value: MenuActions.CHECK_ALL,
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
                PopupMenuItem<MenuActions>(
                  value: MenuActions.UNCHECK_ALL,
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
            onSelected: (MenuActions a) {
              switch(a) {

                case MenuActions.CHECK_ALL:
                  _checkAll();
                  break;
                case MenuActions.UNCHECK_ALL:
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

          if(actions == null) {

            //loading...
            return Center(
              child: CircularProgressIndicator(),
            );

          } else {

            if(actions.length == 0) {

              return Center(
                child: Text("You should create some actions first (settings)"),
              );

            } else {

              return ListView.separated(
                  itemBuilder: (context, index) {

                    TrainingStatsAction.Action action = actions[index];

                    return CheckboxListTile(
                      value: checked[index],
                      onChanged: (value) {
                        setState(() {
                          checked[index] = value;
                        });
                      },
                      secondary: CircleAvatar(
                        backgroundColor: action.color,
                      ),
                      title: Text(action.name),
                      subtitle: Text(action.shortName),
                    );
                  },
                  separatorBuilder: (_, __) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Divider(),
                  ),
                  itemCount: actions.length
              );
            }
          }
        },
      ),
    );
  }

}