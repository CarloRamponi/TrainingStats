import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:training_stats/datatypes/action_data.dart';
import 'package:training_stats/datatypes/exercise_data.dart';
import 'package:training_stats/datatypes/player_data.dart';
import 'package:training_stats/datatypes/training_data.dart';
import 'package:training_stats/routes/about_scene.dart';
import 'package:training_stats/routes/collect_data_scene.dart';
import 'package:training_stats/routes/edit_team_scene.dart';
import 'package:training_stats/routes/players_scene.dart';
import 'package:training_stats/routes/select_player_scene.dart';
import 'package:training_stats/routes/settings_scene.dart';
import 'package:training_stats/routes/teams_scene.dart';
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

      case "/about":

        return MaterialPageRoute(
            builder: (_) {
              return AboutScene();
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