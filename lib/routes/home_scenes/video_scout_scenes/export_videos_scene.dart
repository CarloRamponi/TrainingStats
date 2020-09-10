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

import 'package:flutter/material.dart';
import 'package:training_stats/datatypes/record.dart';

class ExportVideosScene extends StatefulWidget {

  final List<Record> records;

  ExportVideosScene({@required this.records});

  @override
  _ExportVideosSceneState createState() =>_ExportVideosSceneState();
}

class _ExportVideosSceneState extends State<ExportVideosScene> {

  List<Record> records;
  Map<Record, bool> selected;

  GlobalKey<ScaffoldState> _scaffold = GlobalKey();

  @override
  void initState() {
    records = List.from(widget.records);
    selected = Map.fromEntries(records.map((e) => MapEntry(e, true)));
    super.initState();
  }

  void _done() {
    if(!selected.values.any((element) => element == true)) {
      _scaffold.currentState.removeCurrentSnackBar();
      _scaffold.currentState.showSnackBar(SnackBar(content: Text("You should select al least one clip!"),));
    } else {
      Navigator.of(context).pop(records.where((element) => selected[element]).toList());
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
          title: Text(record.player.name),
        )).toList(),
      ),
    );
  }

}