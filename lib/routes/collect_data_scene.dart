import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:training_stats/datatypes/evaluation_data.dart';
import 'package:training_stats/datatypes/record_data.dart';
import 'package:training_stats/datatypes/training_data.dart';
import 'package:training_stats/widgets/grid_segmented_control.dart';


class CollectDataScene extends StatefulWidget {
  CollectDataScene({Key key, this.training, this.evaluations}) : super(key: key);

  final TrainingData training;
  final List<EvaluationData> evaluations;

  @override
  _CollectDataSceneState createState() => _CollectDataSceneState();
}

class _CollectDataSceneState extends State<CollectDataScene> {

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<RecordData> records = [];
  RecordData currentRecord = RecordData();

  void onPlayerChanged(int index) {
    setState(() {
      currentRecord.player = widget.training.players[index];
    });
  }

  void onActionChanged(int index) {
    setState(() {
      currentRecord.action = widget.training.actions[index];
    });
  }

  void onEvaluationChanged(int index) {
    setState(() {
      currentRecord.evaluation = widget.evaluations[index];
    });
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
              scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Not yet implemented"),));
            },
          )
        ],
      ),
      body: SafeArea(
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
              GridSegmentedControl(
                title: "Evaluation",
                rowCount: 6,
                widgets: widget.evaluations.asMap().map((key, value) => MapEntry<int, String>(key, value.shortName)),
                onPressed: (idx) => onEvaluationChanged(idx),
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(
                      child: Text("UNDO", style: Theme.of(context).textTheme.button),
                      onPressed: () {},
                    ),
                    RaisedButton(
                      child: Text("OK"),
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      disabledColor: Colors.grey,
                      disabledTextColor: Colors.black,
                      onPressed: okBtnEnabled() ? () {} : null,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
    );
  }
}
