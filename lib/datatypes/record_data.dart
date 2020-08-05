
import 'package:training_stats/datatypes/action_data.dart';
import 'package:training_stats/datatypes/evaluation_data.dart';
import 'package:training_stats/datatypes/player_data.dart';

class RecordData {

  RecordData({this.player, this.action, this.evaluation, this.timestamp}) {
    if(this.timestamp == null) {
      this.timestamp = DateTime.now();
    }
  }

  PlayerData player;
  ActionData action;
  EvaluationData evaluation;
  DateTime timestamp;

}