import 'dart:async';

import 'package:flutter/cupertino.dart';

class Blinker extends StatefulWidget {

  Blinker({
    Key key,
    this.child,
    this.interval = const Duration(milliseconds: 500),
    this.animation = const Duration(milliseconds: 100)
  }):super(key: key);

  final Widget child;
  final Duration interval;
  final Duration animation;

  _BlinkerState createState() => _BlinkerState();
}

class _BlinkerState extends State<Blinker> {

  Timer timer;
  double opacity;

  @override
  void initState() {
    opacity = 1.0;
    timer = Timer.periodic(widget.interval, (timer) {
      setState(() {
        opacity = 1.0 - opacity;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: widget.animation,
      child: widget.child,
    );
  }

}