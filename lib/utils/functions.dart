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
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_ffmpeg/log_level.dart';
import 'package:flutter_ffmpeg/media_information.dart';
import 'package:flutter_ffmpeg/statistics.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:random_string/random_string.dart';
import 'package:training_stats/datatypes/evaluation.dart';
import 'package:training_stats/datatypes/record.dart';
import 'package:training_stats/datatypes/training.dart';
import 'package:path/path.dart';
import 'package:tuple/tuple.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:image/image.dart' as image;

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
  FlutterFFmpegConfig flutterFFmpegConfig = new FlutterFFmpegConfig();
  flutterFFmpegConfig.setLogLevel(LogLevel.AV_LOG_ERROR);

  double progress = 0.0;

  for(Record r in training.records) {

    String clipPath = join(path, r.id.toString() + ".mp4");
    String thumbnailPath = join(path, "thumbnail_" + r.id.toString() + ".jpg");

    //cut out the clip from the original video
    int res = await flutterFFmpeg.executeWithArguments([
      "-i", videoPath,
      "-ss", printDuration(maxDuration(r.timestamp.difference(startTimeStamp) - Duration(seconds: 3), Duration.zero)),
      "-to", printDuration(minDuration(r.timestamp.difference(startTimeStamp) + Duration(seconds: 2), endTimeStamp.difference(startTimeStamp))),
      "-c:0", "copy",
      clipPath
    ]);

    onProgress(progress += 1.0 / (training.records.length * 2));

    if(res != 0) {
      return false;
    }

    try {
      //save a thumbnail image
      Uint8List thumbnailData = await VideoThumbnail.thumbnailData(
          video: clipPath,
          timeMs: 3000,
          quality: 75
      );

      File(thumbnailPath).writeAsBytesSync(thumbnailData.toList());
    } catch (e) {
      print(e);
    }

    onProgress(progress += 1.0 / (training.records.length * 2));

  }

  File(videoPath).deleteSync();

  return true;

}

Future<String> createCSV(List<List<dynamic>> data) async {
  String csv = ListToCsvConverter().convert(data);
  String filePath = join((await getTemporaryDirectory()).path, randomString(10, from: 62, to: 86) + ".csv");
  File(filePath)..createSync()..writeAsStringSync(csv);
  return filePath;
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

  FlutterFFmpeg flutterFFmpeg = new FlutterFFmpeg();
  final FlutterFFprobe flutterFFprobe = new FlutterFFprobe();

  FlutterFFmpegConfig flutterFFmpegConfig = new FlutterFFmpegConfig();
  flutterFFmpegConfig.setLogLevel(LogLevel.AV_LOG_ERROR);

  int currentRecord = 0;

  const int videoLength = 4500;
  double currentProgress = 0.0;

  for(Record r in records) {

    flutterFFmpegConfig.enableStatisticsCallback((statistics) {
      print("Statistics: executionId: ${statistics.executionId}, time: ${statistics.time}, size: ${statistics.size}, bitrate: ${statistics.bitrate}, speed: ${statistics.speed}, videoFrameNumber: ${statistics.videoFrameNumber}, videoQuality: ${statistics.videoQuality}, videoFps: ${statistics.videoFps}");
      double progress = statistics.time / videoLength;
      if(progress < 1.0) {
        currentProgress = min(1.0, max(currentProgress,
            (currentRecord + progress) / (records.length + 1)));
        onProgress(currentProgress);
      }
    });

    String clipPath = join(path, r.id.toString() + ".mp4");
    String overlayPath = join(tmp_clips, "overlay_" + r.id.toString() + ".png");

    MediaInformation info = await flutterFFprobe.getMediaInformation(clipPath);

    int width, height;

    width = min(info.getStreams().first.getAllProperties()['width'], info.getStreams().first.getAllProperties()['height']);
    height = max(info.getStreams().first.getAllProperties()['width'], info.getStreams().first.getAllProperties()['height']);

    if(!(await createOverlayImage(overlayPath, r, width, height))) {
      print("Unable to generate overlay image");
      return null;
    }

    int res = await flutterFFmpeg.executeWithArguments([
      "-i", clipPath,
      "-i", overlayPath,
      "-filter_complex", '[0][1]overlay=x=0:y=0',
      join(tmp_clips, r.id.toString() + ".mp4")
    ]);

    if(res != 0) {
      print("Unable to encode a video");
      return null;
    }

    currentRecord++;

  }

  String videosTxtPath = join(cache, "videos.txt");
  String videosTxtContent = records.map<String>((record) => "file '${join(tmp_clips, "${record.id.toString()}.mp4")}'").join("\n");
  File(videosTxtPath).writeAsStringSync(videosTxtContent);

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

  onProgress(1.0);

  if(ret == 0) {
    return outPath;
  } else {
    print("Unable to concatenate videos.");
    return null;
  }
}

Future<bool> createOverlayImage(String path, Record record, int width, int height) async {

  int padding = width ~/ 30;
  int circleRadius = width ~/ 20;
  int logoSize = width ~/ 5;

  int stringHeight = width ~/ 30;

  image.Image logoImage = image.decodePng((await rootBundle.load("assets/img/icon.png")).buffer.asUint8List());

  image.Image overlay = image.Image(width, height);

  image.fillCircle(overlay, padding + circleRadius, padding + circleRadius, circleRadius, Evaluation.getColor(record.evaluation).value);
  image.drawImage(overlay, logoImage, dstX: width - padding - logoSize, dstY: height - padding - logoSize, dstW: logoSize, dstH: logoSize);

  String playerString = "${record.player.name}, ${record.action.name}";
  Tuple2<int, int> stringSize = calculateImageStringSize(playerString, image.arial_48);
  image.Image titleImage = image.Image(stringSize.item1, stringSize.item2);
  image.drawString(titleImage, image.arial_48, 0, 0, playerString);
  int dstWidth = (stringHeight / stringSize.item2 * stringSize.item1).toInt();
  image.drawImage(overlay, titleImage, dstX: padding + circleRadius*2 + padding, dstY: padding + (circleRadius*2 - stringHeight)~/2, dstH: stringHeight, dstW: dstWidth);

  String tsString = "Training Stats";
  Tuple2<int, int> tsStringSize = calculateImageStringSize(tsString, image.arial_48);
  image.Image tsImage = image.Image(tsStringSize.item1, tsStringSize.item2);
  image.drawString(tsImage, image.arial_48, 0, 0, tsString);
  dstWidth = (stringHeight / tsStringSize.item2 * tsStringSize.item1).toInt();
  image.drawImage(overlay, tsImage, dstX: width - padding - logoSize - padding - dstWidth, dstY: height - padding - (logoSize - (logoSize - stringHeight)~/2), dstH: stringHeight, dstW: dstWidth);

  File(path).writeAsBytesSync(image.encodePng(overlay));

  return true;

}

Tuple2<int, int> calculateImageStringSize(String string, image.BitmapFont font) {

  var stringWidth = 0;
  var stringHeight = 0;


  var chars = string.codeUnits;
  for (var c in chars) {
    if (!font.characters.containsKey(c)) {
      continue;
    }
    var ch = font.characters[c];
    stringWidth += ch.xadvance;
    if(ch.height + ch.yoffset > stringHeight) {
      stringHeight = ch.height + ch.yoffset;
    }
  }

  return Tuple2(stringWidth, stringHeight);
}