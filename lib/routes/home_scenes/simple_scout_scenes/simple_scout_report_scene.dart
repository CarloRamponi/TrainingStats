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
import 'package:training_stats/routes/home_scenes/simple_scout_scenes/charts/classics.dart';
import 'package:training_stats/routes/home_scenes/simple_scout_scenes/charts/touches_average.dart';

class SimpleScoutReportScene extends StatefulWidget{

  final Training training;

  SimpleScoutReportScene({
    @required this.training
  });

  @override
  _SimpleScoutReportSceneState createState() => _SimpleScoutReportSceneState();

}

enum ReportAction {
  clone,
  delete,
  export,
}

class _SimpleScoutReportSceneState extends State<SimpleScoutReportScene> {

  Future<bool> loadingRecords;

  @override
  void initState() {
    loadingRecords = widget.training.loadRecords();
    super.initState();
  }

  Future<bool> _confirmDelete() {
    return showDialog(context: context, builder: (context) => AlertDialog(
      title: Text("Are you sure?"),
      content: Text("This action cannot be undone.\nAll data from this training will be lost."),
      actions: [
        FlatButton(
          child: Text("Cancel"),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        FlatButton(
          child: Text("Delete"),
          onPressed: () => Navigator.of(context).pop(true),
        )
      ],
    ));
  }

  void _popUpMenuHandler(ReportAction action) async {
    switch(action) {

      case ReportAction.clone:

        Training t = Training(
          team: widget.training.team,
          players: widget.training.players,
          actions: widget.training.actions
        );

        Navigator.of(context).pushReplacementNamed("/simple_scout/scout", arguments: t);
        break;
      case ReportAction.delete:

        if(await _confirmDelete()) {
          await TrainingProvider.delete(widget.training.id);
          Navigator.of(context).pop();
        }

        break;
      case ReportAction.export:
        // TODO: Handle this case.
        break;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Report"),
        actions: [
          PopupMenuButton<ReportAction>(
            itemBuilder: (context) => [
              PopupMenuItem<ReportAction>(
                value: ReportAction.export,
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 10.0),
                      child: Icon(
                        Icons.exit_to_app,
                        color: Colors.grey,
                      ),
                    ),
                    Text("Export")
                  ],
                ),
              ),
              PopupMenuItem<ReportAction>(
                value: ReportAction.clone,
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 10.0),
                      child: Icon(
                        Icons.content_copy,
                        color: Colors.grey,
                      ),
                    ),
                    Text("Clone")
                  ],
                ),
              ),
              PopupMenuItem<ReportAction>(
                value: ReportAction.delete,
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 10.0),
                      child: Icon(
                        Icons.delete,
                        color: Colors.grey,
                      ),
                    ),
                    Text("Delete")
                  ],
                ),
              )
            ],
            onSelected: _popUpMenuHandler,
          )
        ],
      ),
      body: FutureBuilder(
        future: loadingRecords,
        builder: (context, snap) => snap.hasData ? snap.data == true ? ListView(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          children: [
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                "Classical statistics",
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            ClassicCharts(
              actions: widget.training.actions,
              players: widget.training.players,
              records: widget.training.records,
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                "Ball touches every N seconds",
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            TouchesAverage(
              actions: widget.training.actions,
              players: widget.training.players,
              records: widget.training.records,
            )
          ],
        ) : Center(
          child: Text("There was an error while loading training records."),
        ) : Center(
          child: CircularProgressIndicator(),
        ),
      )
    );
  }

}
