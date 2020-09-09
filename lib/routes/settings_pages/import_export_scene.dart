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

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:training_stats/utils/db.dart';

class ImportExportScene extends StatefulWidget {


  @override
  _ImportExportSceneState createState() => _ImportExportSceneState();
}

class _ImportExportSceneState extends State<ImportExportScene> {

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool importing;
  bool exporting;

  @override
  void initState() {
    importing = false;
    exporting = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Import/Export"),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          minimum: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Import & export data",
                style: Theme.of(context).textTheme.headline5,
              ),
              Padding(padding: EdgeInsets.only(top: 10.0),),
              Text(
                "You will be able to export a single file containing all your data, including players, teams, reports and your settings.\nThis file can be later imported on an other device.\nUse it also as a backup method."
              ),
              Padding(padding: EdgeInsets.only(top: 10.0),),
              Text(
                "Note: players pictures won't be exported nor imported.",
                style: Theme.of(context).textTheme.caption,
              ),
              Padding(padding: EdgeInsets.only(top: 10.0),),
              Text(
                "Caution: importing data will overwrite all your current data!",
                style: Theme.of(context).textTheme.caption.copyWith(color: Colors.red),
              ),
              Padding(padding: EdgeInsets.only(top: 15.0),),
              Row(
                children: <Widget>[
                  Expanded(
                    child: exporting ? Center(
                      child: CircularProgressIndicator(),
                    ) : RaisedButton(
                      color: Colors.green,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.arrow_upward),
                          Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Text("Export"),
                          )
                        ],
                      ),
                      onPressed: importing ? (){} : _export, //do nothing if an import is in progress
                    ),
                  ),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 10.0),),
                  Expanded(
                    child: importing ? Center(
                      child: CircularProgressIndicator(),
                    ) : RaisedButton(
                      color: Colors.deepOrange,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.arrow_downward),
                          Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Text("Import"),
                          )
                        ],
                      ),
                      onPressed: exporting ? () {} : _import, //do nothing if an export is in progress
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _export() async {

    setState(() {
      exporting = true;
    });

    try {

      String path = await (await DB.instance).exportDB();

      FlutterShare.shareFile(
          title: path.split("/").last,
          text: "TrainingStats exported data",
          filePath: path,
          chooserTitle: "Export data"
      );

    } catch (e) {
      print(e.toString());
      _scaffoldKey.currentState.removeCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Failed to generate export file"), duration: Duration(seconds: 3)));
    }

    setState(() {
      exporting = false;
    });
  }

  void _import() async {

    setState(() {
      importing = true;
    });

    File file = await FilePicker.getFile();

    if(file != null) {
      var result = await (await DB.instance).importData(file.path);

      setState(() {
        importing = false;
      });

      if (result) {
        _scaffoldKey.currentState.removeCurrentSnackBar();
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("Data imported correctly"),
            duration: Duration(seconds: 1)));
      } else {
        _scaffoldKey.currentState.removeCurrentSnackBar();
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("Error while importing data"),
            duration: Duration(seconds: 3)));
      }
    } else {
      setState(() {
        importing = false;
      });
    }

  }

}