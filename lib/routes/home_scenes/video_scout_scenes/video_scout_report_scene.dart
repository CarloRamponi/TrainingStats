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

import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:training_stats/datatypes/action.dart' as TSA;
import 'package:training_stats/datatypes/evaluation.dart';
import 'package:training_stats/datatypes/player.dart';
import 'package:training_stats/datatypes/record.dart';
import 'package:training_stats/datatypes/training.dart';
import 'package:training_stats/routes/home_scenes/video_scout_scenes/export_videos_scene.dart';
import 'package:training_stats/utils/functions.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as p;

class VideoScoutReportScene extends StatefulWidget {

  final Training training;

  VideoScoutReportScene({this.training});

  @override _VideoScoutReportSceneState createState() => _VideoScoutReportSceneState();
}

enum Options {
  export,
  filter
}

enum OrderByWhat {
  Time,
  Player,
  Action,
  Evaluation
}

extension OrderByWhatName on OrderByWhat {
  String name() => this.toString().split(".").last;
}

enum OrderByOrder {
  Ascending,
  Descending
}

extension OrderByOrderName on OrderByOrder {
  String name() => this.toString().split(".").last;
}

class _VideoScoutReportSceneState extends State<VideoScoutReportScene> {


  String path;
  double height, width, aspectRatio;

  bool _initialized = false;
  bool _changingVideo = false;
  Duration _currentPosition = Duration.zero;

  Record _currentRecord;

  List<Record> filteredRecords;
  VideoPlayerController _controller;

  bool _playing = false;
  bool _looping = false;

  bool _buttonsVisible = true;
  Timer _buttonsTimer;

  bool _playlistOpen = false;


  Map<Player, bool> playersSelected;
  Map<TSA.Action, bool> actionsSelected;
  Map<int, bool> evaluationsSelected;

  OrderByWhat orderByWhat = OrderByWhat.Time;
  OrderByOrder orderByOrder = OrderByOrder.Ascending;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {

    Training.getVideoDirectoryPath(widget.training.id).then((value) {
      path = value;
      widget.training.loadRecords().then((value) {

        playersSelected = Map.fromEntries(widget.training.players.map((e) => MapEntry(e, true)));
        actionsSelected = Map.fromEntries(widget.training.actions.map((e) => MapEntry(e, true)));
        evaluationsSelected = Map.fromEntries([-3, -2, -1, 1, 2, 3].map((e) => MapEntry(e, true)));

        filteredRecords = widget.training.records;

        _currentRecord = filteredRecords.first;

        initController(_currentRecord).then((_) {
          setState(() {

            Size size = MediaQuery.of(context).size;
            aspectRatio = _controller.value.aspectRatio;

            //I want the video to cover all the available space
            if(size.height*aspectRatio < size.width) {
              width = size.width;
              height = width / aspectRatio;
            } else {
              height = size.height;
              width = height * aspectRatio;
            }

            _initialized = true;
          });
        });
      });
    });
    super.initState();
  }

  Future<void> initController(Record record) async {
    setState(() {
      _changingVideo = true;
    });

    try {
      var tmp = VideoPlayerController.file(
          File(p.join(path, record.id.toString() + ".mp4")));
      await tmp.initialize();
      tmp.addListener(_controllerListener);
      tmp.setVolume(0.0);

      _currentRecord = record;
      var old = _controller;
      _controller = tmp;

      old?.dispose();
    } catch (e) {
      print(e.toString());
      return initController(record);
    }

    setState(() {
      _changingVideo = false;
    });
  }

  void _controllerListener() {
    //check if we reached the end of the video
    if(_currentPosition != null && _controller != null && _currentPosition >= _controller.value.duration) {
      setState(() {
        _currentPosition = Duration.zero;
        if(!_looping) {
          _playing = false;
          _controller.pause();
        }
        _controller.seekTo(Duration.zero);
      });
    }
    setState(() {});
  }

  Future<void> _refreshFilters() async {
    filteredRecords = widget.training.records.where((record) => playersSelected[record.player] && actionsSelected[record.action] && evaluationsSelected[record.evaluation]).toList();
  }

  Future<void> _refreshOrder() async {
    switch(orderByWhat) {
      case OrderByWhat.Time:
        switch(orderByOrder) {
          case OrderByOrder.Ascending:
            filteredRecords.sort((r1, r2) => r1.timestamp.millisecondsSinceEpoch - r2.timestamp.millisecondsSinceEpoch);
            break;
          case OrderByOrder.Descending:
            filteredRecords.sort((r1, r2) => r2.timestamp.millisecondsSinceEpoch - r1.timestamp.millisecondsSinceEpoch);
            break;
        }
        break;
      case OrderByWhat.Player:
        switch(orderByOrder) {
          case OrderByOrder.Ascending:
            filteredRecords.sort((r1, r2) => r1.player.name.compareTo(r2.player.name));
            break;
          case OrderByOrder.Descending:
            filteredRecords.sort((r1, r2) => r2.player.name.compareTo(r1.player.name));
            break;
        }
        break;
      case OrderByWhat.Action:
        switch(orderByOrder) {
          case OrderByOrder.Ascending:
            filteredRecords.sort((r1, r2) => r1.action.name.compareTo(r2.action.name));
            break;
          case OrderByOrder.Descending:
            filteredRecords.sort((r1, r2) => r2.action.name.compareTo(r1.action.name));
            break;
        }
        break;
      case OrderByWhat.Evaluation:
        switch(orderByOrder) {
          case OrderByOrder.Ascending:
            filteredRecords.sort((r1, r2) => r1.evaluation - r2.evaluation);
            break;
          case OrderByOrder.Descending:
            filteredRecords.sort((r1, r2) => r2.evaluation - r1.evaluation);
            break;
        }
        break;
    }

    if(!filteredRecords.contains(_currentRecord) && filteredRecords.isNotEmpty) {
      await initController(filteredRecords.first);

    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _resetButtonsTimer() {
    _buttonsTimer?.cancel();
    _buttonsTimer = Timer(Duration(seconds: 3), () {
      setState(() {
        _buttonsVisible = false;
      });
    });
  }

  void _changeVideo(int value) async {
    if(filteredRecords.length > 0) {
      await initController(filteredRecords[(max(
          filteredRecords.indexOf(_currentRecord) + value, 0)) %
          filteredRecords.length]);
      await _controller.play();
      setState(() {
        _playing = true;
      });
    }
  }

  void _openPlaylist() async {
    _playing = false;
    await _controller?.pause();
    setState(() {
      _playlistOpen = true;
    });
  }

//  void _onReorderPlaylist(int oldIndex, int newIndex) {
//    setState(() {
//      Record r = filteredRecords.removeAt(oldIndex);
//      filteredRecords.insert(newIndex - (newIndex > oldIndex ? 1 : 0), r);
//    });
//  }

  void _onRecordTapped(Record record) async {
    await initController(record);
    await _controller.play();
    setState(() {
      _playlistOpen = false;
      _playing = true;
    });
  }

  void _resetFilters() {
    playersSelected = Map.fromEntries(widget.training.players.map((e) => MapEntry(e, true)));
    actionsSelected = Map.fromEntries(widget.training.actions.map((e) => MapEntry(e, true)));
    evaluationsSelected = Map.fromEntries([-3, -2, -1, 1, 2, 3].map((e) => MapEntry(e, true)));
    orderByWhat = OrderByWhat.Time;
    orderByOrder = OrderByOrder.Ascending;
  }

  void _showExportDialog() async {
    List<Record> exportingRecords = await Navigator.push(context, MaterialPageRoute<List<Record>>(builder: (context) => ExportVideosScene(records: filteredRecords, trainingId: widget.training.id,)));
    if(exportingRecords != null) {
      String filePath = await loadingPopupWithProgress<String>(context, (onProgress) => exportClips(widget.training.id, exportingRecords, onProgress), "Generating video...\nCould take some time");
      if(filePath != null) {
        FlutterShare.shareFile(title: "video.mp4", filePath: filePath);
      } else {
        _scaffoldKey.currentState.removeCurrentSnackBar();
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Unable to generate video..."),));
      }
    }
  }

  void _showFilterDialog() async {
    await showDialog(context: context, builder: (context) {
      return StatefulBuilder(
        builder: (builder, setDialogState) => AlertDialog(
          actions: [
            FlatButton(
              child: Text("Reset"),
              onPressed: () {
                setState(() {
                  _resetFilters();
                });
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Apply"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
          content: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Filter records",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Players"),
                    trailing: Text(
                      playersSelected.values.any((element) => element == false) ? "some selected" : "all",
                      style: Theme.of(context).textTheme.caption,
                    ),
                    onTap: () {
                      showDialog(context: context, builder: (context) => StatefulBuilder(
                        builder: (context, setDialogDialogState) => AlertDialog(
                          content: SingleChildScrollView(
                            child: Column(
                              children:  widget.training.players.map((player) => CheckboxListTile(
                                value: playersSelected[player],
                                onChanged: (value) {
                                  setDialogDialogState(() {
                                    playersSelected[player] = value;
                                    //check whether at least one item is selected
                                    if(!playersSelected.values.any((element) => element == true)) {
                                      playersSelected[player] = true;
                                    }
                                  });
                                  setDialogState(() {});
                                  setState(() {});
                                },
                                title: Text(player.name),
                              )).toList(),
                            ),
                          ),
                          actions: [
                            FlatButton(
                                child: Text("Reset"),
                                onPressed: () {
                                  setDialogState(() {
                                    playersSelected = Map.fromEntries(widget.training.players.map((e) => MapEntry(e, true)));
                                  });
                                  Navigator.of(context).pop();
                                }
                            ),
                            FlatButton(
                              child: Text("Apply"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }
                            )
                          ],
                        ),
                      ));
                    },
                  ),
                  ListTile(
                    title: Text("Actions"),
                    trailing: Text(
                      actionsSelected.values.any((element) => element == false) ? "some selected" : "all",
                      style: Theme.of(context).textTheme.caption,
                    ),
                    onTap: () {
                      showDialog(context: context, builder: (context) => StatefulBuilder(
                        builder: (context, setDialogDialogState) => AlertDialog(
                          content: SingleChildScrollView(
                            child: Column(
                              children:  widget.training.actions.map((action) => CheckboxListTile(
                                value: actionsSelected[action],
                                onChanged: (value) {
                                  setDialogDialogState(() {
                                    actionsSelected[action] = value;
                                    //check whether at least one item is selected
                                    if(!actionsSelected.values.any((element) => element == true)) {
                                      actionsSelected[action] = true;
                                    }
                                  });
                                  setDialogState(() {});
                                  setState(() {});
                                },
                                title: Text(action.name),
                              )).toList(),
                            ),
                          ),
                          actions: [
                            FlatButton(
                                child: Text("Reset"),
                                onPressed: () {
                                  setDialogState(() {
                                    actionsSelected = Map.fromEntries(widget.training.actions.map((e) => MapEntry(e, true)));
                                  });
                                  Navigator.of(context).pop();
                                }
                            ),
                            FlatButton(
                                child: Text("Apply"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }
                            )
                          ],
                        ),
                      ));
                    },
                  ),
                  ListTile(
                    title: Text("Evaluations"),
                    trailing: Text(
                      evaluationsSelected.values.any((element) => element == false) ? "some selected" : "all",
                      style: Theme.of(context).textTheme.caption,
                    ),
                    onTap: () {
                      showDialog(context: context, builder: (context) => StatefulBuilder(
                        builder: (context, setDialogDialogState) => AlertDialog(
                          content: SingleChildScrollView(
                            child: FutureBuilder(
                              future: EvaluationProvider.getAll(),
                              builder: (context, snap) => snap.hasData ? Column(
                                children:  [3, 2, 1, -1, -2, -3].map((eval) => CheckboxListTile(
                                  value: evaluationsSelected[eval],
                                  onChanged: (value) {
                                    setDialogDialogState(() {
                                      evaluationsSelected[eval] = value;
                                      //check whether at least one item is selected
                                      if(!evaluationsSelected.values.any((element) => element == true)) {
                                        evaluationsSelected[eval] = true;
                                      }
                                    });
                                    setDialogState(() {});
                                    setState(() {});
                                  },
                                  secondary: CircleAvatar(
                                    backgroundColor: Evaluation.getColor(eval),
                                  ),
                                  title: Text(snap.data[eval]),
                                )).toList(),
                              ) : Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          ),
                          actions: [
                            FlatButton(
                                child: Text("Reset"),
                                onPressed: () {
                                  setDialogState(() {
                                    evaluationsSelected = Map.fromEntries([-3, -2, -1, 1, 2, 3].map((e) => MapEntry(e, true)));
                                  });
                                  Navigator.of(context).pop();
                                }
                            ),
                            FlatButton(
                                child: Text("Apply"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }
                            )
                          ],
                        ),
                      ));
                    },
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Order by"),
                    trailing: DropdownButton<OrderByWhat>(
                      value: orderByWhat,
                      onChanged: (value) {
                        setDialogState(() {
                          orderByWhat = value;
                        });
                      },
                      items: OrderByWhat.values.map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e.name(),
                          style: Theme.of(context).textTheme.caption,
                        ),
                      )).toList(),
                    ),
                  ),
                  ListTile(
                    title: Text("Order"),
                    trailing: DropdownButton<OrderByOrder>(
                      value: orderByOrder,
                      onChanged: (value) {
                        setDialogState(() {
                          orderByOrder = value;
                        });
                      },
                      items: OrderByOrder.values.map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e.name(),
                          style: Theme.of(context).textTheme.caption,
                        ),
                      )).toList(),
                    ),
                  )
                ],
              ),
            )
          )
        ),
      );
    });
    await _refreshFilters();
    await _refreshOrder();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(_playlistOpen) {

          if(filteredRecords.length > 0) {
            setState(() {
              _playlistOpen = false;
            });
          } else {
            _scaffoldKey.currentState.removeCurrentSnackBar();
            _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("There should be something in the playlist!"), duration: Duration(seconds: 3),));
          }

          return false;
        }

        return true;
      },
      child: Scaffold(
        body: Builder(
          builder: (context) {
            if(_initialized) {
              return GestureDetector(
                onTap: () {
                  if(_buttonsVisible) {
                    _buttonsTimer?.cancel();
                    setState(() {
                      _buttonsVisible = false;
                    });
                  } else {
                    setState(() {
                      _buttonsVisible = true;
                    });
                    _resetButtonsTimer();
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.hardEdge,
                  fit: StackFit.passthrough,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: _changingVideo ? Center(
                        child: CircularProgressIndicator(),
                      ) : Container(
                        width: width,
                        height: height,
                        child: AspectRatio(
                          aspectRatio: aspectRatio,
                          child: _controller != null ? VideoPlayer(_controller) : Text("No record provided."),
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                        duration: Duration(milliseconds: 200),
                        bottom: _buttonsVisible ? 20.0 : -100.0,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if(!_changingVideo && _controller != null)
                                FutureBuilder(
                                  future: _controller.position,
                                  builder: (BuildContext context, AsyncSnapshot<Duration> durationSnap) {
                                    if(durationSnap.hasData) {
                                      _currentPosition = durationSnap.data;
                                      return Slider(
                                        min: 0.0,
                                        max: _controller.value.duration.inMilliseconds.toDouble(),
                                        value: max(0.0, min(durationSnap.data.inMilliseconds.toDouble(), _controller.value.duration.inMilliseconds.toDouble())),
                                        onChanged: (val) async {
                                          _resetButtonsTimer();
                                          await _controller.pause();
                                          await _controller.seekTo(Duration(milliseconds: val.toInt()));
                                          setState(() {});
                                        },
                                        onChangeEnd: (val) async {
                                          if(_playing)
                                            await _controller.play();
                                        },
                                      );
                                    } else {
                                      return Container();
                                    }
                                  },
                                ),
                              Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: RaisedButton(
                                        padding: EdgeInsets.zero,
                                        clipBehavior: Clip.hardEdge,
                                        color: Colors.black38.withOpacity(0.8),
                                        shape: CircleBorder(),
                                        child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(10.0),
                                              child: Icon(
                                                Icons.loop,
                                                color: _looping ? Theme.of(context).primaryColor : Colors.white,
                                                size: 20.0,
                                              ),
                                            )
                                        ),
                                        onPressed: () {
                                          _resetButtonsTimer();
                                          setState(() {
                                            _looping = !_looping;
                                          });
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: RaisedButton(
                                        padding: EdgeInsets.zero,
                                        clipBehavior: Clip.hardEdge,
                                        color: Colors.black38.withOpacity(0.8),
                                        shape: CircleBorder(),
                                        child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(10.0),
                                              child: Icon(
                                                Icons.arrow_back,
                                                color: Colors.white,
                                                size: 20.0,
                                              ),
                                            )
                                        ),
                                        onPressed: () {
                                          _resetButtonsTimer();
                                          _changeVideo(-1);
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: RaisedButton(
                                        padding: EdgeInsets.zero,
                                        clipBehavior: Clip.hardEdge,
                                        color: Colors.black38.withOpacity(0.8),
                                        shape: CircleBorder(),
                                        child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(10.0),
                                              child: Icon(
                                                _playing ? Icons.pause : Icons.play_arrow,
                                                color: Colors.white,
                                                size: 30.0,
                                              ),
                                            )
                                        ),
                                        onPressed: () {
                                          _resetButtonsTimer();

                                          if(_playing)
                                            _controller.pause();
                                          else
                                            _controller.play();

                                          setState(() {
                                            _playing = !_playing;
                                          });
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: RaisedButton(
                                        padding: EdgeInsets.zero,
                                        clipBehavior: Clip.hardEdge,
                                        color: Colors.black38.withOpacity(0.8),
                                        shape: CircleBorder(),
                                        child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(10.0),
                                              child: Icon(
                                                Icons.arrow_forward,
                                                color: Colors.white,
                                                size: 20.0,
                                              ),
                                            )
                                        ),
                                        onPressed: () {
                                          _resetButtonsTimer();
                                          _changeVideo(1);
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: RaisedButton(
                                        padding: EdgeInsets.zero,
                                        clipBehavior: Clip.hardEdge,
                                        color: Colors.black38.withOpacity(0.8),
                                        shape: CircleBorder(),
                                        child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(10.0),
                                              child: Icon(
                                                Icons.list,
                                                color: Colors.white,
                                                size: 20.0,
                                              ),
                                            )
                                        ),
                                        onPressed: () {
                                          _resetButtonsTimer();
                                          _openPlaylist();
                                        },
                                      ),
                                    ),
                                  ]
                              ),
                            ],
                          ),
                        )
                    ),
                    AnimatedPositioned(
                        duration: Duration(milliseconds: 200),
                        left: 0.0,
                        top: _buttonsVisible ? 0.0 : -100.0,
                        child: Container(
                          padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
                          decoration: BoxDecoration(
                              color: Colors.black38.withOpacity(0.6)
                          ),
                          width: MediaQuery.of(context).size.width,
                          child: _currentRecord != null ? Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left:20.0),
                                child: Container(
                                  height: 30.0,
                                  width: 30.0,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Evaluation.getColor(_currentRecord.evaluation)
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left:20.0),
                                child: Text(
                                  "${_currentRecord.player.name}, ${_currentRecord.action.name}",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.0
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 10.0),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              )
                            ],
                          ) : Container(),
                        )
                    ),
                    AnimatedPositioned(
                      top: _playlistOpen ? 0.0 : MediaQuery.of(context).size.height,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.ease,
                      child: Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.white,
                          child: Scaffold(
                            key: _scaffoldKey,
                            appBar: AppBar(
                              title: Text("Playlist"),
                              actions: [
                                IconButton(
                                  icon: Icon(
                                    Icons.filter_list,
                                    color: Colors.white,
                                  ),
                                  onPressed: _showFilterDialog,
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.share,
                                    color: Colors.white,
                                  ),
                                  onPressed: _showExportDialog,
                                )
                              ],
                            ),
                            body: filteredRecords.isEmpty ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("You should rethink you choices..."),
                                  FlatButton(
                                    child: Text("Reset filters"),
                                    onPressed: () async {
                                      _resetFilters();
                                      await _refreshFilters();
                                      await _refreshOrder();
                                      setState(() {});
                                    },
                                  )
                                ],
                              ),
                            ) : ListView(
//                              onReorder: _onReorderPlaylist,
                              children: filteredRecords.map((record) => ListTile(
                                key: ValueKey(record.id),
                                leading: Builder(
                                    key: ValueKey(record.id),
                                    builder: (context) => _initialized? CircleAvatar(
                                        backgroundColor: Colors.transparent,
                                        backgroundImage: FileImage(File(p.join(path, "thumbnail_" + record.id.toString() + ".jpg")))
                                    ) : CircleAvatar(
                                      backgroundColor: Colors.grey.withOpacity(0.2),
                                      foregroundColor: Theme.of(context).primaryColor,
                                      child: Center(
                                        child: Icon(Icons.image),
                                      ),
                                    )
                                ),
                                title: Text(record.player.name),
                                subtitle: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 10.0),
                                      child: Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Evaluation.getColor(record.evaluation)
                                        ),
                                      ),
                                    ),
                                    Text(record.action.name)
                                  ],
                                ),
                                selected: _currentRecord == record,
                                onTap: () {
                                  _onRecordTapped(record);
                                },
                              )).toList(),
                            ),
                          )
                      ),
                    )
                  ],
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

}
