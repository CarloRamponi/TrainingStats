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

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:training_stats/datatypes/board_type.dart';
import 'package:training_stats/datatypes/player.dart';
import 'package:training_stats/datatypes/record.dart';
import 'package:training_stats/datatypes/training.dart';
import 'package:training_stats/utils/functions.dart';
import 'package:training_stats/widgets/blinker.dart';
import 'package:training_stats/widgets/evaluation_board.dart';
import 'package:training_stats/widgets/evaluation_history_board.dart';
import 'package:training_stats/widgets/grid_segmented_control.dart';
import '../../../main.dart';
import 'package:path/path.dart' as path;
import 'package:training_stats/datatypes/action.dart' as TSA;

class VideoScoutScene extends StatefulWidget{

  VideoScoutScene({
    Key key,
    this.training
  }) : super(key: key);

  final Training training;

  @override
  _VideoScoutSceneState createState() => _VideoScoutSceneState();
}

class _VideoScoutSceneState extends State<VideoScoutScene> {

  CameraController controller;
  bool initialized;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<EvaluationHistoryBoardState> evalHistoryKey = GlobalKey<EvaluationHistoryBoardState>();

  List<Record> records = [];
  Record currentRecord = Record();

  DateTime videoTsStart;

  Duration timer;
  Timer _timerObj;

  String filePath;

  bool videoPreviewFullScreen = false;
  double videoPreviewSize = 150.0;

  @override
  void initState() {

    initialized = false;
    timer = Duration.zero;

    controller = CameraController(cameras[0], ResolutionPreset.ultraHigh);
    controller.initialize().then((_) {
      getTemporaryDirectory().then((tmpDir) {

        filePath = path.join(tmpDir.path, "tmp_video.mp4");
        File file = File(filePath);
        if(file.existsSync()) {
          file.deleteSync();
        }

        controller.startVideoRecording(filePath).then((_) {

          videoTsStart = DateTime.now();

          _timerObj = Timer.periodic(Duration(seconds: 1), (_) {
            setState(() {
              timer += Duration(seconds: 1);
            });
          });

          setState(() {
            initialized = true;
          });

        }, onError: (e) {
          scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Error starting video!\n${e.toString()}"),));
        });
      });
    }, onError: (e) => print(e.toString()));
    super.initState();
  }

  @override
  void dispose() {
    _timerObj.cancel();
    controller?.dispose();
    super.dispose();
  }

  void _stop() async {

    Training training = widget.training;
    training.ts_end = DateTime.now();
    training.records = records;

    DateTime endTs = DateTime.now();
    await controller.stopVideoRecording();
    await controller.dispose();

    setState(() {
      _timerObj.cancel();
      controller= null;
    });

    if(records.length > 0) {

      training = await loadingPopup(context, TrainingProvider.create(training), "Creating training's report");
      bool result = await loadingPopupWithProgress<bool>(context, (onProgress) => createClips(filePath, videoTsStart, endTs, training, onProgress), "Creating clips");

      Navigator.pushReplacementNamed(context, '/simple_scout/report', arguments: training);
    } else {
      await loadingPopup(context, File(filePath).delete(), "Deleting video file");
      Navigator.of(context).pop();
    }

  }

  void onPlayerChanged(Player player) {
    setState(() {
      if(player == currentRecord.player)
        currentRecord.player = null;
      else
        currentRecord.player = player;
    });
  }

  void onActionChanged(TSA.Action action) {
    setState(() {
      if(action == currentRecord.action)
        currentRecord.action = null;
      else
        currentRecord.action = action;
    });
  }

  bool onEvaluationChanged(int eval) {

    if(currentRecord.player != null && currentRecord.action != null) {

      setState(() {

        records.add(Record(
            player: currentRecord.player,
            action: currentRecord.action,
            evaluation: eval
        ));

        evalHistoryKey.currentState.addRecord(records.last);

      });

      return true;
    } else {
      scaffoldKey.currentState.removeCurrentSnackBar();
      scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("You should select the player and the action first."), duration: Duration(milliseconds: 700),));
      return false;
    }
  }

  bool undoBtnEnabled() {
    return records.length > 0;
  }

  void undo() {
    setState(() {
      records.removeLast();
      evalHistoryKey.currentState.removeLastRecord();
    });
  }

  Future<bool> _confirmExit() async {
    var result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Confirm exit"),
          content: Text("Are you sure you want to exit?\nThis training will be discarded and you won't be able to recover it."),
          actions: [
            FlatButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            FlatButton(
              child: Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            )
          ],
        ));

    return result == true;
  }

  Future<bool> _confirmStop() async {
    var result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Confirm stop"),
          content: Text("Are you sure you want to stop this training?"),
          actions: [
            FlatButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            FlatButton(
              child: Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            )
          ],
        ));

    return result == true;
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: videoPreviewFullScreen ? () async {
        setState(() {
          videoPreviewFullScreen = false;
        });
        return false;
      } : _confirmExit,
      child: Scaffold(
          key: scaffoldKey,
          body: Stack(
            children: <Widget>[
              SafeArea(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 60.0,
                      child: Stack(
                        fit: StackFit.expand,
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Video Scout",
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                                Text(
                                  "${timer.inMinutes.toString().padLeft(2, '0')}:${(timer.inSeconds % 60).toString().padLeft(2, '0')}",
                                  style: Theme.of(context).textTheme.caption,
                                )
                              ],
                            ),
                          ),
                          Positioned(
                            right: 0.0,
                            child: FlatButton(
                              padding: EdgeInsets.zero,
                              child: Text("Stop"),
                              onPressed: () async {
                                if(await _confirmStop()) {
                                  _stop();
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    Divider(
                      height: 0.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                      child: Column(
                        children: [
                          GridSegmentedControl<Player>(
                            title: "Player",
                            rowCount: 6,
                            elements: widget.training.players.map((value) => GridSegmentedControlElement(value: value, name: value.shortName, color: value.role.color, tooltip: value.name)).toList(),
                            onPressed: (player) => onPlayerChanged(player),
                            selected: currentRecord.player,
                          ),
                          GridSegmentedControl<TSA.Action>(
                            title: "Action",
                            rowCount: max(min(6, widget.training.actions.length), 4),
                            elements: widget.training.actions.map((value) => GridSegmentedControlElement(value: value, name: value.shortName, color: value.color, tooltip: value.name)).toList(),
                            onPressed: onActionChanged,
                            selected: currentRecord.action,
                          ),
                          FutureBuilder(
                            future: BoardTypeProvider.get(),
                            builder: (context, AsyncSnapshot<BoardType> boardType) => FutureBuilder(
                              future: BoardTypeProvider.showLabels(),
                              builder: (_, AsyncSnapshot<bool> showLabels) => boardType.hasData ? EvaluationBoard(
                                boardType: boardType.data,
                                showLabels: showLabels.hasData ? showLabels.data : false,
                                onPressed: onEvaluationChanged,
                              ) : LinearProgressIndicator(),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: EvaluationHistoryBoard(
                    key: evalHistoryKey,
                  ),
                )
              ),
              Positioned(
                bottom: 5.0,
                right: 8.0,
                child: IconButton(
                  icon: Icon(
                    Icons.backspace,
                    color: Colors.grey,
                    size: 25.0,
                  ),
                  onPressed: undoBtnEnabled() ? () { undo(); } : null,
                ),
              ),
              if(controller != null)
                Align(
                  alignment: Alignment.bottomLeft,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        videoPreviewFullScreen = !videoPreviewFullScreen;
                      });
                    },
                    child: AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        height: videoPreviewFullScreen ? MediaQuery.of(context).size.height : videoPreviewSize,
                        child: initialized ? Stack(
                          fit: StackFit.loose,
                          clipBehavior: Clip.none,
                          children: [
                            Container(
//                              decoration: BoxDecoration(
//                                borderRadius: BorderRadius.only(topRight: Radius.circular(videoPreviewFullScreen ? 0.0 : 5.0))
//                              ),
//                              clipBehavior: Clip.hardEdge,
                              child: AspectRatio(
                                aspectRatio: controller.value.aspectRatio,
                                child: CameraPreview(controller),
                              )
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Blinker(
                                  interval: Duration(seconds: 1),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 10.0,
                                        width: 10.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 5.0),
                                        child: Text("REC"),
                                      )
                                    ],
                                  ),
                                )
                              ),
                            ),
                            if(!videoPreviewFullScreen)
                              Positioned(
                                bottom: videoPreviewSize - 25.0,
                                left: videoPreviewSize * controller.value.aspectRatio - 25.0,
                                child: GestureDetector(
                                  child: Card(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(Icons.call_made),
                                    ),
                                    color: Colors.white,
                                    shape: CircleBorder(),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      videoPreviewFullScreen = !videoPreviewFullScreen;
                                    });
                                  },
                                  onPanUpdate: (details) {
                                    setState(() {
                                      videoPreviewSize = min(max(videoPreviewSize - details.delta.dy, 100.0), MediaQuery.of(context).size.height - 100.0);
                                    });
                                  },
                                ),
                              )
                          ],
                        ) : Center(
                          child: CircularProgressIndicator(),
                        )
                    ),
                  )
                )
            ],
          )
      ),
    );
  }

}

