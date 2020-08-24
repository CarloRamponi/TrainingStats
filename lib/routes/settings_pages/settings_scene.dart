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
import 'package:training_stats/widgets/drawer.dart';

class SettingsPageInfo {

  String title;
  String subtitle;
  IconData icon;
  String route;

  SettingsPageInfo({this.title, this.subtitle, this.icon, this.route});

}

class SettingsScene extends StatelessWidget {

  final List<SettingsPageInfo> pages = [
    SettingsPageInfo(
      title: "Roles",
      subtitle: "Edit name and color of your roles.",
      icon: Icons.scatter_plot,
      route: "roles"
    ),
    SettingsPageInfo(
        title: "Evaluation board",
        subtitle: "Customize the evaluation board.",
        icon: Icons.dashboard,
        route: "evaluations"
    ),
    SettingsPageInfo(
        title: "Actions",
        subtitle: "Edit the actions of your sport.",
        icon: Icons.build,
        route: "actions"
    ),
    SettingsPageInfo(
        title: "Import/Export",
        subtitle: "Import/Export your data.",
        icon: Icons.import_export,
        route: "import_export"
    ),
    SettingsPageInfo(
        title: "About",
        subtitle: "About TrainingStats.",
        icon: Icons.info,
        route: "about"
    ),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        drawer: MyDrawer(),
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: ListView.separated(
            itemBuilder: (context, index) {

              SettingsPageInfo info = pages[index];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.grey,
                  child: Icon(info.icon, size: 30,),
                ),
                title: Text(info.title),
                subtitle: Text(info.subtitle),
                onTap: () {
                  Navigator.of(context).pushNamed("/settings/" + info.route);
                },
              );
            },
            separatorBuilder: (_, __) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Divider(),
            ),
            itemCount: pages.length
        )
    );

  }

}