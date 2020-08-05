import 'package:training_stats/datatypes/exercise_data.dart';
import 'package:training_stats/datatypes/action_data.dart';
import 'package:training_stats/datatypes/player_data.dart';

class TrainingData {

  TrainingData({this.exercise, this.players, this.actions});

  ExerciseData exercise;
  List<PlayerData> players;
  List<ActionData> actions;

}