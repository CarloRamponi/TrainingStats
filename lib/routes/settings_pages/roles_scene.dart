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
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:training_stats/datatypes/role.dart';

class RolesScene extends StatefulWidget {

  @override
  _RolesSceneState createState() => _RolesSceneState();

}

class _RolesSceneState extends State<RolesScene> {

  Future<List<Role>> roles;

  bool _editing;
  Role _editingRole;
  GlobalKey<FormState> _editingFormKey = GlobalKey();

  Role _creatingRole;

  @override
  void initState() {
    _editing = false;
    _editingRole = null;
    _refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(_editing) {
         setState(() {
           _editing = false;
         });
          return false;
        }


        return true;
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text('Roles'),
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: _createRolePopup,
          ),
          body: FutureBuilder(
            future: roles,
            builder: (context, AsyncSnapshot<List<Role>> roleSnap) {
              if(roleSnap.hasData) {
                if(roleSnap.data.length > 0) {
                  return ListView.separated(
                      itemBuilder: (context, index) {

                        Role role = roleSnap.data[index];

                        return ListTile(
                          leading: GestureDetector(
                            child: CircleAvatar(
                              backgroundColor: role.color,
                            ),
                            onTap: () {
                              _changeColorPopup(role);
                            },
                          ),
                          title: (_editing && _editingRole == role) ? Form(
                            key: _editingFormKey,
                            child: TextFormField(
                              initialValue: role.name,
                              autofocus: true,
                              onChanged: (value) {
                                _editingRole.name = value;
                              },
                              onEditingComplete: () {
                                _editingComplete();
                              },
                              maxLength: 128,
                              decoration: InputDecoration(
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
                          ) : GestureDetector(
                            child: Text(role.name),
                            onTap: () { _editRoleName(role); },
                          ),
                          trailing: (_editing && _editingRole == role) ? IconButton(
                            icon: Icon(
                              Icons.check,
                              color: Colors.green,
                            ),
                            onPressed: () {
                              _editingComplete();
                            },
                          ) : IconButton(
                            icon: Icon(
                              Icons.remove,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              _removeRole(role);
                            },
                          ),
                          onLongPress: () {
                            _removeRole(role);
                          },
                        );
                      },
                      separatorBuilder: (_, __) => Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Divider(),
                      ),
                      itemCount: roleSnap.data.length
                  );
                } else {
                  return Center(
                      child: Text("Start by creating a new role")
                  );
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          )
      ),
    );
  }

  void _refresh() {
    setState(() {
      roles = RoleProvider.getAll();
    });
  }

  void _removeRole(Role r) async {

    setState(() {
      _editing = false;
    });

    var result = await showDialog(context: context, builder: (_) => AlertDialog(
      title: Text("Are you sure?"),
      content: Text("Every player that owns this role will remain without a role!"),
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
      await RoleProvider.delete(r.id);
      _refresh();
    }
  }

  void _createRolePopup() async {

    setState(() {
      _editing = false;
    });

    _creatingRole = Role(name: "", color: Colors.lightBlue);
    GlobalKey<FormState> formKey = GlobalKey();

    var result = await showDialog(context: context, builder: (context) => AlertDialog(
      title: Text("New role"),
      content: SingleChildScrollView(
        child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  autofocus: true,
                  onChanged: (value) {
                    _creatingRole.name = value;
                  },
                  maxLength: 128,
                  decoration: InputDecoration(
                      hintText: "Role name",
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
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: BlockPicker(
                    pickerColor: _creatingRole.color,
                    onColorChanged: (color) { _creatingRole.color = color; },
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
              await RoleProvider.create(_creatingRole);
              Navigator.of(context).pop(true);
            }
          },
        )
      ],
    ));

    if(result != null)
      _refresh();

    _creatingRole = null;

  }

  void _editRoleName(Role r) {
    setState(() {
      _editing = true;
      _editingRole = r;
    });
  }

  void _editingComplete() async {
    if(_editingFormKey.currentState.validate()) {
      await RoleProvider.update(_editingRole);
      setState(() {
        _editing = false;
        _refresh();
      });
    }
  }

  void _changeColorPopup(Role r) async {

    var result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Change role color"),
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
                await RoleProvider.update(r);
                Navigator.of(context).pop(true);
              },
            )
          ],
          content: BlockPicker(
            pickerColor: r.color,
            onColorChanged: (color) { r.color = color; },
          ),
        );
      }
    );

    if(result != null) {
      _refresh();
    }

  }

}