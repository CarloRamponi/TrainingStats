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
 
 

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum DrawerSection {
  HOME,
  SCORE_KEEPER,
  TEAMS,
  PLAYERS,
  SETTINGS,
  INFO
}

class MyDrawer extends StatelessWidget {

  DrawerSection activeSection;

  MyDrawer({this.activeSection});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
                'Training Stats',
              style: Theme.of(context).textTheme.headline5.apply(color: Colors.white),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Home"),
            onTap: activeSection == DrawerSection.HOME ? () {
              Navigator.of(context).pop();
            } : () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed("/");
            },
            selected: activeSection == DrawerSection.HOME,
          ),
          ListTile(
            leading: Icon(Icons.score),
            title: Text("Score keeper"),
            onTap: activeSection == DrawerSection.SCORE_KEEPER ? () {
              Navigator.of(context).pop();
            } : () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed("/score_keeper");
            },
            selected: activeSection == DrawerSection.SCORE_KEEPER,
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text("Teams"),
            onTap: activeSection == DrawerSection.TEAMS ? () {
              Navigator.of(context).pop();
            } : () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed("/teams");
            },
            selected: activeSection == DrawerSection.TEAMS,
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Players"),
            onTap: activeSection == DrawerSection.PLAYERS ? () {
              Navigator.of(context).pop();
            } : () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed("/players");
            },
            selected: activeSection == DrawerSection.PLAYERS,
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings"),
            onTap: activeSection == DrawerSection.SETTINGS ? () {
              Navigator.of(context).pop();
            } : () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed("/settings");
            },
            selected: activeSection == DrawerSection.SETTINGS,
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text("About"),
            onTap: activeSection == DrawerSection.INFO ? () {
              Navigator.of(context).pop();
            } : () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed("/settings/about");
            },
            selected: activeSection == DrawerSection.INFO,
          ),
        ],
      ),
    );
  }
}
