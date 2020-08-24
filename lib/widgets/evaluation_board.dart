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
 
 
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:training_stats/datatypes/board_type.dart';
import 'package:training_stats/datatypes/evaluation.dart';

class EvaluationBoard extends StatefulWidget {

  EvaluationBoard({
    Key key,
    @required this.onPressed,
    this.boardType,
    this.showLabels = true
  }) : super(key: key);

  final bool Function(int) onPressed;
  final BoardType boardType;
  final bool showLabels;
  
  @override
  EvaluationBoardState createState() => EvaluationBoardState();
  
}

class EvaluationBoardState extends State<EvaluationBoard> {

  Map<int, String> evaluations;
  
  @override
  void initState() {
    refreshLabels();
    super.initState();
  }
  
  void refreshLabels() {
    EvaluationProvider.getAll().then((value) {
      setState(() {
        evaluations = value;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {

    switch(widget.boardType) {

      case BoardType.COMPLETE:

        return Card(
          child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.0)
              ),
              height: 80.0,
              child: Column(
                children: [
                  Container(
                    height: 40.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                            child:
                            FlatButton(
                              shape: ContinuousRectangleBorder(),
                              child: widget.showLabels ? Center(
                                child: evaluations == null ? null : Text(
                                    evaluations[-3]
                                ),
                              ) : null,
                              color: Evaluation.getColor(-3),
                              onPressed: () { widget.onPressed(-3); },
                            )
                        ),
                        Expanded(
                            child:
                            FlatButton(
                              shape: ContinuousRectangleBorder(),
                              child: widget.showLabels ? Center(
                                child: evaluations == null ? null : Text(
                                    evaluations[3]
                                ),
                              ) : null,
                              color: Evaluation.getColor(3),
                              onPressed: () { widget.onPressed(3); },
                            )
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 40.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                            child:
                            FlatButton(
                              shape: ContinuousRectangleBorder(),
                              child: widget.showLabels ? Center(
                                child: evaluations == null ? null : Text(
                                    evaluations[-2]
                                ),
                              ) : null,
                              color: Evaluation.getColor(-2),
                              onPressed: () { widget.onPressed(-2); },
                            )
                        ),
                        Expanded(
                            child:
                            FlatButton(
                              shape: ContinuousRectangleBorder(),
                              child: widget.showLabels ? Center(
                                child: evaluations == null ? null : Text(
                                    evaluations[-1]
                                ),
                              ) : null,
                              color: Evaluation.getColor(-1),
                              onPressed: () { widget.onPressed(-1); },
                            )
                        ),
                        Expanded(
                            child:
                            FlatButton(
                              shape: ContinuousRectangleBorder(),
                              child: widget.showLabels ? Center(
                                child: evaluations == null ? null : Text(
                                    evaluations[1]
                                ),
                              ) : null,
                              color: Evaluation.getColor(1),
                              onPressed: () { widget.onPressed(1); },
                            )
                        ),
                        Expanded(
                            child:
                            FlatButton(
                              shape: ContinuousRectangleBorder(),
                              child: widget.showLabels ? Center(
                                child: evaluations == null ? null : Text(
                                    evaluations[2]
                                ),
                              ) : null,
                              color: Evaluation.getColor(2),
                              onPressed: () { widget.onPressed(2); },
                            )
                        )
                      ],
                    ),
                  )
                ],
              )
          ),
        );

        break;

      case BoardType.SIMPLE:

        return Card(
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.0)
            ),
            height: 50.0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                    child:
                    FlatButton(
                      shape: ContinuousRectangleBorder(),
                      child: widget.showLabels ? Center(
                        child: evaluations == null ? null : Text(
                                    evaluations[-3]
                        ),
                      ) : null,
                      color: Evaluation.getColor(-3),
                      onPressed: () { widget.onPressed(-3); },
                    )
                ),
                Expanded(
                    child:
                    FlatButton(
                      shape: ContinuousRectangleBorder(),
                      child: widget.showLabels ? Center(
                        child: evaluations == null ? null : Text(
                                    evaluations[-2]
                        ),
                      ) : null,
                      color: Evaluation.getColor(-2),
                      onPressed: () { widget.onPressed(-2); },
                    )
                ),
                Expanded(
                    child:
                    FlatButton(
                      shape: ContinuousRectangleBorder(),
                      child: widget.showLabels ? Center(
                        child: evaluations == null ? null : Text(
                                    evaluations[2]
                        ),
                      ) : null,
                      color: Evaluation.getColor(2),
                      onPressed: () { widget.onPressed(2); },
                    )
                ),
                Expanded(
                    child:
                    FlatButton(
                      shape: ContinuousRectangleBorder(),
                      child: widget.showLabels ? Center(
                        child: evaluations == null ? null : Text(
                                    evaluations[3]
                        ),
                      ) : null,
                      color: Evaluation.getColor(3),
                      onPressed: () { widget.onPressed(3); },
                    )
                ),
              ],
            ),
          ),
        );

        break;

      case BoardType.VERY_SIMPLE:

      case BoardType.SIMPLE:

        return Card(
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.0)
            ),
            height: 50.0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                    child:
                    FlatButton(
                      shape: ContinuousRectangleBorder(),
                      child: widget.showLabels ? Center(
                        child: evaluations == null ? null : Text(
                                    evaluations[-3]
                        ),
                      ) : null,
                      color: Evaluation.getColor(-3),
                      onPressed: () { widget.onPressed(-3); },
                    )
                ),
                Expanded(
                    child:
                    FlatButton(
                      shape: ContinuousRectangleBorder(),
                      child: widget.showLabels ? Center(
                        child: evaluations == null ? null : Text(
                                    evaluations[3]
                        ),
                      ) : null,
                      color: Evaluation.getColor(3),
                      onPressed: () { widget.onPressed(3); },
                    )
                ),
              ],
            ),
          ),
        );

        break;

      default:
        throw ArgumentError();

    }
  }  
  
}