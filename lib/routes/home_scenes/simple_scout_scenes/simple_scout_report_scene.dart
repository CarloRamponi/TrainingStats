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

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:random_string/random_string.dart';
import 'package:training_stats/datatypes/evaluation.dart';
import 'package:training_stats/datatypes/statistics.dart';
import 'package:training_stats/datatypes/training.dart';
import 'package:training_stats/routes/home_scenes/simple_scout_scenes/charts/classics.dart';
import 'package:training_stats/routes/home_scenes/simple_scout_scenes/charts/exportable_chart_state.dart';
import 'package:training_stats/routes/home_scenes/simple_scout_scenes/charts/touches_average.dart';
import 'package:path/path.dart' as path;
import 'package:pdf/widgets.dart' as pw;
import 'package:training_stats/routes/home_scenes/video_scout_scenes/video_scout_report_scene.dart';
import 'package:training_stats/utils/functions.dart';

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

  Statistics statistics;
  GlobalKey<ExportableChartState> _classicChart = GlobalKey();
  GlobalKey<ExportableChartState> _avgChart = GlobalKey();

  @override
  void initState() {
    loadingRecords = widget.training.loadRecords()..then((value) => statistics = Statistics(widget.training));
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
          actions: widget.training.actions,
          video: widget.training.video
        );

        if(t.video) {
          Navigator.of(context).pushReplacementNamed("/video_scout/scout", arguments: t);
        } else {
          Navigator.of(context).pushReplacementNamed("/simple_scout/scout", arguments: t);
        }

        break;
      case ReportAction.delete:

        if(await _confirmDelete()) {
          await TrainingProvider.delete(widget.training.id);
          Navigator.of(context).pop();
        }

        break;
      case ReportAction.export:
        _showExportPopUp();
        break;
    }
  }

  void _exportPdf() async {

    ExportedChart classicChart = await loadingPopup(context, _classicChart.currentState.getImage());
    ExportedChart avgChart = await loadingPopup(context, _avgChart.currentState.getImage());

    String filePath = path.join((await getTemporaryDirectory()).path, randomString(10, from: 62, to: 86) + ".pdf");
    File(filePath).writeAsBytesSync((await loadingPopup(context, statistics.generateReport([classicChart, avgChart]))).toList());

    FlutterShare.shareFile(title: "Simple scout report.pdf", filePath: filePath);

  }

  void _exportCsv() async {

    Map<int, String> evalLabels = await EvaluationProvider.getAll();

    List<List<dynamic>> list = [<dynamic>["Player", "Player name", "action", "evaluation value", "evaluation label", "timestamp"]] + statistics.training.records.map<List<dynamic>>((record) => ["${record.player.shortName}", "${record.player.name}", "${record.action.name}", record.evaluation, evalLabels[record.evaluation], record.timestamp.toIso8601String()]).toList();
    String csv = ListToCsvConverter().convert(list);
    String filePath = path.join((await getTemporaryDirectory()).path, randomString(10, from: 62, to: 86) + ".csv");
    File(filePath).writeAsStringSync(csv);
    FlutterShare.shareFile(title: "training_${statistics.training.team.teamName}_${statistics.training.ts_start.toIso8601String()}.csv", filePath: filePath);

  }

  void _showExportPopUp() {
    showDialog(context: context, builder: (context) => SimpleDialog(
      children: [
        ListTile(
          leading: Icon(Icons.picture_as_pdf),
          title: Text("Export as pdf"),
          onTap: () {
            Navigator.of(context).pop();
            _exportPdf();
          },
        ),
        ListTile(
          leading: Icon(Icons.poll),
          title: Text("Export as csv"),
          onTap: () {
            Navigator.of(context).pop();
            _exportCsv();
          },
        )
      ],
    ));
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
        builder: (context, snap) => snap.hasData ? snap.data == true ? SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(widget.training.video)
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text("This is a video training"),
                          ),
                          RaisedButton(
                            child: Text(
                              "View clips",
                              style: TextStyle(
                                color: Colors.white
                              ),
                            ),
                            color: Colors.green,
                            onPressed: () {
                              Navigator.of(context).pushNamed("/video_scout/report", arguments: widget.training);
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "Classical statistics",
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              ClassicCharts(
                key: _classicChart,
                statistics: statistics,
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
                key: _avgChart,
                statistics: statistics,
              )
            ]
          ),
        ) : Center(
          child: Text("There was an error while loading training records."),
        ) : Center(
          child: CircularProgressIndicator(),
        ),
      )
    );
  }

}
