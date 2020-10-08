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
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:training_stats/datatypes/action.dart' as LocalAction;

class ActionsScene extends StatefulWidget {

  @override
  _ActionsSceneState createState() => _ActionsSceneState();

}

class _ActionsSceneState extends State<ActionsScene> {

  Future<List<LocalAction.Action>> actionsFtr;
  List<LocalAction.Action> actions;

  LocalAction.Action _creatingAction;

  @override
  void initState() {
    _refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actions'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _createActionPopup,
      ),
      body: FutureBuilder(
        future: actionsFtr,
        builder: (context, AsyncSnapshot<List<LocalAction.Action>> actionSnap) {
          if(actionSnap.hasData) {
            if(actionSnap.data.length > 0) {
              return ReorderableListView(
                children: actions.map((action) => ListTile(
                  key: ValueKey(action.id),
                  leading: GestureDetector(
                    child: CircleAvatar(
                      backgroundColor: action.color,
                    ),
                    onTap: () {
                      _changeColorPopup(action);
                    },
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(action.name),
                      ),
                      Text(
                        'W',
                        style: TextStyle(
                            color: action.winning ? Colors.green : Colors.grey
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5.0),
                        child: Text(
                          'L',
                          style: TextStyle(
                            color: action.losing ? Colors.red : Colors.grey
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(action.shortName),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.remove,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      _removeAction(action);
                    },
                  ),
                  onTap: () {
                    _editAction(action);
                  },
                )).toList(),
                onReorder: _onReorder,
              );
            } else {
              return Center(
                  child: Text("Start by creating a new action")
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      )
    );
  }

  void _refresh() {
    setState(() {
      actionsFtr = LocalAction.ActionProvider.getAll()..then((value) => actions = value);
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      LocalAction.Action action = actions.removeAt(oldIndex);
      actions.insert(newIndex - (newIndex > oldIndex ? 1 : 0), action);
    });
    _updateOrders();
  }

  void _updateOrders() {
    for(int index = 0; index < actions.length; index++) {
      actions[index].index = index;
      LocalAction.ActionProvider.update(actions[index]);
    }
  }

  void _removeAction(LocalAction.Action a) async {

    var result = await showDialog(context: context, builder: (_) => AlertDialog(
      title: Text("Are you sure?"),
      content: Text("Every report containing this action will be deleted too! Be careful!"),
      actions: <Widget>[
        FlatButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.pop(context, null);
          },
        ),
        FlatButton(
          child: Text("Delete"),
          onPressed: () {
            Navigator.pop(context, true);
          },
        )
      ],
    ));

    if(result == true) {

      var result = await showDialog(context: context, builder: (_) => AlertDialog(
        title: Text("Are you really sure?"),
        content: Text("I am asking this you twice because this is a really dangerous action!"),
        actions: <Widget>[
          FlatButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.pop(context, null);
            },
          ),
          FlatButton(
            child: Text("I know what I'm doing"),
            onPressed: () {
              Navigator.pop(context, true);
            },
          )
        ],
      ));

      if(result == true) {
        await LocalAction.ActionProvider.delete(a.id);
        _refresh();
      }
    }
  }

  void _createActionPopup() async {

    _creatingAction = LocalAction.Action(name: "", shortName: "", color: Colors.lightBlue, winning: true, losing: true);
    GlobalKey<FormState> formKey = GlobalKey();
    FocusNode shortNameFocusNode = FocusNode();

    var result = await showDialog(context: context, builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text("New action"),
        content: SingleChildScrollView(
          child: Form(
              key: formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    autofocus: true,
                    onChanged: (value) {
                      _creatingAction.name = value;
                    },
                    onEditingComplete: () {
                      shortNameFocusNode.requestFocus();
                    },
                    maxLength: 128,
                    decoration: InputDecoration(
                        hintText: "Action name",
                        counterText: ""
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Enter some text";
                      } else {
                        return null;
                      }
                    },
                  ),
                  TextFormField(
                    focusNode: shortNameFocusNode,
                    onChanged: (value) {
                      _creatingAction.shortName = value;
                    },
                    maxLength: 2,
                    decoration: InputDecoration(
                        hintText: "Action short name",
                        counterText: ""
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Enter some text";
                      } else {
                        return null;
                      }
                    },
                  ),
                  Tooltip(
                    message: "Checked if a perfect action of this kind results in a point for the team",
                    child: CheckboxListTile(
                      value: _creatingAction.winning,
                      onChanged: (value) {
                        setDialogState(() {
                          _creatingAction.winning = value;
                        });
                      },
                      title: Text("Winning"),
                    ),
                  ),
                  Tooltip(
                    message: "Checked if a bad action of this kind results in a point for the other team",
                    child: CheckboxListTile(
                      value: _creatingAction.losing,
                      onChanged: (value) {
                        setDialogState(() {
                          _creatingAction.losing = value;
                        });
                      },
                      title: Text("Losing"),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: BlockPicker(
                      pickerColor: _creatingAction.color,
                      onColorChanged: (color) { _creatingAction.color = color; },
                    ),
                  )
                ],
              )
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text("Create"),
            onPressed: () async {
              if(formKey.currentState.validate()) {
                await LocalAction.ActionProvider.create(_creatingAction);
                Navigator.of(context).pop(true);
              }
            },
          )
        ],
      ),
    ));

    if(result != null)
      _refresh();

    _creatingAction = null;

  }

  void _editAction(LocalAction.Action action) async {

    GlobalKey<FormState> _form = GlobalKey();
    FocusNode shortNameFocusNode = FocusNode();

    var result = await showDialog(context: context, builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
          title: Text("Edit action"),
          actions: [
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Update"),
              onPressed: () async {
                if(_form.currentState.validate()) {
                  await LocalAction.ActionProvider.update(action);
                  Navigator.of(context).pop(true);
                }
              },
            )
          ],
          content: SingleChildScrollView(
            child: Container(
              child: Form(
                  key: _form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        initialValue: action.name,
                        autofocus: true,
                        onChanged: (value) {
                          action.name = value;
                        },
                        onEditingComplete: () {
                          shortNameFocusNode.requestFocus();
                        },
                        maxLength: 128,
                        decoration: InputDecoration(
                            hintText: "Action name",
                            counterText: ""
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Enter some text";
                          } else {
                            return null;
                          }
                        },
                      ),
                      TextFormField(
                        initialValue: action.shortName,
                        focusNode: shortNameFocusNode,
                        onChanged: (value) {
                          action.shortName = value;
                        },
                        maxLength: 2,
                        decoration: InputDecoration(
                            hintText: "Action short name",
                            counterText: ""
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Enter some text";
                          } else {
                            return null;
                          }
                        },
                        onEditingComplete: () async {
                          if(_form.currentState.validate()) {
                            await LocalAction.ActionProvider.update(action);
                            Navigator.of(context).pop(true);
                          }
                        },
                      ),
                      Tooltip(
                        message: "Checked if a perfect action of this kind results in a point for the team",
                        child: CheckboxListTile(
                          value: action.winning,
                          onChanged: (value) {
                            setDialogState(() {
                              action.winning = value;
                            });
                          },
                          title: Text("Winning"),
                        ),
                      ),
                      Tooltip(
                        message: "Checked if a bad action of this kind results in a point for the other team",
                        child: CheckboxListTile(
                          value: action.losing,
                          onChanged: (value) {
                            setDialogState(() {
                              action.losing = value;
                            });
                          },
                          title: Text("Losing"),
                        ),
                      ),
                    ],
                  )
              ),
            ),
          )
      ),
    ));

    if(result == true) {
      _refresh();
    }

  }

  void _changeColorPopup(LocalAction.Action a) async {

    var result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Change action color"),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Ok'),
              onPressed: () async {
                await LocalAction.ActionProvider.update(a);
                Navigator.of(context).pop(true);
              },
            )
          ],
          content: BlockPicker(
            pickerColor: a.color,
            onColorChanged: (color) { a.color = color; },
          ),
        );
      }
    );

    if(result != null) {
      _refresh();
    }

  }

}