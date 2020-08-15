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

  @override
  bool operator ==(Object other) => identical(this, other) || other is Evaluation && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value;
}

class EvaluationProvider {

  static Future<List<Evaluation>> getAll() async {
    List<Map<String, dynamic>> teams = await (await DB.instance).db.query('Evaluation', orderBy: 'value DESC',);
    return teams.map((m) => Evaluation.fromMap(m)).toList();
  }

  static Future<int> update(Evaluation eval) async {
    return await (await DB.instance).db.update(
        'Evaluation', eval.toMap()..remove('value'),
        where: 'value = ?', whereArgs: [eval.value]);
  }

}