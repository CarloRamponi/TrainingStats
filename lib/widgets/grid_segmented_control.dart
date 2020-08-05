import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class GridSegmentedControl<T> extends StatefulWidget {
  GridSegmentedControl(
      {Key key,
      @required this.title,
      @required this.widgets,
      @required this.onPressed,
      this.rowCount = 4})
      : super(key: key);

  final String title;
  final Map<T, String> widgets;
  final int rowCount;
  final bool Function(T) onPressed;

  @override
  _GridSegmentedControlState createState() => _GridSegmentedControlState();
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
    List<Widget> children = [];

    widget.widgets.forEach((key, text) {
      children.add(
        GestureDetector(
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 100),
              curve: Curves.easeIn,
              decoration: selectedItem == key || currentTappedItem == key
                ? BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(100.0)),
                    color:  Theme.of(context).primaryColor,
                  )
                : BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(100.0)),
                  color: Colors.transparent,
                ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                     color: selectedItem == key || currentTappedItem == key ? Colors.white : Colors.black
                  ),
                ),
              ),
            ),
          ),
          onTap: () {
            onTap(key);
          },
          onTapDown: (_) {
            onTapDown(key);
          },
          onTapUp: (_) {
            onTapUp();
          },
          onTapCancel: () {
            onTapUp();
          },
        ),
      );
    });

//    for(var i = 0; i < widget.widgets.length % widget.rowCount - 1; i++) {
//      children.add(
//        Container(
//          decoration: BoxDecoration(
//            border: Border.all(
//                color: Theme.of(context).primaryColor,
//                width: 1.0
//            ),
//          )
//        )
//      );
//    }

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
                  GridView.count(
                      physics: new NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 5.0,
                      shrinkWrap: true,
                      crossAxisCount: widget.rowCount,
                      children: children
                  ),
                ]
            )
        )
    );
  }
}
