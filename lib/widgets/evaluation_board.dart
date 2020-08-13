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

class EvaluationBoard extends StatefulWidget {
  EvaluationBoard({Key key, @required this.onPressed}) : super(key: key);

  final bool Function(int) onPressed;

  @override
  _EvaluationBoardState createState() => _EvaluationBoardState();
}

class _EvaluationBoardState extends State<EvaluationBoard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 40,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
                child:
                FlatButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(3), bottomLeft: Radius.circular(3))),
                  child: null,
                  color: Colors.red,
                  onPressed: () { widget.onPressed(-2); },
                )
            ),
            Expanded(
                child:
                FlatButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  child: null,
                  color: Colors.orange,
                  onPressed: () { widget.onPressed(-1); },
                )
            ),
            Expanded(
                child:
                FlatButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  child: null,
                  color: Colors.yellow,
                  onPressed: () { widget.onPressed(1); },
                )
            ),
            Expanded(
                child:
                FlatButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(3), bottomRight: Radius.circular(3))),
                  child: null,
                  color: Colors.green,
                  onPressed: () { widget.onPressed(2); },
                )
            )
          ],
        ),
      ),
    );
  }
}
