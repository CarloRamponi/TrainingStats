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

class EvaluationsScene extends StatefulWidget {

  @override
  _EvaluationsSceneState createState() => _EvaluationsSceneState();

}

class _EvaluationsSceneState extends State<EvaluationsScene> {

  Future<List<Evaluation>> evaluations;

  bool _editing;
  Evaluation _editingItem;
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
            builder: (context, AsyncSnapshot<List<Evaluation>> evalSnap) {
              if(evalSnap.hasData) {
                return ListView.separated(
                    itemBuilder: (context, index) {

                      Evaluation eval = evalSnap.data[index];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Evaluation.getColor(eval.value),
                          child: Center(
                            child: Text(
                              eval.value.toString(),
                              style: Theme.of(context).textTheme.button.copyWith(color: useWhiteForeground(Evaluation.getColor(eval.value)) ? Colors.white : Colors.black),
                            ),
                          ),
                        ),
                        title: (_editing && _editingItem == eval) ? Form(
                          key: _editingFormKey,
                          child: TextFormField(
                            initialValue: eval.name,
                            autofocus: true,
                            onChanged: (value) {
                              _editingItem.name = value;
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
                          child: Text(eval.name),
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

  void _editEvalName(Evaluation e) {
    setState(() {
      _editing = true;
      _editingItem = e;
    });
  }

  void _editingComplete() async {
    if(_editingFormKey.currentState.validate()) {
      await EvaluationProvider.update(_editingItem);
      setState(() {
        _editing = false;
        _refresh();
      });
    }
  }

}