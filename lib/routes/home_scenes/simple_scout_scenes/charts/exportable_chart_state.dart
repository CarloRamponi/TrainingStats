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
import 'package:flutter/services.dart';

class ExportedChart {
  
  String title;
  ByteData image;

  ExportedChart({
    this.title,
    this.image
  });

}

class ExportedData {
  String title;
  List<List<dynamic>> data;

  ExportedData(this.title, this.data);
}


abstract class ExportableChartState<T extends StatefulWidget> extends State<T> {
  Future<ExportedChart> getImage();
  Future<ExportedData> getData();
}