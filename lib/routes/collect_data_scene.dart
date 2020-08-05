import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:training_stats/datatypes/record_data.dart';
import 'package:training_stats/datatypes/training_data.dart';
import 'package:training_stats/widgets/evaluation_board.dart';
import 'package:training_stats/widgets/evaluation_history_board.dart';
import 'package:training_stats/widgets/grid_segmented_control.dart';


class CollectDataScene extends StatefulWidget {
  CollectDataScene({Key key, this.training}) : super(key: key);

  final TrainingData training;

  @override
  _CollectDataSceneState createState() => _CollectDataSceneState();
}

class _CollectDataSceneState extends State<CollectDataScene> {

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<EvaluationHistoryBoardState> evalHistoryKey = GlobalKey<EvaluationHistoryBoardState>();

  List<RecordData> records = [];
  RecordData currentRecord = RecordData();

  bool onPlayerChanged(int index) {
    setState(() {
      if(index == null) {
        currentRecord.player = null;
      } else {
        currentRecord.player = widget.training.players[index];
      }
    });
    return true;
  }

  bool onActionChanged(int index) {
    if(currentRecord.player != null) {
      setState(() {
        if(index == null) {
          currentRecord.action = null;
        } else {
          currentRecord.action = widget.training.actions[index];
        }
      });
      return true;
    } else {
      scaffoldKey.currentState.removeCurrentSnackBar();
      scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("You should select the player first."), duration: Duration(seconds: 1)));
      return false;
    }
  }

  bool onEvaluationChanged(int eval) {

    if(currentRecord.player != null && currentRecord.action != null) {

      setState(() {

        records.add(RecordData(
            player: currentRecord.player,
            action: currentRecord.action,
            evaluation: eval
        ));

        evalHistoryKey.currentState.addRecord(records.last);

      });

      return true;
    } else {
      scaffoldKey.currentState.removeCurrentSnackBar();
      scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("You should select the player and the action first."), duration: Duration(milliseconds: 700),));
      return false;
    }
  }

  bool undoBtnEnabled() {
    return records.length > 0;
  }

  void undo() {
    setState(() {
      records.removeLast();
      evalHistoryKey.currentState.removeLastRecord();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(widget.training.exercise.name),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.stop),
            tooltip: "Stop the current training session",
            onPressed: () {
              scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Not yet implemented"), duration: Duration(milliseconds: 700)));
            },
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          SafeArea(
            minimum: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
            child: Column(
              children: <Widget>[
                GridSegmentedControl(
                  title: "Player",
                  rowCount: 6,
                  widgets: widget.training.players.asMap().map((key, value) => MapEntry<int, String>(key, value.shortName)),
                  onPressed: (idx) => onPlayerChanged(idx),
                ),
                GridSegmentedControl(
                  title: "Action",
                  rowCount: 6,
                  widgets: widget.training.actions.asMap().map((key, value) => MapEntry<int, String>(key, value.shortName)),
                  onPressed: (idx) => onActionChanged(idx),
                ),
                EvaluationBoard(
                  onPressed: (eval) => onEvaluationChanged(eval),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: EvaluationHistoryBoard(
              key: evalHistoryKey,
            ),
          ),
          Positioned(
            bottom: 5.0,
            right: 8.0,
            child: IconButton(
              icon: Icon(
                Icons.backspace,
                color: Colors.grey,
                size: 25.0,
              ),
              onPressed: undoBtnEnabled() ? () { undo(); } : null,
            ),
          )
        ],
      )
    );
  }
}
