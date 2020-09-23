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

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:training_stats/datatypes/evaluation.dart';
import 'package:training_stats/datatypes/record.dart';
import 'package:training_stats/datatypes/training.dart';

class ExportVideosScene extends StatefulWidget {

  final int trainingId;
  final List<Record> records;

  ExportVideosScene({
    @required this.trainingId,
    @required this.records
  });

  @override
  _ExportVideosSceneState createState() =>_ExportVideosSceneState();
}

class _ExportVideosSceneState extends State<ExportVideosScene> {

  List<Record> records;
  Map<Record, bool> selected;

  Future<String> clipsPath;

  GlobalKey<ScaffoldState> _scaffold = GlobalKey();

  @override
  void initState() {
    records = List.from(widget.records);
    selected = Map.fromEntries(records.map((e) => MapEntry(e, true)));

    clipsPath = Training.getVideoDirectoryPath(widget.trainingId);

    super.initState();
  }

  void _done() {
    if(!selected.values.any((element) => element == true)) {
      _scaffold.currentState.removeCurrentSnackBar();
      _scaffold.currentState.showSnackBar(SnackBar(content: Text("You should select al least one clip!"),));
    } else {
      Navigator.of(this.context).pop(records.where((element) => selected[element]).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      appBar: AppBar(
        title: Text("Export clips"),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _done,
          )
        ],
      ),
      body: ReorderableListView(
        onReorder: (oldIndex, newIndex) {
          if(newIndex > oldIndex)
            newIndex--;
          setState(() {
            Record item = records.removeAt(oldIndex);
            records.insert(newIndex, item);
          });
        },
        children: records.map((record) => CheckboxListTile(
          key: ValueKey(record.id),
          value: selected[record],
          onChanged: (value) {
            setState(() {
              selected[record] = value;
//              records.remove(record);
//              int index = records.indexWhere((element) => !selected[element]);
//              if(index == -1)
//                records.add(record);
//              else
//                records.insert(index, record);
            });
          },
          secondary: FutureBuilder(
            key: ValueKey(record.id),
            future: clipsPath,
            builder: (context, snap) => snap.hasData ? CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: FileImage(File(join(snap.data, "thumbnail_" + record.id.toString() + ".jpg")))
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
        )).toList(),
      ),
    );
  }

}