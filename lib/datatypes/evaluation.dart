
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:training_stats/utils/db.dart';

class Evaluation {
  int value;
  String name;

  Evaluation({this.value, this.name});

  static Evaluation fromMap(Map<String, dynamic> m) {
    return Evaluation(value: m['value'], name: m['name']);
  }

  Map<String, dynamic> toMap() {
    return {
      'value': this.value,
      'name': this.name
    };
  }

  static Color getColor(int value) {
    switch(value) {
      case -3:
        return Colors.red;
      case -2:
        return Colors.deepOrange;
      case -1:
        return Colors.orange;
      case 1:
        return Colors.yellow;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.green;
      default:
        return Colors.brown;
    }
  }
}

class EvaluationProvider {

  static Future<List<Evaluation>> getAll() async {
    List<Map<String, dynamic>> teams = await (await DB.instance).db.query('Evaluation', orderBy: 'value');
    return teams.map((m) => Evaluation.fromMap(m)).toList();
  }

  static Future<int> update(Evaluation eval) async {
    return await (await DB.instance).db.update(
        'Evaluation', eval.toMap()..remove('value'),
        where: 'value = ?', whereArgs: [eval.value]);
  }

}