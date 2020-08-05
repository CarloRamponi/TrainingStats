import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EvaluationBoard extends StatefulWidget {
  EvaluationBoard({Key key, @required this.onPressed}) : super(key: key);

  final bool Function(int) onPressed;

  @override
  _EvaluationBoardState createState() => _EvaluationBoardState();
}

class _EvaluationBoardState extends State<EvaluationBoard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 40,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
                child:
                FlatButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(3), bottomLeft: Radius.circular(3))),
                  child: null,
                  color: Colors.red,
                  onPressed: () { widget.onPressed(-2); },
                )
            ),
            Expanded(
                child:
                FlatButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  child: null,
                  color: Colors.orange,
                  onPressed: () { widget.onPressed(-1); },
                )
            ),
            Expanded(
                child:
                FlatButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  child: null,
                  color: Colors.yellow,
                  onPressed: () { widget.onPressed(1); },
                )
            ),
            Expanded(
                child:
                FlatButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(3), bottomRight: Radius.circular(3))),
                  child: null,
                  color: Colors.green,
                  onPressed: () { widget.onPressed(2); },
                )
            )
          ],
        ),
      ),
    );
  }
}
