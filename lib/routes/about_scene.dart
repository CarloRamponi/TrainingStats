import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:training_stats/widgets/drawer.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScene extends StatefulWidget {
  @override
  _AboutSceneState createState() => _AboutSceneState();

}

class _AboutSceneState extends State<AboutScene> {

  Future<String> license;

  @override
  void initState() {
    license = rootBundle.loadString(join("assets", "LICENSE.md"));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: MyDrawer(),
        appBar: AppBar(
          title: Text('About'),
        ),
        body: SafeArea(
            child: Scrollbar(
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Training Stats",
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10.0),
                        ),
                        RichText(
                            textAlign: TextAlign.center,
                            text :
                            TextSpan(
                                children: <InlineSpan>[
                                  TextSpan(
                                    text: 'Source code available at ',
                                    style: Theme.of(context).textTheme.bodyText2.apply(fontSizeDelta: -2.0),
                                  ),
                                  TextSpan(
                                      text: 'https://github.com/CarloRamponi/TrainingStats/',
                                      style: Theme.of(context).textTheme.bodyText2.apply(color: Colors.blue, decoration: TextDecoration.underline, fontSizeDelta: -2.0),
                                      recognizer: TapGestureRecognizer()..onTap = () { launch('https://github.com/CarloRamponi/TrainingStats/'); }
                                  )
                                ]
                            )
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10.0),
                        ),
                        Text(
                          '''
Copyright (C) 2020 Carlo Ramponi <magocarlos1999@gmail.com>
This program comes with ABSOLUTELY NO WARRANTY.
This is free software, and you are welcome to redistribute it under certain conditions, see the full license below.
''',
                          style: Theme.of(context).textTheme.bodyText2.apply(fontSizeDelta: -2.0),
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 30.0),
                        ),
                        FutureBuilder(
                          builder: (context, licenseSnap) {
                            if(licenseSnap.hasData) {
                              return Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: licenseSnap.data.split('\n\n').map<Widget>((chunk) => Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5.0),
                                    child: Text(
                                      chunk.split('\n').map((c) => c.trim()).toList().join('\n'),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.caption.apply(fontSizeDelta: -4.0),
                                    ),
                                  )
                                  ).toList()
                              );
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          },
                          future: license,
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
        )
    );
  }
}