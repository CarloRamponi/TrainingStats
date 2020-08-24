import 'package:shared_preferences/shared_preferences.dart';

enum BoardType {
  COMPLETE,
  SIMPLE,
  VERY_SIMPLE
}

class BoardTypeProvider {
  static Future<BoardType> get() async => BoardType.values[(await SharedPreferences.getInstance()).getInt("BoardType") ?? 0];
  static Future<bool> set(BoardType t) async => await (await SharedPreferences.getInstance()).setInt("BoardType", t.index);

  static Future<bool> showLabels() async => (await SharedPreferences.getInstance()).getBool("ShowEvaluationLabels") ?? true;
  static Future<bool> setShowLabels(bool e) async => await (await SharedPreferences.getInstance()).setBool("ShowEvaluationLabels", e);

  static String getName(BoardType t) {
    switch(t) {

      case BoardType.COMPLETE:
        return "Complete";
        break;
      case BoardType.SIMPLE:
        return "Simple";
        break;
      case BoardType.VERY_SIMPLE:
        return "Very simple";
        break;
    }
  }
}