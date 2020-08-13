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
 
 
import 'dart:collection';
import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:training_stats/datatypes/record_data.dart';

class EvaluationHistoryTile extends StatelessWidget {
  
  final RecordData record;
  
  EvaluationHistoryTile({
    @required this.record
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      width: 35,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: record.getEvalColor()
      ),
      child: Center(
        child: Text(
          record.player.shortName,
          style: TextStyle(
              color: Colors.white
          ),
        ),
      )
    );
  }
  
}

class EvaluationHistoryBoard extends StatefulWidget {
  EvaluationHistoryBoard({Key key}) : super(key: key);

  @override
  EvaluationHistoryBoardState createState() => EvaluationHistoryBoardState();
}

enum _AnimationPhase {
  NONE,
  INSERT,
  REMOVE,
}

class EvaluationHistoryBoardState extends State<EvaluationHistoryBoard> {

  static final double _SIZE = 35.0;
  static final Duration _ANIM_DURATION = Duration(milliseconds: 500);
  static final double _PADDING = 5.0;

  List<RecordData> records;

  _AnimationPhase animationPhase;

  @override
  void initState() {
    records = List();
    animationPhase = _AnimationPhase.NONE;
    super.initState();
  }

  void addRecord(RecordData r) {
    records.add(r);

    setState(() {
      animationPhase = _AnimationPhase.INSERT;
    });
    Future.delayed(_ANIM_DURATION, () {
      setState(() {
        animationPhase = _AnimationPhase.NONE;
      });
    });
  }

  void removeLastRecord() {
    setState(() {
      animationPhase = _AnimationPhase.REMOVE;
    });
    Future.delayed(_ANIM_DURATION, () {
      records.removeLast();
      setState(() {
        animationPhase = _AnimationPhase.NONE;
      });
    });
  }

  double lastWidgetTopPosition() {
    switch(animationPhase) {
      case _AnimationPhase.NONE:
        return _SIZE/2.0;
        break;
      case _AnimationPhase.INSERT:
        return 60.0;
        break;
      case _AnimationPhase.REMOVE:
        return 60.0;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> widgets = List();

    if(records.length > 0) {

      widgets.add(
          AnimatedPositioned(
            key: ObjectKey(records.last),
            top: lastWidgetTopPosition(),
            right: (MediaQuery.of(context).size.width / 2.0) - (_SIZE / 2.0),
            duration: _ANIM_DURATION,
            curve: Curves.easeOutBack,
            child: EvaluationHistoryTile(
              record: records.last,
            )
          )
      );


      for (int i = records.length - 2; i >= max(0, records.length - 8); i--) {
        widgets.add(
            AnimatedPositioned(
              key: ObjectKey(records[i]),
              top: _SIZE/2.0,
              right: (MediaQuery.of(context).size.width / 2.0) - (_SIZE / 2.0) + ((_PADDING + _SIZE) * (records.length - 1 - i - (animationPhase == _AnimationPhase.REMOVE ? 1 : 0))),
              duration: _ANIM_DURATION,
              curve: Curves.easeOutBack,
              child: EvaluationHistoryTile(
                record: records[i]
              )
            )
        );
      }
    }

    return Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(width: 1, color: Colors.grey)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top: -12,
              child: Icon(
                Icons.arrow_drop_down,
                size: 30,
                color: Colors.grey,
              ),
            ),
          ] + widgets,
        ),
      );
  }
}
