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
import 'package:training_stats/datatypes/evaluation.dart';
import 'package:training_stats/datatypes/role.dart';

class EvaluationsNamesScene extends StatefulWidget {

  @override
  _EvaluationsNamesSceneState createState() => _EvaluationsNamesSceneState();

}

class _EvaluationsNamesSceneState extends State<EvaluationsNamesScene> {

  Future<Map<int, String>> evaluations;

  bool _editing;
  int _editingItem;
  String _editingName;
  GlobalKey<FormState> _editingFormKey = GlobalKey();

  @override
  void initState() {
    _editing = false;
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
            title: Text('Evaluations'),
          ),
          body: FutureBuilder(
            future: evaluations,
            builder: (context, AsyncSnapshot<Map<int, String>> evalSnap) {
              if(evalSnap.hasData) {

                List<int> keys = evalSnap.data.keys.toList();

                return ListView.separated(
                    itemBuilder: (context, index) {

                      int eval = keys[index];
                      String name = evalSnap.data[eval];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Evaluation.getColor(eval),
                          child: Center(
                            child: Text(
                              eval.toString(),
                              style: Theme.of(context).textTheme.button.copyWith(color: useWhiteForeground(Evaluation.getColor(eval)) ? Colors.white : Colors.black),
                            ),
                          ),
                        ),
                        title: (_editing && _editingItem == eval) ? Form(
                          key: _editingFormKey,
                          child: TextFormField(
                            initialValue: name,
                            autofocus: true,
                            onChanged: (value) {
                              _editingName = value;
                            },
                            onEditingComplete: () {
                              _editingComplete();
                            },
                            maxLength: 2,
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
                          child: Text(name),
                          onTap: () { _editEvalName(eval); },
                        ),
                        trailing: (_editing && _editingItem == eval) ? IconButton(
                          icon: Icon(
                            Icons.check,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            _editingComplete();
                          },
                        ) : IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            _editEvalName(eval);
                          },
                        )
                      );
                    },
                    separatorBuilder: (_, __) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Divider(),
                    ),
                    itemCount: evalSnap.data.length
                );
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
      evaluations = EvaluationProvider.getAll();
    });
  }

  void _editEvalName(int e) {
    if(!_editing) {
      setState(() {
        _editing = true;
        _editingItem = e;
      });
    }
  }

  void _editingComplete() async {
    if(_editingFormKey.currentState.validate()) {
      await EvaluationProvider.update(_editingItem, _editingName);
      setState(() {
        _editing = false;
        _refresh();
      });
    }
  }

}