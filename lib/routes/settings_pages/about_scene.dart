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
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:path/path.dart';

class AboutScene extends StatelessWidget {

  final Future<String> licenseFuture = rootBundle.loadString(join("assets", "LICENSE.md"));
  final Future<PackageInfo> infoFuture = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {

    licenseFuture.then((license) {
      infoFuture.then((info) {

        Navigator.of(context).pop();

        String preamble = '''
Copyright (C) 2020 Carlo Ramponi, magocarlos1999@gmail.com
This program comes with ABSOLUTELY NO WARRANTY.
This is free software, and you are welcome to redistribute it under certain conditions, see the full license below.
                ''';

        /* Remove useless spaces and returns. */
        license = license.split("\n").map((e) => e.trim()).map((e) => e == "" ? '\n\n' : e + " ").join("");

        /* Displays a scene where there will be the license of "Training stats" and all other open source licenses of sources that are used in the application */
        showLicensePage(
            context: context,
            applicationName: info.appName,
            applicationVersion: info.version,
            applicationLegalese: preamble + "\n" + license,
            applicationIcon: Image.asset("assets/img/icon.png")
        );

      });
    });

    return Center(
      child: CircularProgressIndicator(),
    );
  }

}