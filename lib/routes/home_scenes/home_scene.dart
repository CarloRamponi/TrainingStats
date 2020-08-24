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
import 'package:training_stats/datatypes/action.dart' as TrainingStatsAction;
import 'package:training_stats/datatypes/player.dart';
import 'package:training_stats/datatypes/team.dart';
import 'package:training_stats/datatypes/training.dart';
import 'package:training_stats/routes/home_scenes/simple_scout_scenes/actions_selection_scene.dart';
import 'package:training_stats/routes/players_scenes/players_selection_scene.dart';
import 'package:training_stats/routes/teams_scenes/team_selection.dart';
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

          Team team = await Navigator.push(context, MaterialPageRoute<Team>(
            builder: (context) => SelectTeam()
          ));

          if(team != null) {
            List<Player> players = await Navigator.push(
                context, MaterialPageRoute<List<Player>>(
                builder: (context) => PlayersSelectionScene(team: team)
            ));

            if(players != null) {
              List<TrainingStatsAction.Action> actions = await Navigator.of(
                  context).push(
                  MaterialPageRoute<List<TrainingStatsAction.Action>>(
                      builder: (context) => ActionsSelectionScene()
                  ));

              if(actions != null) {
                Training training = Training(
                    team: team,
                    players: players,
                    actions: actions
                );

                Navigator.of(context).pushNamed(
                    "/simple_scout", arguments: training);
              }
            }
          }

        }
    ),
    FunctionalityDescription(
        title: "Title",
        description: "Description",
        onTap: (context) {}
    ),
    FunctionalityDescription(
        title: "Title",
        description: "Description",
        onTap: (context) {}
    ),
    FunctionalityDescription(
        title: "Title",
        description: "Description",
        onTap: (context) {}
    ),
    FunctionalityDescription(
        title: "Title",
        description: "Description",
        onTap: (context) {}
    ),
    FunctionalityDescription(
        title: "Title",
        description: "Description",
        onTap: (context) {}
    ),
    FunctionalityDescription(
        title: "Title",
        description: "Description",
        onTap: (context) {}
    ),
    FunctionalityDescription(
        title: "Title",
        description: "Description",
        onTap: (context) {}
    ),
  ];

  Widget _functionalityCard(BuildContext context, FunctionalityDescription f) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
            child: Text(
              f.title,
              style: Theme.of(context).textTheme.headline5,
              textAlign: TextAlign.left,
            ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            child: Text(
              f.description,
              style: Theme.of(context).textTheme.caption,
            ),
          ),
          Expanded(
            child: Container(),
          ),
          FlatButton(
            child: Text("START", style: TextStyle(color: Colors.green),),
            onPressed: () {
              f.onTap(context);
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Training Stats"),
      ),
      drawer: MyDrawer(),
      body: GridView.count(
        padding: EdgeInsets.all(5.0),
        crossAxisCount: 2,
        shrinkWrap: true,
        children: functionalities.map<Widget>((f) => _functionalityCard(context, f)).toList()
      ),
    );
  }

}