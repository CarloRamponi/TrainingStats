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
 
 

import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Evaluation {
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

  static Map<int, String> _current;

  static Map<int, String> _default() => {
    3: "#",
    2: "+",
    1: "!",
    -1: "/",
    -2: "-",
    -3: "="
  };

  static Future<Map<int, String>> getAll() async {

    if(_current == null) {

      String json = (await SharedPreferences.getInstance()).getString('Evaluations');

      if(json != null) {
        try {
          Map<String, dynamic> maps = jsonDecode(json);
          _current = maps.map((key, value) => MapEntry<int, String>(int.parse(key), value.toString()));
        } catch (e) {
          _current = _default();
        }
      } else {
        _current = _default();
      }
    }

    return _current;

  }

  static Future<bool> update(int value, String name) async {

    Map<int, String> all = await getAll();
    all[value] = name;

    String json = jsonEncode(all.map((key, value) => MapEntry<String, String>(key.toString(), value)));
    return await (await SharedPreferences.getInstance()).setString('Evaluations', json);

  }

}