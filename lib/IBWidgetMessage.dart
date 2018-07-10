
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ib/IBColors.dart';
import 'package:ib/IBFirestore.dart';
import 'package:ib/IBFirestoreEvent.dart';
import 'package:ib/IBMessaging.dart';
import 'package:ib/IBLocalString.dart';

import 'package:ib/IBWidgetEvent.dart';

class IBWidgetMessage extends StatefulWidget {

  final Map message;

  IBWidgetMessage(this.message, {Key key}) : super(key: key);

  @override
  IBStateWidgetMessage createState() {
    return IBStateWidgetMessage(this.message);
  }
}

class IBStateWidgetMessage extends State<IBWidgetMessage> {

  static const double SPACING_HORIZONTAL = 8.0;
  static const double SPACING_VERTICAL = 6.0;
  static const double SPACING_VERTICAL_EDGE = 8.0;

  Map message;

  IBStateWidgetMessage(this.message);

  IBFirestoreEvent event;

  @override
  void initState() {
    super.initState();
    IBLocalString.context = context;
  }


  setupAsync() async {
    loadEvents();
  }


  loadEvents() async {

    var idEvent = message[IBMessaging.ID_EVENT];

    if (idEvent != null) {
      var event = await IBFirestore.getEvent(message[IBMessaging.ID_EVENT]);
      setState(() {
        this.event = event;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: IBColors.logo,
          iconTheme: IconThemeData(
              color: Colors.white
          ),
          actions: [ ],
          centerTitle: false,
          elevation: 1.0,
          title: Text(
            IBLocalString.messageTitle,
            style: TextStyle(
                color: Colors.white
            ),
          ),
        ),
        body: ListView(
          children: <Widget>[
            event != null ? IBWidgetEvent(event) : Container()
          ],
        )
    );
  }
}