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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';
import 'package:training_stats/datatypes/evaluation.dart';
import 'package:training_stats/datatypes/record.dart';
import 'package:training_stats/datatypes/training.dart';
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

class _VideoScoutReportSceneState extends State<VideoScoutReportScene> {

  List<VideoPlayerController> _controllers;
  Future<void> _initializeVideoPlayer;
  Future<void> _documentsDirectoryFtr;
  String path;
  int _currentVideo;
  bool _initialized = false;

  bool _playing = false;

  bool _buttonsVisible = true;
  Timer _buttonsTimer;

  @override
  void initState() {
    _currentVideo = 0;
    _documentsDirectoryFtr = getApplicationDocumentsDirectory()..then((value) {
      path = p.join(value.path, "video_scout", widget.training.id.toString());
      widget.training.loadRecords().then((value) {
        _controllers = widget.training.records.map((r) => VideoPlayerController.file(File(p.join(path, r.id.toString() + ".mp4")))).toList();
        _initializeVideoPlayer = Future.wait(_controllers.map((controller) => controller.initialize()).toList())..then((value) {

          //add listeners
          _controllers.forEach((element) {
            element.addListener(_controllerListener);
          });

          //notify that controllers are ready
          setState(() {
            _initialized = true;
          });

        });
      });
    });
    super.initState();
  }

  void _controllerListener() {
//    //check if we reached the end of the video
//    if((await _controllers[_currentVideo].position).inMilliseconds >= _controllers[_currentVideo].value.duration.inMilliseconds) {
//      await _controllers[_currentVideo].pause();
//    }
    setState(() {});
  }

  @override
  void dispose() {
    for(VideoPlayerController _controller in _controllers)
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

  void _onOptionSelected(Options option) async {
    switch(option) {
      case Options.export:
        // TODO: Handle this case.
        break;
      case Options.filter:
        // TODO: Handle this case.
        break;
    }
  }

  void _changeVideo(int value) async {
    _controllers[_currentVideo].pause();
    _currentVideo = (_currentVideo + value) % widget.training.records.length;
    await _controllers[_currentVideo].seekTo(Duration.zero);
    if(_playing)
      await _controllers[_currentVideo].play();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    child: Builder(
                      builder: (context) {

                        Size size = MediaQuery.of(context).size;
                        double ratio = _controllers[_currentVideo].value.aspectRatio;

                        double width, height;

                        //I want the video to cover all the available space
                        if(size.height*ratio < size.width) {
                          width = size.width;
                          height = width / ratio;
                        } else {
                          height = size.height;
                          width = height * ratio;
                        }

                        return Container(
                          width: width,
                          height: height,
                          child: AspectRatio(
                            aspectRatio: _controllers[_currentVideo].value.aspectRatio,
                            child: VideoPlayer(_controllers[_currentVideo]),
                          ),
                        );
                      },
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
                          FutureBuilder(
                            future: _controllers[_currentVideo].position,
                            builder: (BuildContext context, AsyncSnapshot<Duration> durationSnap) {
                              if(durationSnap.hasData) {

                                if(durationSnap.data >= _controllers[_currentVideo].value.duration) {
                                  _playing = false;
                                }

                                return Slider(
                                  min: 0.0,
                                  max: _controllers[_currentVideo].value.duration.inMilliseconds.toDouble(),
                                  value: min(durationSnap.data.inMilliseconds.toDouble(), _controllers[_currentVideo].value.duration.inMilliseconds.toDouble()),
                                  onChanged: (val) async {
                                    _resetButtonsTimer();
                                    await _controllers[_currentVideo].pause();
                                    await _controllers[_currentVideo].seekTo(Duration(milliseconds: val.toInt()));
                                    setState(() {});
                                  },
                                  onChangeEnd: (val) async {
                                    if(_playing)
                                      await _controllers[_currentVideo].play();
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FlatButton(
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
                                FlatButton(
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
                                      _controllers[_currentVideo].pause();
                                    else
                                      _controllers[_currentVideo].play();

                                    setState(() {
                                      _playing = !_playing;
                                    });
                                  },
                                ),
                                FlatButton(
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
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left:20.0),
                            child: Container(
                              height: 30.0,
                              width: 30.0,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Evaluation.getColor(widget.training.records[_currentVideo].evaluation)
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left:20.0),
                            child: Text(
                              "${widget.training.records[_currentVideo].player.name}, ${widget.training.records[_currentVideo].action.name}",
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
                            child: PopupMenuButton<Options>(
                              onSelected: _onOptionSelected,
                              icon: Icon(
                                Icons.more_vert,
                                color: Colors.white,
                              ),
                              itemBuilder: (context) => [
                                PopupMenuItem<Options>(
                                  value: Options.filter,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 10.0),
                                        child: Icon(Icons.filter_list),
                                      ),
                                      Text("Filter")
                                    ],
                                  ),
                                ),
                                PopupMenuItem<Options>(
                                  value: Options.export,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 10.0),
                                        child: Icon(Icons.share),
                                      ),
                                      Text("Share")
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    )
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
      )
    );
  }

}
