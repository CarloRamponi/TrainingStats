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
import 'package:training_stats/datatypes/score_keeper_config.dart';
import 'package:training_stats/widgets/drawer.dart';

class ScoreKeeperConfigScene extends StatefulWidget {

  @override
  _ScoreKeeperConfigSceneState createState() => _ScoreKeeperConfigSceneState();
}

class _ScoreKeeperConfigSceneState extends State<ScoreKeeperConfigScene> {

  Future<ScoreKeeperConfig> configFtr;
  GlobalKey<FormState> _formState = GlobalKey();

  ScoreKeeperConfig config;

  @override
  void initState() {
    configFtr = ScoreKeeperConfig.load()..then((value) { config = value; });
    super.initState();
  }

  void _doneConfiguring() async {
    if(_formState.currentState.validate()) {
      await config.update();
      Navigator.of(context).pushNamed("/score_keeper/main", arguments: config);
    }
  }

  String _intValidator(value) {
    if(value == null || value == "") {
      return "Empty";
    } else {
      try {
        int i = int.parse(value);
        if(i <= 0) {
          return "Positive";
        } else {
          return null;
        }
      } catch (e) {
        print(e);
        return "Integer";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(activeSection: DrawerSection.SCORE_KEEPER,),
      appBar: AppBar(
        title: Text("Score keeper"),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: _doneConfiguring,
          )
        ],
      ),
      body: FutureBuilder(
        future: configFtr,
        builder: (context, AsyncSnapshot<ScoreKeeperConfig> configSnp) {
          if(configSnp.hasData) {

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Form(
                    key: _formState,
                    autovalidate: true,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text("Sets to win:"),
                          trailing: Container(
                            width: 50,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              initialValue: config.setsToWin.toString(),
                              onChanged: (value) {
                                config.setsToWin = int.parse(value);
                              },
                              validator: _intValidator,
                            ),
                          )
                        ),
                        ListTile(
                            title: Text("Points per set:"),
                            trailing: Container(
                              width: 50,
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                initialValue: config.pointsPerSet.toString(),
                                onChanged: (value) {
                                  config.pointsPerSet = int.parse(value);
                                },
                                validator: _intValidator,
                              ),
                            )
                        ),
                        SwitchListTile(
                          value: config.advantages,
                          onChanged: (value) {
                            setState(() {
                              config.advantages = value;
                            });
                          },
                          title: Text("Advantages"),
                        ),
                        ListTile(
                            title: Text("Last set's points:"),
                            trailing: Container(
                              width: 50,
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                initialValue: config.lastSetPoints.toString(),
                                onChanged: (value) {
                                  config.lastSetPoints = int.parse(value);
                                },
                                validator: _intValidator,
                              ),
                            )
                        ),
                        SwitchListTile(
                          value: config.lastSetAdvantages,
                          onChanged: (value) {
                            setState(() {
                              config.lastSetAdvantages = value;
                            });
                          },
                          title: Text("Last set advantages"),
                        ),
                        SwitchListTile(
                          value: config.belowZero,
                          onChanged: (value) {
                            setState(() {
                              config.belowZero = value;
                            });
                          },
                          title: Text("Points can be negative"),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FlatButton(
                            child: Text("Start"),
                            textColor: Colors.green,
                            onPressed: _doneConfiguring,
                          ),
                        )
                      ],
                    )
                ),
              )
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

}