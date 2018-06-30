
import 'package:flutter/material.dart';

import 'package:ib/IBColors.dart';

import 'package:ib/IBWidgetEvents.dart';

class IBWidgetApp extends StatelessWidget {

  static pushWidget(Widget widget, BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Icebreak',
      theme: ThemeData(
          primaryColor: IBColors.logo,
          primarySwatch: Colors.green
      ),
//      home: IBWidgetUserEvents(),
      home: IBWidgetEvents(),
      supportedLocales: [
        const Locale(
            'en'
        ),
        const Locale(
            'es'
        ),
      ],
    );
  }
}


