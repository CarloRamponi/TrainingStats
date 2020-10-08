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
import 'package:training_stats/routes/home_scenes/simple_scout_scenes/charts/efficiency.dart';
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
  delete_clips
}

class _SimpleScoutReportSceneState extends State<SimpleScoutReportScene> {

  Future<bool> loadingRecords;

  Statistics statistics;
  GlobalKey<ExportableChartState> _classicChart = GlobalKey();
  GlobalKey<ExportableChartState> _efficiencyChart = GlobalKey();
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

  Future<bool> _confirmDeleteClips() {
    return showDialog(context: context, builder: (context) => AlertDialog(
      title: Text("Are you sure?"),
      content: Text("This action cannot be undone.\nAll clips in this training session will be deleted from this device.\nYou may want to export them first!\nThe training will not be deleted."),
      actions: [
        FlatButton(
          child: Text("Cancel"),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        FlatButton(
          child: Text("Delete clips"),
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

      case ReportAction.delete_clips:
        if(widget.training.video) {

          if(await _confirmDeleteClips()) {
            Training t = await loadingPopup<Training>(context, TrainingProvider.removeVideo(widget.training));
            Navigator.of(context).pushReplacementNamed("/simple_scout/report", arguments: t);
          }

        }
        break;
    }
  }

  void _exportPdf() async {

    await loadingPopupWithProgress(context, (onProgress) async {

      ExportedChart efficiencyChart = await _efficiencyChart.currentState.getImage();
      onProgress(0.25);

      ExportedChart classicChart = await _classicChart.currentState.getImage();
      onProgress(0.50);

      ExportedChart avgChart = await _avgChart.currentState.getImage();
      onProgress(0.75);

      String filePath = path.join((await getTemporaryDirectory()).path, randomString(10, from: 62, to: 86) + ".pdf");
      File(filePath).writeAsBytesSync((await statistics.generateReport([efficiencyChart, classicChart, avgChart])).toList());
      onProgress(1.0);

      FlutterShare.shareFile(title: "Simple scout report.pdf", filePath: filePath);
    }, "Generating PDF report...");

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
              ),
              if(widget.training.video)
                PopupMenuItem<ReportAction>(
                  value: ReportAction.delete_clips,
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child: Icon(
                          Icons.videocam_off,
                          color: Colors.grey,
                        ),
                      ),
                      Text("Delete clips")
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
              EfficiencyChart(
                key: _efficiencyChart,
                statistics: statistics,
              ),
              Divider(),
              ClassicCharts(
                key: _classicChart,
                statistics: statistics,
              ),
              Divider(),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "Actions every N seconds",
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
