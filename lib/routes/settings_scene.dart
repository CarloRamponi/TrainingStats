import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:training_stats/datatypes/evaluation.dart';
import 'package:training_stats/datatypes/role.dart';
import 'package:training_stats/widgets/drawer.dart';

class SettingsScene extends StatefulWidget {

  _SettingsSceneState createState() => _SettingsSceneState();

}

class _SettingsSceneState extends State<SettingsScene> {


  List<bool> _sections;

  Color _currentColor = Colors.lightBlue;
  bool _creatingRole = false;
  bool _creationLoading = false;
  TextEditingController _newRoleController = TextEditingController();

  bool _changingName = false;
  Role _changingNameRole;
  bool _changingNameAnimation = false;

  Future<List<Role>> roles;
  Future<List<Evaluation>> evaluations;

  bool _changingEvaluationName = false;
  Evaluation _changingEvaluation;
  bool _changingEvaluationAnimation = false;
  TextEditingController _evalController = TextEditingController();

  @override
  void initState() {
    _sections = List.filled(2, false);
    evaluations = EvaluationProvider.getAll();
    roles = RoleProvider.getAll();
    super.initState();
  }

  void _changeColor(Role r) async {
    _currentColor = r.color ?? Colors.lightBlue;
    await showDialog(context: context, builder: (_) => _colorPickerDialog());
    r.color = _currentColor;
    RoleProvider.update(r).then((value) {
      roles = RoleProvider.getAll()..then((value) {
        setState(() {

        });
      });
    });
  }

  void _createRole() {

    if(_newRoleController.text != "") {
      setState(() {
        _creationLoading = true;
      });

      RoleProvider.create(
          Role(color: _currentColor, name: _newRoleController.text)).then((
          value) {
        roles = RoleProvider.getAll()
          ..then((value) {
            setState(() {
              _creatingRole = false;
              _creationLoading = false;
              _newRoleController.clear();
            });
          });
      });
    } else {
      setState(() {
        _creatingRole = false;
        _creationLoading = false;
        _newRoleController.clear();
      });
    }

  }

  void _deleteRole(Role r) async {

    var result = await showDialog(context: context, builder: (_) => AlertDialog(
      title: Text("Are you sure?"),
      content: Text("Every player that owns this role will become without role!"),
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
      RoleProvider.delete(r.id).then((val) {
        roles = RoleProvider.getAll()..then((value) {
          setState(() {});
        });
      });
    }
  }

  void _changeName(Role r) {
    setState(() {
      _creatingRole = false;
      _changingName = true;
      _changingNameRole = r;
      _changingNameAnimation = false;
      _newRoleController.text = r.name;
    });
  }

  void _doneChangingName(Role r) {

    if(_newRoleController.text != "") {
      setState(() {
        _changingNameAnimation = true;
      });

      r.name = _newRoleController.text;
      _newRoleController.clear();

      RoleProvider.update(r).then((value) {
        roles = RoleProvider.getAll()
          ..then((value) {
            setState(() {
              _changingNameAnimation = false;
              _changingName = false;
            });
          });
      });
    } else {
      setState(() {
        _changingNameAnimation = false;
        _changingName = false;
      });
    }
  }

  void _changeEvaluation(Evaluation eval) {
    setState(() {
      _changingEvaluationName = true;
      _changingEvaluationAnimation = false;
      _changingEvaluation = eval;
      _evalController.text = eval.name;
    });
  }

  void _doneChangingEvaluation(Evaluation eval) {

    setState(() {
      _changingEvaluationAnimation = true;
    });


    eval.name = _evalController.text;

    EvaluationProvider.update(eval).then((_) {
      evaluations = EvaluationProvider.getAll()..then((_) {
          setState(() {
            _changingEvaluationAnimation = false;
            _changingEvaluationName = false;
          });
        });
      }
    );
  }

  ExpansionPanel _rolesPanel(int index) {

    return ExpansionPanel(
        headerBuilder: (_, bool expanded) {
          if(expanded) {
            return ListTile(
              leading: Icon(Icons.group_work),
              title: Text("Roles"),
              trailing: _creatingRole ? _creationLoading ? Container() : IconButton(
                icon: Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _creatingRole = false;
                  });
                },
              ) : IconButton(
                icon: Icon(Icons.add, color: Colors.green,),
                onPressed: () {
                  setState(() {
                    _creatingRole = true;
                    _changingName = false;
                    _newRoleController.text = "";
                  });
                },
              ),
            );
          } else {
            return ListTile(
              leading: Icon(Icons.group_work),
              title: Text("Roles"),
            );
          }
        },
        body: FutureBuilder(
          builder: (_, AsyncSnapshot<List<Role>> rolesSnap) {
            if(rolesSnap.hasData) {
              return Column(
                children: <Widget>[
                  if(_creatingRole)
                    ListTile(
                      leading: GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(100.0)),
                            color: _currentColor.withOpacity(0.6),
                          ),
                          width: 20.0,
                          height: 20.0,
                          margin: EdgeInsets.only(left: 5.0),
                        ),
                        onTap: () {
                          showDialog(context: context, builder: (_) => _colorPickerDialog());
                        },
                      ),
                      title: _creationLoading ? Text(_newRoleController.text) : TextField(
                        autofocus: true,
                        controller: _newRoleController,
                        maxLength: 128,
                        onEditingComplete: _createRole,
                        decoration: InputDecoration(
                          counterText: ''
                        ),
                      ),
                      trailing: _creationLoading ? CircularProgressIndicator() : IconButton(
                        icon: Icon(Icons.check, color: Colors.green,),
                        onPressed: _createRole,
                      ),
                    ),
                ] + rolesSnap.data.reversed.map((role) => ListTile(
                  leading: GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(100.0)),
                        color: role.color == null ? Colors.white : role.color.withOpacity(0.6),
                      ),
                      width: 20.0,
                      height: 20.0,
                      margin: EdgeInsets.only(left: 5.0),
                    ),
                    onTap: () => _changeColor(role),
                  ),
                  title: _changingName && _changingNameRole == role ? TextField(
                    autofocus: true,
                    controller: _newRoleController,
                    maxLength: 128,
                    onEditingComplete: () => _doneChangingName(role),
                    decoration: InputDecoration(
                        counterText: ''
                    ),
                  ) : GestureDetector(
                    child: Text(role.name),
                    onTap: () => _changeName(role),
                  ),
                  trailing: _changingName && _changingNameRole == role ? _changingNameAnimation ? CircularProgressIndicator() : IconButton(
                    icon: Icon(Icons.check, color: Colors.green,),
                    onPressed: () => _doneChangingName(role),
                  ) : IconButton(
                    icon: Icon(Icons.remove, color: Colors.red,),
                    onPressed: () => _deleteRole(role),
                  ),
                ),).toList(),
              );
            } else {
              return Center(
                child: Container(
                  padding: EdgeInsets.all(15.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
          future: roles,
        ),
        isExpanded: _sections[index]
    );

  }

  void _onColorChanged(Color color) {
    Navigator.of(context).pop();
    setState(() {
      _currentColor = color;
    });
  }

  AlertDialog _colorPickerDialog() {
    return AlertDialog(
      title: Text("Create a new role"),
      content: SingleChildScrollView(
        child: BlockPicker(
          pickerColor: _currentColor,
          onColorChanged: _onColorChanged,
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Ok"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  ExpansionPanel _evaluationsPanel(int index) {

    return ExpansionPanel(
        headerBuilder: (_, bool expanded) {
          return ListTile(
            leading: Icon(Icons.grade),
            title: Text("Evaluations"),
          );
        },
        body: FutureBuilder(
          builder: (_, AsyncSnapshot<List<Evaluation>> evalSnap) {
            if(evalSnap.hasData) {
              return Column(
                children: evalSnap.data.map((eval) => ListTile(
                  leading: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(100.0)),
                        color: Evaluation.getColor(eval.value),
                      ),
                      width: 20.0,
                      height: 20.0,
                      margin: EdgeInsets.only(left: 5.0),
                  ),
                  title: _changingEvaluationName && _changingEvaluation == eval ? TextField(
                    autofocus: true,
                    controller: _evalController,
                    maxLength: 2,
                    onEditingComplete: () => _doneChangingEvaluation(eval),
                    decoration: InputDecoration(
                        counterText: ''
                    ),
                  ) : GestureDetector(
                    child: Text(eval.name),
                    onTap: () => _changeEvaluation(eval),
                  ),
                  trailing: _changingEvaluationName && _changingEvaluation == eval ? _changingEvaluationAnimation ? CircularProgressIndicator() : IconButton(
                    icon: Icon(Icons.check, color: Colors.green,),
                    onPressed: () => _doneChangingEvaluation(eval),
                  ) : IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _changeEvaluation(eval),
                  ),
                ),).toList(),
              );
            } else {
              return Center(
                child: Container(
                  padding: EdgeInsets.all(15.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
          future: evaluations,
        ),
        isExpanded: _sections[index]
    );

  }

  @override
  Widget build(BuildContext context) {

    List<ExpansionPanel> panels = <ExpansionPanel>[
      _rolesPanel(0),
      _evaluationsPanel(1)
    ];

    return Scaffold(
        drawer: MyDrawer(),
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      _sections[index] = !isExpanded;
                      _changingName = false;
                      _creatingRole = false;
                      _changingEvaluationName = false;
                      _changingEvaluationAnimation = false;
                    });
                  },
                  children: panels
                ),
              ),
            )
        )
    );
  }

}