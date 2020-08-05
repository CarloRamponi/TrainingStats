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

    /* DEBUG */
    if(eval == 2) {
      evalHistoryKey.currentState.addRecord(RecordData(
        player: widget.training.players[0],
        action: widget.training.actions[0],
        evaluation: 2
      ));
    } else if(eval == -2) {
      evalHistoryKey.currentState.removeLastRecord();
    }

    if(currentRecord.player != null && currentRecord.action != null) {
      return true;
    } else {
      scaffoldKey.currentState.removeCurrentSnackBar();
      scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("You should select the player and the action first."), duration: Duration(milliseconds: 700),));
      return false;
    }
  }

  bool okBtnEnabled() {
    return currentRecord.player != null && currentRecord.action != null && currentRecord.evaluation != null;
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
          )
        ],
      )
    );
  }
}
