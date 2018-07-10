
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

  static const IS_TAPPED_MORE_FOLLOWERS_COUNT = "is_tapped_more_followers_count";

  static const MARGIN_RIGHT_ROW = 40.0;

  static const SIZE_ICON = 18.0;

  static const SPACING_HORIZONTAL = 8.0;
  static const SPACING_VERTICAL = 4.0;
  static const SPACING_VERTICAL_EDGE = 8.0;

  IBFirestoreEvent event;

  IBStateWidgetEvent(this.event);

  IBFirestoreGroup groupPayload;

  var isUserAppFollowing = false;

  var idsFollowersShown = List<String>();

  var taps = Map<String, bool>();

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

    if (event.idCreator != null) {
      userPayloadCreator = IBFirestoreUser.firestore(event.idCreator, IBFirestore.usersPayloads[event.idCreator]);
      usersPayloadsFollowersShown = idsFollowersShown.map<IBFirestoreUser>((id) => IBFirestoreUser.firestore(id, IBFirestore.usersPayloads[id])).toList();
    }
  }


  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: Container(
                      child: Text(
                        event.name,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      margin: EdgeInsets.only(
                        top: SPACING_VERTICAL_EDGE,
                        left: SPACING_HORIZONTAL,
                      ),
                    ),
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
                          top: SPACING_VERTICAL_EDGE - 2.0,
                          left: SPACING_HORIZONTAL/2// adjustment to center with title
                      )
                  ) : Container(),
                  groupPayload != null ? GestureDetector(
                    child: Container(
                      child: Text(
                        IBLocalString.eventGroup(groupPayload.name),
                        style: TextStyle(
                            color: taps[groupPayload.id] ?? false ? IBColors.tappedDown : Colors.black,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic
                        ),
                      ),
                      margin: EdgeInsets.only(
                        top: SPACING_VERTICAL_EDGE,
                        left: SPACING_HORIZONTAL,
                      ),
                    ),
                    onTapCancel: () {
                      setState(() {
                        taps[groupPayload.id] = false;
                      });
                    },
                    onTapDown: (_) {
                      setState(() {
                        taps[groupPayload.id] = true;
                      });
                    },
                    onTapUp: (_) {
                      IBWidgetApp.pushWidget(IBWidgetGroup(groupPayload), context);
                      setState(() {
                        taps[groupPayload.id] = false;
                      });
                    },
                  ) : Container(),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
              ),
              margin: EdgeInsets.only(
                right: MARGIN_RIGHT_ROW,
              ),
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
                  top: SPACING_VERTICAL,
                  left: SPACING_HORIZONTAL,
                  right: SPACING_HORIZONTAL
              ),
            ),
            Row(
              children: <Widget>[
                GestureDetector(
                  child: Container(
                    child: Text(
                      event.placePayload.name,
                      style: TextStyle(
                        color: taps[event.placePayload.id] ?? false ? IBColors.tappedDown : Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    margin: EdgeInsets.only(
                      top: SPACING_VERTICAL,
                      left: SPACING_HORIZONTAL,
                    ),
                  ),
                  onTapCancel: () {
                    setState(() {
                      taps[event.placePayload.id] = false;
                    });
                  },
                  onTapDown: (_) {
                    setState(() {
                      taps[event.placePayload.id] = true;
                    });
                  },
                  onTapUp: (_) {
                    IBWidgetApp.pushWidget(IBWidgetPlace(event.placePayload), context);
                    setState(() {
                      taps[event.placePayload.id] = false;
                    });
                  },
                ),
                GestureDetector(
                  child: Container(
                    child: Text(
                      event.payloadPlaceCity.name,
                      style: TextStyle(
                        color: taps[event.payloadPlaceCity.id] ?? false ? IBColors.tappedDown : Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    margin: EdgeInsets.only(
                        top: SPACING_VERTICAL,
                        left: SPACING_HORIZONTAL/2
                    ),
                  ),
                  onTapCancel: () {
                    setState(() {
                      taps[event.payloadPlaceCity.id] = false;
                    });
                  },
                  onTapDown: (_) {
                    setState(() {
                      taps[event.payloadPlaceCity.id] = true;
                    });
                  },
                  onTapUp: (_) {
                    IBWidgetApp.pushWidget(IBWidgetPlace(event.payloadPlaceCity), context);
                    setState(() {
                      taps[event.payloadPlaceCity.id] = false;
                    });
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
                  top: SPACING_VERTICAL,
                  left: SPACING_HORIZONTAL,
                  right: SPACING_HORIZONTAL
              ),
            ),
            event.idCreator != null ? Container(
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
                        color: taps[userPayloadCreator.id] ?? false ? IBColors.tappedDown : Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    onTapCancel: () {
                      setState(() {
                        taps[userPayloadCreator.id] = false;
                      });
                    },
                    onTapDown: (_) {
                      setState(() {
                        taps[userPayloadCreator.id] = true;
                      });
                    },
                    onTapUp: (_) {
                      IBWidgetApp.pushWidget(IBWidgetUser(userPayload: userPayloadCreator), context);
                      setState(() {
                        taps[userPayloadCreator.id] = false;
                      });
                    },
                  ),
                ],
                runSpacing: SPACING_VERTICAL/2,
                spacing: SPACING_HORIZONTAL/2,
              ),
              margin: EdgeInsets.only(
                top: SPACING_VERTICAL,
                left: SPACING_HORIZONTAL,
              ),
            ) : Container(),
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
                        color: taps[userPayload.id] ?? false ? IBColors.tappedDown : Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    onTapCancel: () {
                      setState(() {
                        taps[userPayload.id] = false;
                      });
                    },
                    onTapDown: (_) {
                      setState(() {
                        taps[userPayload.id] = true;
                      });
                    },
                    onTapUp: (_) {
                      IBWidgetApp.pushWidget(IBWidgetUser(userPayload: userPayload), context);
                      setState(() {
                        taps[userPayload.id] = false;
                      });
                    },
                  ),
                ]).expand((list) => list).toList() +
                    (event.idsFollowers.length > idsFollowersShown.length ? [
                      GestureDetector(
                        child: Text(
                          IBLocalString.eventMoreFollowersCount(event.idsFollowers.length - idsFollowersShown.length),
                          style: TextStyle(
                            color: taps[IS_TAPPED_MORE_FOLLOWERS_COUNT] ?? false ? IBColors.tappedDown : Colors.black,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        onTapCancel: () {
                          setState(() {
                            taps[IS_TAPPED_MORE_FOLLOWERS_COUNT] = false;
                          });
                        },
                        onTapDown: (_) {
                          setState(() {
                            taps[IS_TAPPED_MORE_FOLLOWERS_COUNT] = true;
                          });
                        },
                        onTapUp: (_) {
                          IBWidgetApp.pushWidget(IBWidgetUsersPayloads(true, event.idsFollowers, event.name), context);
                          setState(() {
                            taps[IS_TAPPED_MORE_FOLLOWERS_COUNT] = false;
                          });
                        },
                      ),
                    ] : []),
                runSpacing: SPACING_VERTICAL/2,
                spacing: SPACING_HORIZONTAL/2,
              ),
              margin: EdgeInsets.only(
                  top: SPACING_VERTICAL,
                  left: SPACING_HORIZONTAL,
                  bottom: SPACING_VERTICAL_EDGE
              ),
            ) : GestureDetector(
              child: Container(
//                child: Text(
//                  IBLocalString.eventFollowersCount(Random().nextInt(event.idGroup != null ? 50 : 1000)),
//                ),
                child: Text(
                  event.idsFollowers.isEmpty ? IBLocalString.eventNoFollowers : IBLocalString.eventFollowersCount(event.idsFollowers.length),
                  style: TextStyle(
                      fontStyle: event.idsFollowers.isEmpty ? FontStyle.italic : FontStyle.normal
                  ),
                ),
                margin: EdgeInsets.only(
                    top: SPACING_VERTICAL,
                    left: SPACING_HORIZONTAL,
                    bottom: SPACING_VERTICAL_EDGE
                ),
              ),
            ),
            Container(
              color: IBColors.divider,
              height: 0.5,
              margin: EdgeInsets.only(
                  top: SPACING_VERTICAL,
                  left: SPACING_HORIZONTAL
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
                  color: IBUserApp.currentId == event.idCreator || !isUserAppFollowing ? Colors.grey : IBColors.logo,
                ),
                margin: EdgeInsets.only(
                    top: SPACING_VERTICAL,
                    right: IBUserApp.currentId == event.idCreator ? 0.0 : SPACING_HORIZONTAL
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
                                  left: SPACING_HORIZONTAL/2
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
        IBMessaging.send(event.name, IBLocalString.eventMessageFollower(IBUserApp.current.name, userPayload[IBFirestore.CODE_LANGUAGE] ?? "es"), {IBMessaging.ID_EVENT : event.id}, userPayload[IBFirestore.TOKEN]);
      });
    }
  }
}