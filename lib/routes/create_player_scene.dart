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
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:training_stats/datatypes/player.dart';
import 'package:training_stats/datatypes/role.dart';
import 'package:path/path.dart';

class CreatePlayerScene extends StatefulWidget {
  CreatePlayerScene({Key key}) : super(key: key);

  @override
  _CreatePlayerSceneState createState() => _CreatePlayerSceneState();
}

class _CreatePlayerSceneState extends State<CreatePlayerScene> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<List<Role>> roles;
  Player player = Player();

  FocusNode shortNameFocusNode = FocusNode();

  bool creating = false;

  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    roles = RoleProvider.getAll();
    super.initState();
  }

  void createPlayer() async {
    setState(() {
      creating = true;
    });

    player = await PlayerProvider.create(player);
    Navigator.of(this.context).pop(player);
  }

  void getImagePopUp() {

    showDialog(context: this.context, builder: (context) {
      return SimpleDialog(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.photo),
              title: Text("Select from gallery"),
              onTap: () {
                Navigator.of(context).pop();
                getImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text("Take a picture"),
              onTap: () {
                Navigator.of(context).pop();
                getImage(ImageSource.camera);
              },
            ),
            if(player.photo != null)
              ListTile(
                leading: Icon(Icons.edit),
                title: Text("Edit current picture"),
                onTap: () {
                  Navigator.of(context).pop();
                  editImage(player.photo);
                },
              ),
            if(player.photo != null)
              ListTile(
                leading: Icon(Icons.delete_forever),
                title: Text("Remove current picture"),
                onTap: () {
                  Navigator.of(context).pop();
                  removeImage();
                },
              )
          ],
      );
    });

  }

  void getImage(ImageSource source) async {

    final pickedFile = await picker.getImage(source: source);

    if(pickedFile != null) {

      editImage(pickedFile.path);

    }

  }

  void editImage(String filePath) async {

    File croppedFile = await ImageCropper.cropImage(
        sourcePath: filePath,
        cropStyle: CropStyle.circle,
        aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop image',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true
        ),
        iosUiSettings: IOSUiSettings(
          title: 'Crop image',
        )
    );

    if(croppedFile != null) {

      Directory docDir = await getApplicationDocumentsDirectory();
      String path = join(docDir.path, "image" + DateTime.now().toIso8601String() + filePath.split(".").last);
      File file = await File(croppedFile.path).rename(path);

      if (player.photo != null && player.photo != file.path) {
        await File(player.photo).delete();
      }

      setState(() {
        player.photo = file.path;
      });

    }

  }

  void removeImage() async {

    if(player.photo != null) {
      await File(player.photo).delete();
      setState(() {
        player.photo = null;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text('Create player'),
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: GestureDetector(
                        child: Center(
                          child: player.photo == null ? Container(
                            height: MediaQuery.of(context).size.width / 2.0,
                            width: MediaQuery.of(context).size.width / 2.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.withOpacity(0.3)
                            ),
                            child: Icon(
                                Icons.add_a_photo,
                                size: MediaQuery.of(context).size.width / 8.0,
                                color: Colors.grey
                              ),
                          ) : ClipOval(
                            child: Stack(
                              children: <Widget>[
                                Image.file(
                                  File(player.photo),
                                  width: MediaQuery.of(context).size.width / 2.0,
                                ),
                                Positioned(
                                  bottom: 0.0,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width / 2.0,
                                    height: MediaQuery.of(context).size.width / 10.0,
                                    color: Colors.grey.withOpacity(0.7),
                                    child: Center(
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ),
                        onTap: () {
                          getImagePopUp();
                        },
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  maxLength: 128,
                  autofocus: true,
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: "Name",
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Enter some text";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {
                    player.name = value;
                  },
                  onEditingComplete: () {
                    shortNameFocusNode.requestFocus();
                  },
                ),
                TextFormField(
                  maxLength: 2,
                  focusNode: shortNameFocusNode,
                  decoration: InputDecoration(
                      counterText: "", hintText: 'Abbreviation'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Enter some text";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {
                    player.shortName = value;
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top:10.0),
                  child: FutureBuilder(
                    future: roles,
                    builder: (_, AsyncSnapshot<List<Role>> snap) {
                      if (snap.hasData) {
                        return DropdownButton<Role>(
                          isExpanded: true,
                          value: player.role,
                          icon: Icon(Icons.arrow_downward),
                          iconSize: 24,
//                            underline: Container(
//                              height: 2,
//                              color: Colors.deepPurpleAccent,
//                            ),
                          onChanged: (Role newValue) {
                            setState(() {
                              player.role = newValue;
                            });
                          },
                          items: (<Role>[null] + snap.data)
                              .map<DropdownMenuItem<Role>>((Role value) {
                            return DropdownMenuItem<Role>(
                              value: value,
                              child: value == null
                                  ? Text(
                                "Select Role",
                                style: Theme.of(context).textTheme.caption,
                              )
                                  : Row(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(right: 10.0),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(100.0),
                                        color: value.color),
                                    width: 20.0,
                                    height: 20.0,
                                  ),
                                  Text(value.name)
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: creating ? CircularProgressIndicator() : RaisedButton(
                    child: Text("Create"),
                    onPressed: () {
                      if (formKey.currentState.validate()) {
                        createPlayer();
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        )));
  }
}
