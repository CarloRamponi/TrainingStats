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
 * along with this program. If not, see <http://www.gnu.org/livaluescenses/>.
 *
 */

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ScoreKeeperConfig {

  int setsToWin;
  int pointsPerSet;
  int lastSetPoints;
  bool belowZero;
  bool advantages;
  bool lastSetAdvantages;

  ScoreKeeperConfig({
    this.setsToWin = 2,
    this.pointsPerSet = 25,
    this.lastSetPoints = 15,
    this.belowZero = false,
    this.advantages = true,
    this.lastSetAdvantages = false
  });

  static ScoreKeeperConfig fromMap(Map<String, dynamic> m) => ScoreKeeperConfig(
    setsToWin : m['setsToWin'],
    pointsPerSet: m['pointsPerSet'],
    lastSetPoints: m['lastSetPoints'],
    belowZero: m['belowZero'],
    advantages: m['advantages'],
    lastSetAdvantages: m['lastSetAdvantages'],
  );

  Map<String, dynamic> toMap() => {
    'setsToWin': this.setsToWin,
    'pointsPerSet': this.pointsPerSet,
    'lastSetPoints': this.lastSetPoints,
    'belowZero': this.belowZero,
    'advantages': this.advantages,
    'lastSetAdvantages': this.lastSetAdvantages,
  };

  static Future<ScoreKeeperConfig> load() async {

    String json = (await SharedPreferences.getInstance()).getString('ScoreKeeperConfig');

    if(json != null) {
      try {
        return ScoreKeeperConfig.fromMap(jsonDecode(json));
      } catch(e) {
        return ScoreKeeperConfig();
      }
    } else {
      return ScoreKeeperConfig();
    }

  }

  Future<bool> update() async {
    String json = jsonEncode(this.toMap());
    return await (await SharedPreferences.getInstance()).setString('ScoreKeeperConfig', json);
  }

}