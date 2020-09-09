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
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:training_stats/datatypes/training.dart';
import 'package:path/path.dart';

List<List<T>> chunk<T>(List<T> lst, int size) {
  return List.generate((lst.length / size).ceil(),
          (i) => lst.sublist(i * size, min(i * size + size, lst.length)));
}

Future<T> loadingPopup<T>(BuildContext context, Future<T> ftr, [String title]) async {

  return await showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (context) {

        ftr.then((T value) => Navigator.of(context).pop(value));

        if(title == null) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return WillPopScope(
            onWillPop: () async => false,
            child: SimpleDialog(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                      child: CircularProgressIndicator(),
                    ),
                    Text(title),
                  ],
                )
              ],
            ),
          );
        }

      },
  );

}

String printDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}

Duration maxDuration(Duration d1, Duration d2) {
  if(d1 > d2)
    return d1;
  return d2;
}

Duration minDuration(Duration d1, Duration d2) {
  if(d1 < d2)
    return d1;
  return d2;
}

Future<bool> createClips(String videoPath, DateTime startTimeStamp, DateTime endTimeStamp, Training training) async {

  Directory documents = await getApplicationDocumentsDirectory();

  String path = join(documents.path, "video_scout", training.id.toString());
  Directory(path).createSync(recursive: true);

  FlutterFFmpeg flutterFFmpeg = new FlutterFFmpeg();

  List<int> results = await Future.wait(
      training.records.map<Future<int>>((r) =>
          flutterFFmpeg.executeWithArguments([
            "-i", videoPath,
            "-ss", printDuration(maxDuration(r.timestamp.difference(startTimeStamp) - Duration(seconds: 3), Duration.zero)),
            "-to", printDuration(minDuration(r.timestamp.difference(startTimeStamp) + Duration(seconds: 2), endTimeStamp.difference(startTimeStamp))),
            "-c:v", "copy",
            join(path, r.id.toString() + ".mp4")
          ])
      )
  );

  if(results.any((element) => element != 0))
    return false;

  File(videoPath).deleteSync();

  return true;

}

//Future<bool> createClips(String videoPath, DateTime startTimeStamp, DateTime endTimeStamp, Training training) async {
//
//  Directory documents = await getApplicationDocumentsDirectory();
//  Directory cache = await getTemporaryDirectory();
//
//  for(String name in ["icon.png", "-3.png", "-2.png", "-1.png", "1.png", "2.png", "3.png"])
//    File(join(cache.path, name)).writeAsBytesSync((await rootBundle.load("assets/img/video_overlays/$name")).buffer.asUint8List());
//  File(join(cache.path, "font.ttf")).writeAsBytesSync((await rootBundle.load("assets/fonts/Roboto-Regular.ttf")).buffer.asUint8List());
//
//  String path = join(documents.path, "video_scout", training.id.toString());
//  Directory(path).createSync(recursive: true);
//
//  String fontPath = join(cache.path, "font.ttf");
//
//  FlutterFFmpeg flutterFFmpeg = new FlutterFFmpeg();
//
//  List<int> results = await Future.wait(
//    training.records.map<Future<int>>((r) =>
//      flutterFFmpeg.executeWithArguments([
//        "-i", videoPath,
//        "-i", join(cache.path, "icon.png"),
//        "-i", join(cache.path, "${r.evaluation.toString()}.png"),
//        "-filter_complex", '''
//          [0][1]overlay=x=(main_w-60):y=(main_h-60)[v1];
//          [v1][2]overlay=x=10:y=10,
//          drawtext=fontfile=$fontPath:text='Training Stats':x=main_w-text_w-70:y=main_h-text_h-10-((50-text_h)/2):fontsize=30:fontcolor=white,
//          drawtext=fontfile=$fontPath:text='${r.player.name}, ${r.action.name}':x=70:y=10+((50-text_h)/2):fontsize=30:fontcolor=white
//        ''',
//        "-ss", printDuration(maxDuration(r.timestamp.difference(startTimeStamp) - Duration(seconds: 3), Duration.zero)),
//        "-to", printDuration(minDuration(r.timestamp.difference(startTimeStamp) + Duration(seconds: 2), endTimeStamp.difference(startTimeStamp))),
//        join(path, r.id.toString() + ".mp4")
//      ])
//    )
//  );
//
//  File(videoPath).deleteSync();
//
//  return true;
//
//}