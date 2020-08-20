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

import 'package:training_stats/utils/db.dart';

class ScoreKeeperConfig {

  int setsToWin;
  int pointsPerSet;
  int lastSetPoints;
  bool belowZero;
  bool advantages;
  bool lastSetAdvantages;

  ScoreKeeperConfig({this.setsToWin, this.pointsPerSet, this.lastSetPoints, this.belowZero, this.advantages, this.lastSetAdvantages});

  static ScoreKeeperConfig fromMap(Map<String, dynamic> m) => ScoreKeeperConfig(
    setsToWin : m['setsToWin'],
    pointsPerSet: m['pointsPerSet'],
    lastSetPoints: m['lastSetPoints'],
    belowZero: m['belowZero'] == 1,
    advantages: m['advantages'] == 1,
    lastSetAdvantages: m['lastSetAdvantages'] == 1,
  );

  Map<String, dynamic> toMap() => {
    'setsToWin': this.setsToWin,
    'pointsPerSet': this.pointsPerSet,
    'lastSetPoints': this.lastSetPoints,
    'belowZero': this.belowZero ? 1 : 0,
    'advantages': this.advantages ? 1 : 0,
    'lastSetAdvantages': this.lastSetAdvantages ? 1 : 0,
  };

  static Future<ScoreKeeperConfig> load() async => ScoreKeeperConfig.fromMap((await (await DB.instance).db.query('ScoreKeeperConfig')).first);

  Future<int> update() async => await (await DB.instance).db.update('ScoreKeeperConfig', this.toMap());

}