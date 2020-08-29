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

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:training_stats/widgets/drawer.dart';

class FunctionalityDescription {

  String title, description;
  void Function(BuildContext) onTap;

  FunctionalityDescription({
    this.title,
    this.description,
    this.onTap
  });

}

class HomeScene extends StatelessWidget  {

  final List<FunctionalityDescription> functionalities = [
    FunctionalityDescription(
      title: "Score keeper",
      description: "The name says it all, it's just a score keeper.",
      onTap: (context) => Navigator.of(context).pushNamed("/score_keeper")
    ),
    FunctionalityDescription(
        title: "Classic scout",
        description: "The classical scouting, in which you record all the ball touches.",
        onTap: (context) async {
            Navigator.of(context).pushNamed("/simple_scout");
        }
    ),
  ];

  Widget _functionalityCard(BuildContext context, FunctionalityDescription f) {
    return Card(
      child: FlatButton(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0).copyWith(top: 10.0),
              child: Text(
                f.title,
                style: Theme.of(context).textTheme.headline5,
                textAlign: TextAlign.left,
              ),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0).copyWith(bottom: 10.0),
              child: Text(
                f.description,
                style: Theme.of(context).textTheme.caption,
              ),
            )
          ],
        ),
        onPressed: () => f.onTap(context),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Training Stats"),
      ),
      drawer: MyDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: functionalities.sublist(0, functionalities.length ~/ 2).map<Widget>((f) => _functionalityCard(context, f)).toList(),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: functionalities.sublist(functionalities.length ~/ 2).map<Widget>((f) => _functionalityCard(context, f)).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

}