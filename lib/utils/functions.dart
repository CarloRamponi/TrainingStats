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
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:training_stats/datatypes/record.dart';
import 'package:training_stats/datatypes/training.dart';
import 'package:path/path.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

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

Future<T> loadingPopupWithProgress<T>(BuildContext context, Future<T> Function(void Function(double)) ftrCall, String title) async {

  return await showDialog<T>(
    context: context,
    barrierDismissible: false,
    builder: (context) {

      void Function(void Function ()) setDialogState = (f) {};

      double progress = 0.0;

      Future<T> ftr = ftrCall((value) {
        setDialogState(() {
          progress = value;
        });
      });

      ftr.then((T value) => Navigator.of(context).pop(value));

      return StatefulBuilder(
          builder: (context, setDState) {

            setDialogState = setDState;

            return WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    child: Row(
                      children: [
                        Text(title),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text("${(progress * 100).ceil().toString()}%"),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
                    child: LinearProgressIndicator(
                      value: progress,
                    ),
                  ),
                ],
              ),
            );
          }
      );
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

Future<bool> createClips(String videoPath, DateTime startTimeStamp, DateTime endTimeStamp, Training training, void Function(double) onProgress) async {

  String path = await Training.getVideoDirectoryPath(training.id);
  Directory(path).createSync(recursive: true);

  FlutterFFmpeg flutterFFmpeg = new FlutterFFmpeg();

  double progress = 0.0;

  for(Record r in training.records) {

    String clipPath = join(path, r.id.toString() + ".mp4");
    String thumbnailPath = join(path, "thumbnail_" + r.id.toString() + ".jpg");

    //cut out the clip from the original video
    int res = await flutterFFmpeg.executeWithArguments([
      "-i", videoPath,
      "-ss", printDuration(maxDuration(r.timestamp.difference(startTimeStamp) - Duration(seconds: 3), Duration.zero)),
      "-to", printDuration(minDuration(r.timestamp.difference(startTimeStamp) + Duration(seconds: 2), endTimeStamp.difference(startTimeStamp))),
      "-c", "copy",
      clipPath
    ]);

    if(res != 0) {
      return false;
    }

    progress += 1.0 / (training.records.length * 2);
    onProgress(progress);

    //save a thumbnail image
    Uint8List thumbnailData = await VideoThumbnail.thumbnailData(
      video: clipPath,
      timeMs: 3000,
      quality: 75
    );

    File(thumbnailPath).writeAsBytesSync(thumbnailData.toList());

    progress += 1.0 / (training.records.length * 2);
    onProgress(progress);
  }

  File(videoPath).deleteSync();

  return true;

}

Future<String> exportClips(int trainingId, List<Record> records, void Function(double) onProgress) async {

  String path = await Training.getVideoDirectoryPath(trainingId);
  String cache = (await getTemporaryDirectory()).path;
  String tmp_clips = join(cache, "tmp_clips");

  try {
    Directory(tmp_clips).deleteSync(recursive: true);
  } catch (e) {}

  try {
    Directory(tmp_clips).createSync(recursive: true);
  } catch (e) {}

  for(String name in ["icon.png", "-3.png", "-2.png", "-1.png", "1.png", "2.png", "3.png"])
    File(join(tmp_clips, name)).writeAsBytesSync((await rootBundle.load("assets/img/video_overlays/$name")).buffer.asUint8List());
  File(join(tmp_clips, "font.ttf")).writeAsBytesSync((await rootBundle.load("assets/fonts/Roboto-Regular.ttf")).buffer.asUint8List());

  String fontPath = join(tmp_clips, "font.ttf");

  FlutterFFmpeg flutterFFmpeg = new FlutterFFmpeg();

  double progress = 0.0;

  for(Record r in records) {
    int res = await flutterFFmpeg.executeWithArguments([
      "-i", join(path, r.id.toString() + ".mp4"),
      "-i", join(tmp_clips, "icon.png"),
      "-i", join(tmp_clips, "${r.evaluation.toString()}.png"),
      "-filter_complex", '''
        [0][1]overlay=x=(main_w-60):y=(main_h-60)[v1];
        [v1][2]overlay=x=10:y=10,
        drawtext=fontfile=$fontPath:text='Training Stats':x=main_w-text_w-70:y=main_h-text_h-10-((50-text_h)/2):fontsize=30:fontcolor=white,
        drawtext=fontfile=$fontPath:text='${r.player.name.replaceAll("'", " ")}, ${r.action.name.replaceAll("'", " ")}':x=70:y=10+((50-text_h)/2):fontsize=30:fontcolor=white
      ''',
      join(tmp_clips, r.id.toString() + ".mp4")
    ]);

    if(res != 0) {
      print("Unable to encode a video");
      return null;
    }

    progress += 1.0 / (records.length + 1);
    onProgress(progress);
  }

  String videosTxtPath = join(cache, "videos.txt");
  String videosTxtContent = records.map<String>((record) => "file '${join(tmp_clips, "${record.id.toString()}.mp4")}'").join("\n");
  File(videosTxtPath).writeAsStringSync(videosTxtContent);

//  String videosTxtPath = join(cache, "videos.txt");
//  String videosTxtContent = records.map<String>((record) => "file '${join(path, "${record.id.toString()}.mp4")}'").join("\n");
//  File(videosTxtPath).writeAsStringSync(videosTxtContent);

  String outPath = join(cache, "output.mp4");

  try {
    File(outPath).deleteSync();
  } catch (e) {}

  int ret = await flutterFFmpeg.executeWithArguments([
    "-f", "concat",
    "-safe", "0",
    "-i", videosTxtPath,
    "-c", "copy",
    outPath
  ]);

  try {
    Directory(tmp_clips).deleteSync(recursive: true);
  } catch (e) {}

  onProgress(100.0);

  if(ret == 0) {
    return outPath;
  } else {
    print("Unable to concatenate videos.");
    return null;
  }
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