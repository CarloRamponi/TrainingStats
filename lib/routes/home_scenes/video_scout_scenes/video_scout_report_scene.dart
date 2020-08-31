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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:video_player/video_player.dart';

class VideoScoutReportScene extends StatefulWidget {

  final String path;
  final List<Duration> ts;

  VideoScoutReportScene({this.path, this.ts});

  @override _VideoScoutReportSceneState createState() => _VideoScoutReportSceneState();
}

class _VideoScoutReportSceneState extends State<VideoScoutReportScene> {

  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayer;
  FlutterFFmpeg _flutterFFmpeg;
  FlutterFFmpegConfig _flutterFFmpegConfig;

  @override
  void initState() {
    _controller = VideoPlayerController.file(File(widget.path));
    _initializeVideoPlayer = _controller.initialize();
    _controller.setLooping(true);
//    _flutterFFmpeg = new FlutterFFmpeg();
//    _flutterFFmpegConfig = new FlutterFFmpegConfig();
//    _flutterFFmpeg.execute("-i ${widget.path} -ss ${_printDuration(widget.ts.first - Duration(seconds: 3))} -to ${_printDuration(widget.ts.first + Duration(seconds: 2))} -c copy ${widget.path + "_cut.mp4"}").then((value) {
//      print("ffmped exited with ec $value");
//      _flutterFFmpegConfig.getLastCommandOutput().then((value) {
//        print("output:\n$value");
//      });
//    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 350.0,
              child: FutureBuilder(
                future: _initializeVideoPlayer,
                builder: (context, snap) => snap.connectionState == ConnectionState.done ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ) : Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            _controller.value.isPlaying ? FlatButton(
              child: Text("PAUSE"),
              onPressed: () {
                setState(() {
                  _controller.pause();
                });
              },
            ) : FlatButton(
              child: Text("PLAY"),
              onPressed: () {
                setState(() {
                  _controller.play();
                });
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: widget.ts.map((t) => FlatButton(
                    child: Text("${t.inMinutes}:${t.inSeconds - t.inMinutes * 60}:${t.inMilliseconds - t.inSeconds * 1000}"),
                    onPressed: () {
                      _controller.seekTo(t);
                    },
                  )).toList(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}