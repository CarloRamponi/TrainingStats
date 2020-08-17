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
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:training_stats/datatypes/action_data.dart';
import 'package:training_stats/datatypes/exercise_data.dart';
import 'package:training_stats/datatypes/player_data.dart';
import 'package:training_stats/datatypes/training_data.dart';
import 'package:training_stats/routes/collect_data_scene.dart';
import 'package:training_stats/routes/players_scenes/create_player_scene.dart';
import 'package:training_stats/routes/settings_pages/about_scene.dart';
import 'package:training_stats/routes/settings_pages/actions_scene.dart';
import 'package:training_stats/routes/settings_pages/evaluations_scene.dart';
import 'package:training_stats/routes/settings_pages/import_export_scene.dart';
import 'package:training_stats/routes/settings_pages/roles_scene.dart';
import 'package:training_stats/routes/teams_scenes/edit_team_scene.dart';
import 'package:training_stats/routes/players_scenes/players_scene.dart';
import 'package:training_stats/routes/teams_scenes/select_player_scene.dart';
import 'package:training_stats/routes/settings_pages/settings_scene.dart';
import 'package:training_stats/routes/teams_scenes/teams_scene.dart';
import 'package:training_stats/utils/palette.dart';
import 'package:training_stats/widgets/drawer.dart';

class RouteGenerator {

  static Route<dynamic> generateRoute(RouteSettings settings) {

    final args = settings.arguments;

    switch (settings.name) {

      case "/":

        return MaterialPageRoute(
          builder: (_) {
            return TeamsScene();
          });

        break;

      case "/teams":

        return MaterialPageRoute(
            builder: (_) {
              return TeamsScene();
            });

        break;

      case "/players":

        return MaterialPageRoute(
            builder: (_) {
              return PlayersScene();
            });

        break;

      case "/createPlayer":

        return MaterialPageRoute(
            builder: (_) {
              return CreatePlayerScene();
            });

        break;

      case "/editPlayer":

        return MaterialPageRoute(
            builder: (_) {
              return CreatePlayerScene(player: args,);
            });

        break;

      case "/editTeam" :

        return MaterialPageRoute(
          builder: (_) {
            return EditTeamScene(team: args);
          }
        );

        break;

      case "/editTeam/addPlayer":

        return MaterialPageRoute(
            builder: (_) {
              return SelectPlayerScene(team: args);
            }
        );

        break;

      case '/scout':

          return MaterialPageRoute(
          builder: (_) {
            return CollectDataScene(
              training: TrainingData(
                exercise: ExerciseData(
                    name: "Exercise 1"
                ),
                players: <PlayerData>[
                  PlayerData(fullName: "Carlo Ramponi", shortName: "CR"),
                  PlayerData(fullName: "Mario Rossi", shortName: "MR"),
                  PlayerData(fullName: "Luca Verdi", shortName: "LV"),
                  PlayerData(fullName: "Giorgio Bianchi", shortName: "GB"),
                  PlayerData(fullName: "Fabio Gialli", shortName: "FG"),
                  PlayerData(fullName: "Stefano Violi", shortName: "SV"),
                  PlayerData(fullName: "Oscar Marroni", shortName: "OM"),
                  PlayerData(fullName: "Massimo Neri", shortName: "MN"),
                ],
                actions: <ActionData>[
                  ActionData(fullName: "Ricezione", shortName: "R"),
                  ActionData(fullName: "Attacco", shortName: "A"),
                  ActionData(fullName: "Difesa", shortName: "D"),
                  ActionData(fullName: "Muro", shortName: "M"),
                  ActionData(fullName: "Copertura", shortName: "C"),
                  ActionData(fullName: "Palleggio", shortName: "P"),
                ]
              ),
            );
          }
        );

        break;

      case "/settings":

        return MaterialPageRoute(
            builder: (_) {
              return SettingsScene();
            }
        );

        break;

      case "/settings/about":

        return MaterialPageRoute(
            builder: (_) {
              return AboutScene();
            }
        );

        break;

      case "/settings/roles":

        return MaterialPageRoute(
            builder: (_) {
              return RolesScene();
            }
        );

        break;

      case "/settings/evaluations":

        return MaterialPageRoute(
            builder: (_) {
              return EvaluationsScene();
            }
        );

        break;

      case "/settings/actions":

        return MaterialPageRoute(
            builder: (_) {
              return ActionsScene();
            }
        );

        break;

      case "/settings/import_export":

        return MaterialPageRoute(
            builder: (_) {
              return ImportExportScene();
            }
        );

        break;

      default:
        return _errorRoute();
    }

  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          drawer: MyDrawer(),
          appBar: AppBar(
            title: Text('Error'),
          ),
          body: Container(
            padding: EdgeInsets.all(15.0),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    ":(",
                    style: TextStyle(
                        fontSize: 100
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 15.0),
                    child: Text(
                      "Something went terribly wrong. Please restart the application.",
                      style: TextStyle(
                          color: Palette.gray
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        );
      }
    );
  }

}