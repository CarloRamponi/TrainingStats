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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:training_stats/datatypes/training.dart';

class SimpleScoutReportScene extends StatefulWidget{

  final Training training;

  SimpleScoutReportScene({
    @required this.training
  });

  @override
  _SimpleScoutReportSceneState createState() => _SimpleScoutReportSceneState();

}

class _SimpleScoutReportSceneState extends State<SimpleScoutReportScene> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text(widget.training.toMap().toString()),
            Text(widget.training.players.map((e) => e.name).join(", ")),
            Text(widget.training.actions.map((e) => e.name).join(", ")),
            Text(widget.training.records.map((e) => e.player.name + " => " + e.action.name + " => " + e.evaluation.toString()).join("\n")),
          ],
        ),
      ),
    );
  }

}
