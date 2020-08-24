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
 

import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class GridSegmentedControlElement<T> {
  T value;
  String name, tooltip;
  Color color;

  GridSegmentedControlElement({
    this.value,
    this.name,
    this.tooltip,
    this.color = Colors.transparent
  });
}

class GridSegmentedControl<T> extends StatefulWidget {
  GridSegmentedControl(
      {Key key,
      @required this.title,
      @required this.elements,
      @required this.onPressed,
      this.rowCount = 4})
      : super(key: key);

  final String title;
  final List<GridSegmentedControlElement<T>> elements;
  final int rowCount;
  final bool Function(T) onPressed;

  @override
  _GridSegmentedControlState<T> createState() => _GridSegmentedControlState<T>();
}

class _GridSegmentedControlState<T> extends State<GridSegmentedControl<T>> {
  T selectedItem;
  T currentTappedItem;

  //callback onPressed should return true if the user can select this item, false otherwise
  void onTap(T item) {

    if(item == selectedItem) {
      widget.onPressed(null);
      setState(() {
        selectedItem = null;
      });
    } else if(widget.onPressed(item)) {
      setState(() {
        selectedItem = item;
      });
    } else {
      setState(() {
        selectedItem = null;
      });
    }
  }

  void onTapDown(T item) {
    setState(() {
      currentTappedItem = item;
    });
  }

  void onTapUp() {
    setState(() {
      currentTappedItem = null;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Container(
        child: Card(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 10.0, top: 10.0),
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, BoxConstraints constraints) {

                      double size = constraints.maxWidth / widget.rowCount;
                      int rows = (widget.elements.length / widget.rowCount).ceil();

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(rows, (index) {
                          Iterable<GridSegmentedControlElement<T>> chunk = widget.elements.getRange(index*widget.rowCount, min((index+1)*widget.rowCount, widget.elements.length));
                          return Row(
                            children: chunk.map((element) {

                              Color bgColor = selectedItem == element.value || currentTappedItem == element.value ? Theme.of(context).primaryColor : element.color.withOpacity(0.5);

                              return Container(
                                width: size,
                                height: size,
                                padding: EdgeInsets.all(5.0),
                                child: Tooltip(
                                  message: element.tooltip,
                                  child: RaisedButton(
                                    shape: selectedItem == element.value ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)): CircleBorder(),
                                    clipBehavior: Clip.hardEdge,
                                    padding: EdgeInsets.zero,
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 200),
                                      curve: Curves.easeIn,
                                      color:  bgColor,
                                      child: Center(
                                        child: Text(
                                          element.name,
                                          style: TextStyle(
                                              color: useWhiteForeground(bgColor) ? Colors.white : Colors.black
                                          ),
                                        ),
                                      ),
                                    ),
                                    onPressed: () => onTap(element.value),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }),
                      );

                    },
                  ),
                ]
            )
        )
    );
  }
}
