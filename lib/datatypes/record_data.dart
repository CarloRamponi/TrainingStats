
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:training_stats/datatypes/action_data.dart';
import 'package:training_stats/datatypes/player_data.dart';

class RecordData {

  RecordData({this.player, this.action, this.evaluation, this.timestamp}) {
    if(this.timestamp == null) {
      this.timestamp = DateTime.now();
    }
  }

  PlayerData player;
  ActionData action;
  int evaluation;
  DateTime timestamp;

  Color getEvalColor() {
    switch(evaluation) {
      case -2:
        return Colors.red;
      case -1:
        return Colors.orange;
      case 1:
        return Colors.yellow;
      case 2:
        return Colors.green;
      default:
        return Colors.brown;
    }
  }

}