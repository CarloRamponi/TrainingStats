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


import 'dart:math';

import 'package:flutter/material.dart';

List<List<T>> chunk<T>(List<T> lst, int size) {
  return List.generate((lst.length / size).ceil(),
          (i) => lst.sublist(i * size, min(i * size + size, lst.length)));
}

Future<T> loadingPopup<T>(BuildContext context, Future<T> ftr) async {

  return await showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (context) {

        ftr.then((T value) => Navigator.of(context).pop(value));

        return Center(
          child: CircularProgressIndicator(),
        );

      },
  );

}