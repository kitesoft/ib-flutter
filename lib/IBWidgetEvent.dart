
import 'package:flutter/material.dart';

import 'package:ib/IBUserApp.dart';
import 'package:ib/IBColors.dart';
import 'package:ib/IBFirestore.dart';
import 'package:ib/IBFirestoreEvent.dart';
import 'package:ib/IBFirestoreGroup.dart';
import 'package:ib/IBFirestoreUser.dart';
import 'package:ib/IBMessaging.dart';
import 'package:ib/IBLocalString.dart';

import 'package:ib/IBWidgetApp.dart';
import 'package:ib/IBWidgetEventCreate.dart';
import 'package:ib/IBWidgetGroup.dart';
import 'package:ib/IBWidgetPlace.dart';
import 'package:ib/IBWidgetUser.dart';
import 'package:ib/IBWidgetUsersPayloads.dart';
import 'package:ib/IBWidgetUserCreate.dart';
import 'package:ib/IBWidgetUserIcon.dart';


class IBWidgetEvent extends StatefulWidget {

  final IBFirestoreEvent event;

  IBWidgetEvent(this.event, {Key key}) : super(key: key);

  @override
  IBStateWidgetEvent createState() {
    return IBStateWidgetEvent(event);
  }
}


class IBStateWidgetEvent extends State<IBWidgetEvent> {

  static const sizeIcon = 18.0;

  static const spacingHorizontal = 8.0;
  static const spacingVertical = 4.0;
  static const spacingVerticalEdge = 8.0;

  IBFirestoreEvent event;

  IBStateWidgetEvent(this.event);

  IBFirestoreGroup groupPayload;

  var isUserAppFollowing = false;

  var idsFollowersShown = List<String>();

  IBFirestoreUser userPayloadCreator;
  List<IBFirestoreUser> usersPayloadsFollowersShown;


  @override
  void initState() {

    super.initState();

    if (IBUserApp.current != null) {
      isUserAppFollowing = event.idsFollowers.contains(IBUserApp.current.id);
      idsFollowersShown = event.idsFollowers.toSet().intersection(IBUserApp.current.idsFollowing.toSet()).toList();
    }

    if (event.idGroup != null) {
      groupPayload = IBFirestoreGroup.firestore(event.idGroup, IBFirestore.groupsPayloads[event.idGroup]);
    }

    userPayloadCreator = IBFirestoreUser.firestore(event.idCreator, IBFirestore.usersPayloads[event.idCreator]);
    usersPayloadsFollowersShown = idsFollowersShown.map<IBFirestoreUser>((id) => IBFirestoreUser.firestore(id, IBFirestore.usersPayloads[id])).toList();
  }


  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      child: Text(
                        event.name,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      margin: EdgeInsets.only(
                        top: spacingVerticalEdge,
                        left: spacingHorizontal,
                      ),
                    ),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                ),
                event.isNow || event.isToday || !event.isActive ?
                Container(
                    child: Text(
                      event.isNow ? IBLocalString.eventNow : event.isToday ? IBLocalString.eventToday : IBLocalString.eventEnded,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: !event.isActive ? Colors.grey : IBColors.logo
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 5.0,
                        vertical: 1.0
                    ),
                    margin: EdgeInsets.only(
                        top: spacingVerticalEdge - 2.0,
                        left: spacingHorizontal/2// adjustment to center with title
                    )
                ) : Container(),
                groupPayload != null ? GestureDetector(
                  child: Container(
                    child: Text(
                      IBLocalString.eventGroup(groupPayload.name),
                      style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic
                      ),
                    ),
                    margin: EdgeInsets.only(
                      top: spacingVerticalEdge,
                      left: spacingHorizontal,
                    ),
                  ),
                  onTapCancel: () {
                  },
                  onTapDown: (_) {
                  },
                  onTapUp: (_) {
                    IBWidgetApp.pushWidget(IBWidgetGroup(groupPayload), context);
                  },
                ) : Container(),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
            ),
            Container(
              child: Text(
                event.description,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.left,
              ),
              margin: EdgeInsets.only(
                  top: spacingVertical,
                  left: spacingHorizontal,
                  right: spacingHorizontal
              ),
            ),
            Row(
              children: <Widget>[
                GestureDetector(
                  child: Container(
                    child: Text(
                      event.placePayload.name,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    margin: EdgeInsets.only(
                      top: spacingVertical,
                      left: spacingHorizontal,
                    ),
                  ),
                  onTapCancel: () {
                  },
                  onTapDown: (_) {
                  },
                  onTapUp: (_) {
                    IBWidgetApp.pushWidget(IBWidgetPlace(event.placePayload), context);
                  },
                ),
                GestureDetector(
                  child: Container(
                    child: Text(
                      event.payloadPlaceCity.name,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    margin: EdgeInsets.only(
                        top: spacingVertical,
                        left: spacingHorizontal/2
                    ),
                  ),
                  onTapCancel: () {
                  },
                  onTapDown: (_) {
                  },
                  onTapUp: (_) {
                    IBWidgetApp.pushWidget(IBWidgetPlace(event.payloadPlaceCity), context);
                  },
                ),
              ],
            ),
            Container(
              child: Text(
                IBLocalString.eventFormatTimestampStart(event.timestampStart) + " " + IBLocalString.eventFormatTimestampEnd(event.timestampEnd),
                style: TextStyle(
                  color:  Colors.black,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.left,
              ),
              margin: EdgeInsets.only(
                  top: spacingVertical,
                  left: spacingHorizontal,
                  right: spacingHorizontal
              ),
            ),
            Container(
              child: Wrap(
                children: <Widget>[
                  Text(
                    IBLocalString.eventOrganizedBy,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  Container(
                    child: IBWidgetUserIcon(
                      event.idCreator,
                    ),
                    height: 18.0,
                    margin: EdgeInsets.only(
                    ),
                    width: 18.0,
                  ),
                  GestureDetector(
                    child: Text(
                      userPayloadCreator.name,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    onTapCancel: () {
                    },
                    onTapDown: (_) {
                    },
                    onTapUp: (_) {
                      IBWidgetApp.pushWidget(IBWidgetUser(userPayload: userPayloadCreator), context);
                    },
                  ),
                ],
                runSpacing: spacingVertical/2,
                spacing: spacingHorizontal/2,
              ),
              margin: EdgeInsets.only(
                top: spacingVertical,
                left: spacingHorizontal,
              ),
            ),
            idsFollowersShown.isNotEmpty ? Container(
              child: Wrap(
                children: <Widget>[
                  Text(
                    IBLocalString.eventFollowedBy,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.left,
                  )
                ] + usersPayloadsFollowersShown.map((userPayload) => [
                  Container(
                    child: IBWidgetUserIcon(
                      userPayload.id,
                    ),
                    height: 18.0,
                    margin: EdgeInsets.only(
                    ),
                    width: 18.0,
                  ),
                  GestureDetector(
                    child: Text(
                      userPayload.name,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    onTapCancel: () {
                    },
                    onTapDown: (_) {
                    },
                    onTapUp: (_) {
                      IBWidgetApp.pushWidget(IBWidgetUser(userPayload: userPayload), context);
                    },
                  ),
                ]).expand((list) => list).toList() +
                    (event.idsFollowers.length > idsFollowersShown.length ? [
                      GestureDetector(
                        child: Text(
                          IBLocalString.eventMoreFollowersCount(event.idsFollowers.length - idsFollowersShown.length),
                        ),
                        onTapCancel: () {
                        },
                        onTapDown: (_) {
                        },
                        onTapUp: (_) {
                          IBWidgetApp.pushWidget(IBWidgetUsersPayloads(true, event.idsFollowers, event.name), context);
                        },
                      ),
                    ] : []),
                runSpacing: spacingVertical/2,
                spacing: spacingHorizontal/2,
              ),
              margin: EdgeInsets.only(
                  top: spacingVertical,
                  left: spacingHorizontal,
                  bottom: spacingVerticalEdge
              ),
            ) : GestureDetector(
              child: Container(
                child: Text(
                  event.idsFollowers.isEmpty ? IBLocalString.eventNoFollowers : IBLocalString.eventFollowersCount(event.idsFollowers.length),
                  style: TextStyle(
                      fontStyle: event.idsFollowers.isEmpty ? FontStyle.italic : FontStyle.normal
                  ),
                ),
                margin: EdgeInsets.only(
                    top: spacingVertical,
                    left: spacingHorizontal,
                    bottom: spacingVerticalEdge
                ),
              ),
              onTapCancel: () {
              },
              onTapDown: (_) {
              },
              onTapUp: (_) {
              },
            ),
            Container(
              color: IBColors.divider,
              height: 0.5,
              margin: EdgeInsets.only(
                  top: spacingVertical,
                  left: spacingHorizontal
              ),
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
        ),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            child: PopupMenuButton<String>(
              child: Container(
                child: Icon(
                  IBUserApp.currentId == event.idCreator ? Icons.more_vert : Icons.done,
                  color: IBUserApp.currentId == event.idCreator ? Colors.grey : isUserAppFollowing ? IBColors.logo : Colors.grey,
                ),
                margin: EdgeInsets.only(
                    top: spacingVertical,
                    right: IBUserApp.currentId == event.idCreator ? 0.0 : spacingHorizontal
                ),
              ),
              itemBuilder: (BuildContext context) {
                var items = List<PopupMenuItem<String>>();
                if (IBUserApp.currentId != event.idCreator) {
                  items.add(
                      PopupMenuItem<String>(
                        value: IBLocalString.eventActionFollowing,
                        child: Row(
                          children: <Widget>[
                            Text(
                                IBLocalString.eventActionFollowing
                            ),
                            Container(
                              child: Icon(
                                Icons.done,
                                color: isUserAppFollowing ? IBColors.logo : Colors.grey,
                              ),
                              margin: EdgeInsets.only(
                                  left: spacingHorizontal/2
                              ),
                            ),
                          ],
                        ),
                      )
                  );
                }
                else if (event.isActive){
                  items.add(
                    PopupMenuItem<String>(
                      value: IBLocalString.eventActionEdit,
                      child: Text(
                          IBLocalString.eventActionEdit
                      ),
                    ),
                  );
                }

                return items;
              },
              onSelected: (value) async {
                if (value == IBLocalString.eventActionFollowing) {
                  if (IBUserApp.current != null) {
                    follow();
                  }
                  else {
                    IBWidgetApp.pushWidget(IBWidgetUserCreate(onCreate: () {
                      follow();
                    }), context);
                  }
                }
                else if (value == IBLocalString.eventActionEdit) {
                  IBWidgetApp.pushWidget(IBWidgetEventCreate(event: event), context);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  follow() {
    IBFirestore.followEvent(event, follow: !isUserAppFollowing);
    setState(() {
      isUserAppFollowing = !isUserAppFollowing;
      if (isUserAppFollowing) {
        event.idsFollowers.add(IBUserApp.current.id);
      }
      else {
        event.idsFollowers.remove(IBUserApp.current.id);
      }
      idsFollowersShown = event.idsFollowers.toSet().intersection(IBUserApp.current.idsFollowing.toSet()).toList();
    });
    if (isUserAppFollowing) {
      (event.idsFollowers + IBUserApp.current.idsFollowers).forEach((id) {
        var userPayload = IBFirestore.usersPayloads[id];
        IBMessaging.send(event.name, IBLocalString.eventMessageFollower(IBUserApp.current.name, userPayload[IBFirestore.CODE_LANGUAGE] ?? "es"), {IBFirestore.ID_EVENT : event.id}, userPayload[IBFirestore.TOKEN]);
      });
    }
  }
}