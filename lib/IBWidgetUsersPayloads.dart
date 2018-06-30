
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ib/IBColors.dart';
import 'package:ib/IBFirestore.dart';
import 'package:ib/IBFirestoreUser.dart';
import 'package:ib/IBLocalString.dart';

import 'package:ib/IBWidgetApp.dart';
import 'package:ib/IBWidgetUser.dart';
import 'package:ib/IBWidgetUserIcon.dart';

class IBWidgetUsersPayloads extends StatefulWidget {

  final bool areFollowers;
  final String name;
  final List<String> idsUsers;

  IBWidgetUsersPayloads(this.areFollowers, this.idsUsers, this.name, {Key key}) : super(key: key);

  @override
  IBStateWidgetUsersPayloads createState() {
    return IBStateWidgetUsersPayloads(areFollowers, idsUsers, name);
  }
}

class IBStateWidgetUsersPayloads extends State<IBWidgetUsersPayloads> {

  static double sizeHeightContainerPayloadUser = 45.0;

  static double spacingHorizontal = 8.0;
  static double spacingVertical = 6.0;
  static double spacingVerticalEdge = 8.0;

  bool areFollowers;
  String name;
  List<String> idsUsers;

  IBStateWidgetUsersPayloads(this.areFollowers, this.idsUsers, this.name);

  var isTappedAction = false;

  var textControllerPlace = TextEditingController();

  List<IBFirestoreUser> usersPayloads;

  @override
  void initState() {

    super.initState();

    IBLocalString.context = context;

    usersPayloads = idsUsers.map<IBFirestoreUser>((id) => IBFirestoreUser.firestore(id, IBFirestore.usersPayloads[id])).toList();

    setupAsync();
  }

  setupAsync() async { }

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
          title: GestureDetector(
              child: Text(
                IBLocalString.usersPayloadsTitle(name, areFollowers),
                style: TextStyle(
                    color: Colors.white
                ),
              ),
              onTapDown: (_) {}
          ),
        ),
        body: ListView(
          children: usersPayloads.map((userPayload) {
            return GestureDetector(
              child: Container(
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: IBWidgetUserIcon(
                              userPayload.id,
                            ),
                            margin: EdgeInsets.only(
                              top: spacingVertical,
                              left: spacingHorizontal,
                              bottom: spacingVertical,
                            ),
                          ),
                          Container(
                            child: Text(
                              userPayload.name,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.0
                              ),
                            ),
                            margin: EdgeInsets.only(
                                left: spacingHorizontal/2
                            ),
                          )
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        color: Colors.black26,
                        height: 0.5,
                        margin: EdgeInsets.only(
                            left: spacingHorizontal
                        ),
                      ),
                    ),
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.transparent
                        )
                    )
                  ],
                ),
                height: sizeHeightContainerPayloadUser,
                padding: EdgeInsets.only(),
              ),
              onTapUp: (_) {
                IBWidgetApp.pushWidget(IBWidgetUser(userPayload: userPayload), context);
              },
            );
          }).toList(),
        )
    );
  }
}