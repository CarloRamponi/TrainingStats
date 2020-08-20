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

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:training_stats/datatypes/score_keeper_config.dart';

class ScoreKeeperScene extends StatefulWidget {
  final ScoreKeeperConfig config;

  ScoreKeeperScene({@required this.config});

  _ScoreKeeperSceneState createState() => _ScoreKeeperSceneState();
}

class _ScoreKeeperSceneState extends State<ScoreKeeperScene> {
  //the current set (from 0)
  int setNumber;

  //number of sets won by each team
  List<int> wonSets;

  //points for each set, for each team (points[setNumber][team])
  List<List<int>> points;

  //time elapsed from the start
  Duration timer;

  //the object tha retains the timer and calls the callback every second
  Timer _timerObj;

  //true if the game is ended.
  bool _gameEnded;

  void initState() {
    setNumber = 0;
    wonSets = List.filled(2, 0);

    points = [List.filled(2, 0)];

    timer = Duration.zero;

    _timerObj = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        timer += Duration(seconds: 1);
      });
    });

    _gameEnded = false;

    super.initState();
  }

  @override
  void dispose() {
    _timerObj.cancel();
    super.dispose();
  }

  void _nextSet() {
    setState(() {
      if (points[setNumber][0] > points[setNumber][1]) {

        wonSets[0]++;

        if(wonSets[0] == widget.config.setsToWin) {
          _endGame();
        } else {
          setNumber++;
          points.add(List.filled(2, 0));
        }

      } else if (points[setNumber][0] < points[setNumber][1]) {
        wonSets[1]++;

        if(wonSets[1] == widget.config.setsToWin) {
          _endGame();
        } else {
          setNumber++;
          points.add(List.filled(2, 0));
        }

      } else {
        setNumber++;
        points.add(List.filled(2, 0));
      }

    });
  }

  bool _lastSet() {
    return setNumber == (widget.config.setsToWin * 2) - 2;
  }

  void _endGame() {
    _timerObj.cancel();
    setState(() {
      _gameEnded = true;
    });
  }

  void _point(int team, int point) {
    setState(() {
      if(point > 0 && _setPoint(team)) {
        points[setNumber][team] += point;
        if (points[setNumber][team] < 0 && !widget.config.belowZero)
          points[setNumber][team] = 0;
        _nextSet();
      } else {
        points[setNumber][team] += point;
        if (points[setNumber][team] < 0 && !widget.config.belowZero)
          points[setNumber][team] = 0;
      }
    });
  }

  bool _setPoint(int team) {
    if(_lastSet()) {
      if(widget.config.lastSetAdvantages) {
        return points[setNumber][team] >= widget.config.lastSetPoints - 1 && points[setNumber][team] > points[setNumber][1-team];
      } else {
        return points[setNumber][team] == widget.config.lastSetPoints - 1;
      }
    } else {
      if(widget.config.advantages) {
        return points[setNumber][team] >= widget.config.pointsPerSet - 1 && points[setNumber][team] > points[setNumber][1-team];
      } else {
        return points[setNumber][team] == widget.config.pointsPerSet - 1;
      }
    }
  }

  Future<bool> _confirmExit() async {
    var result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Confirm exit"),
              content: Text("Are you sure you want to exit?"),
              actions: [
                FlatButton(
                  child: Text("No"),
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                ),
                FlatButton(
                  child: Text("Yes"),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                )
              ],
            ));

    return result == true;
  }

  Future<bool> _confirmEndGame() async {
    var result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Confirm end game"),
          content: Text("Are you sure you want end this game?"),
          actions: [
            FlatButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            FlatButton(
              child: Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            )
          ],
        ));

    return result == true;
  }

  Future<bool> _confirmRestart() async {
    var result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Confirm restart"),
          content: Text("Do you want to start a new game?\nThese results will be lost."),
          actions: [
            FlatButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            FlatButton(
              child: Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            )
          ],
        ));

    return result == true;
  }

  Future<bool> _willPopCallback() async {
    if (await _confirmExit()) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      return true;
    }

    return false;
  }

  Widget _buildTeamPanel(int team) {
    
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 70.0,
            child: Container(
              color: Colors.grey.withOpacity(0.15),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Card(
                      margin: EdgeInsets.only(right: 5.0),
                      child: Container(
                        height: 50.0,
                        width: 50.0,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 2.0),
                              child: Text("SETS"),
                            ),
                            Divider(
                              height: 0.0,
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  wonSets[team].toString(),
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .button
                                      .copyWith(
                                      fontSize: 20.0,
                                      color: wonSets[team] ==
                                          wonSets[1 - team]
                                          ? Colors.black
                                          : wonSets[team] >
                                          wonSets[1 - team]
                                          ? Colors.green
                                          : Colors.red),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Card(
                        margin: EdgeInsets.only(left: 5.0),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeOutBack,
                          height: 50.0,
                          width: 60.0 + min(125.0, (setNumber + 1) * 25.0),
                          child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: Container(
                                            width: 60.0,
                                            child: Center(
                                              child: Text("SET"),
                                            )),
                                      ),
                                      Expanded(
                                        child: Container(
                                            width: 60.0,
                                            child: Center(
                                              child: Text("POINTS"),
                                            )),
                                      )
                                    ]),
                                Expanded(
                                  child: Container(
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(topRight: Radius.circular(3.0), bottomRight: Radius.circular(3.0))
                                    ),
                                    child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        reverse: true,
                                        child: Container(
                                          width: (setNumber + 1) * 25.0,
                                          child: Row(
                                            children: List<Widget>.generate(
                                              (setNumber + 1) * 2,
                                                  (index) {
                                                if (index % 2 == 0) {
                                                  return VerticalDivider(width: 0.0);
                                                } else {
                                                  int setIndex = index ~/ 2;

                                                  Color backgroundColor;

                                                  //if it's not the running set
                                                  if (setIndex < setNumber || _gameEnded) {
                                                    if (points[setIndex][team] >
                                                        points[setIndex][1 -
                                                            team]) //if this team scored more points
                                                      backgroundColor =
                                                          Colors.green.withOpacity(0.3);
                                                    else if (points[setIndex][team] <
                                                        points[setIndex][1 -
                                                            team]) //if this team scored less points
                                                      backgroundColor =
                                                          Colors.red.withOpacity(0.3);
                                                    else //if both teams scored the same points
                                                      backgroundColor =
                                                          Colors.transparent;
                                                  } else {
                                                    backgroundColor =
                                                        Colors.transparent;
                                                  }

                                                  Color foregroundColor;

                                                  //if it is the running set
                                                  if (setIndex == setNumber && !_gameEnded) {
                                                    if (points[setIndex][team] >
                                                        points[setIndex][1 - team])
                                                      foregroundColor = Colors.green;
                                                    else if (points[setIndex][team] <
                                                        points[setIndex][1 - team])
                                                      foregroundColor = Colors.red;
                                                    else
                                                      foregroundColor = Colors.black;
                                                  } else {
                                                    foregroundColor = Colors.black;
                                                  }

                                                  return AnimatedContainer(
                                                    duration: Duration(
                                                        milliseconds: 500),
                                                    color: backgroundColor,
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.max,
                                                      children: [
                                                        Expanded(
                                                          child: Container(
                                                              width: 25.0,
                                                              child: Center(
                                                                child: Text((
                                                                    setIndex + 1)
                                                                    .toString()
                                                                ),
                                                              )),
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                              width: 25.0,
                                                              child: Center(
                                                                child: Text(
                                                                  points[setIndex][team]
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      color: foregroundColor
                                                                  ),
                                                                ),
                                                              )),
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        )
                                    ),
                                  ),
                                )
                              ]
                          ),
                        ))
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedPositioned(
                  duration: Duration(milliseconds: 500),
                  top: _gameEnded ? 30.0 : 10.0,
                  child: Text(
                    points[setNumber][team].toString().padLeft(2, '0'),
                    style: Theme
                        .of(context)
                        .textTheme
                        .headline1
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if(!_gameEnded)
                  Positioned(
                    bottom: 0.0,
                    child: Card(
                        margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                        child: Container(
                          height: 40.0,
                          width: MediaQuery.of(context).size.width / 2 - 50.0,
                          child: Row(
                            children: [
                              Expanded(
                                child: FlatButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(3.0),
                                          bottomLeft: Radius.circular(3.0))),
                                  child: Center(
                                    child: Icon(Icons.exposure_neg_1),
                                  ),
                                  color: Colors.red,
                                  onPressed: () {
                                    _point(team, -1);
                                  },
                                ),
                              ),
                              Expanded(
                                child: FlatButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(3.0),
                                          bottomRight: Radius.circular(3.0))),
                                  child: Center(
                                    child: Icon(Icons.exposure_plus_1),
                                  ),
                                  color: Colors.green,
                                  onPressed: () {
                                    _point(team, 1);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ))
                  )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
          body: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 55.0,
                  padding: EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      FlatButton(
                          child: Text("Exit"),
                          onPressed: () async {
                            if (await _willPopCallback())
                              Navigator.of(context).pop();
                          }),
                      Expanded(
                        child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "SET ${setNumber + 1}",
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                                Text(
                                  "${timer.inMinutes.toString().padLeft(2, '0')}:${(timer.inSeconds % 60).toString().padLeft(2, '0')}",
                                  style: Theme.of(context).textTheme.caption,
                                )
                              ],
                            )),
                      ),
                      _gameEnded ? FlatButton(
                        child: Text("Restart"),
                        onPressed: () async {
                          if(await _confirmRestart()) {
                            initState();
                            setState(() {});
                          }
                        },
                      ) : FlatButton(
                        child: Text("End game"),
                        onPressed: () async {
                          if(await _confirmEndGame()) {
                            _endGame();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 0.0,
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildTeamPanel(0)),
                      VerticalDivider(
                        width: 0.0,
                      ),
                      Expanded(
                        child: _buildTeamPanel(1),
                      )
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}
