
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ib/IBUserApp.dart';
import 'package:ib/IBColors.dart';
import 'package:ib/IBDefaults.dart';
import 'package:ib/IBLocalString.dart';
import 'package:ib/IBFirestore.dart';
import 'package:ib/IBFirestoreEvent.dart';
import 'package:ib/IBFirestoreUser.dart';

import 'package:ib/IBWidgetApp.dart';
import 'package:ib/IBWidgetEvent.dart';
import 'package:ib/IBWidgetTapText.dart';
import 'package:ib/IBWidgetUserCreate.dart';
import 'package:ib/IBWidgetUserIcon.dart';
import 'package:ib/IBWidgetUsersPayloads.dart';

class IBWidgetUser extends StatefulWidget {

  final IBFirestoreUser userPayload;
  final IBFirestoreUser user;

  IBWidgetUser({this.user, this.userPayload, Key key}) : super(key: key);

  @override
  IBStateWidgetUser createState() {
    return IBStateWidgetUser(user: user, userPayload: userPayload);
  }
}

class IBStateWidgetUser extends State<IBWidgetUser> {

  static double sizeUserIcon = 65.0;

  static double spacingHorizontal = 8.0;
  static double spacingVertical = 6.0;
  static double spacingVerticalEdge = 8.0;

  IBFirestoreUser user;
  IBFirestoreUser userPayload;

  IBStateWidgetUser({this.user, this.userPayload});

  var eventsCreatedActive = List<IBFirestoreEvent>();
  var eventsCreatedInactive = List<IBFirestoreEvent>();
  var eventsFollowingActive = List<IBFirestoreEvent>();
  var eventsFollowingInactive = List<IBFirestoreEvent>();

  bool get areGroupsInCommonAll {

    if (IBUserApp.current == null) {
      return false;
    }
    if (IBUserApp.current.idsGroups.length != user.idsGroups.length) {
      return false;
    }
    IBUserApp.current.idsGroups.asMap().forEach((index, idGroup) {
      if (idGroup != user.idsGroups[index]) {
        return false;
      }
    });
    return true;
  }

  List<String> get idsGroupsInCommon {
    if (IBUserApp.current == null) {
      return [];
    }
    return IBUserApp.current.idsGroups.toSet().intersection(user.idsGroups.toSet()).toList();
  }

  String get idUserNonNull => user != null ? user.id : userPayload.id;

  bool get isSelf => idUserNonNull == IBUserApp.currentId;

  var isAppUserFollowing = false;
  var isTappedAction = false;

  List<String> get idsFollowersShown {
    if (IBUserApp.current == null) {
      return [];
    }
    return user.idsFollowers.toSet().intersection(IBUserApp.current.idsFollowing.toSet()).toList();
  }

  List<String> get idsFollowingShown {
    if (user == null) {
      return [];
    }
    return user.idsFollowing.toSet().intersection(IBUserApp.current.idsFollowing.toSet()).toList();
  }

  List<IBFirestoreUser> usersPayloadsFollowersShown;
  List<IBFirestoreUser> usersPayloadsFollowingShown;

    @override
  void initState() {

    super.initState();

    IBLocalString.context = context;

    if (IBUserApp.current != null) {
      isAppUserFollowing = IBUserApp.current.idsFollowing.contains(idUserNonNull);
    }

    usersPayloadsFollowersShown = idsFollowersShown.map<IBFirestoreUser>((id) => IBFirestoreUser.firestore(id, IBFirestore.usersPayloads[id])).toList();
    usersPayloadsFollowingShown = idsFollowersShown.map<IBFirestoreUser>((id) => IBFirestoreUser.firestore(id, IBFirestore.usersPayloads[id])).toList();

    setupAsync();
  }

  setupAsync() async {

    if (user == null) {
      user = await IBFirestore.getUser(idUserNonNull);
      setState(() {
        this.user = user;
      });
    }

    loadEvents();
  }

  loadEvents() async {

    var eventsCreated = List<IBFirestoreEvent>();
    var eventsFollowing = List<IBFirestoreEvent>();

    eventsCreated.addAll(await IBFirestore.getEvents(idUserCreator: user.id));
    eventsFollowing.addAll(await IBFirestore.getEvents(idUserFollower: user.id));

    if (areGroupsInCommonAll) {
      eventsCreated.addAll(await IBFirestore.getEventsGroup(idUserCreator: idUserNonNull));
      eventsFollowing.addAll(await IBFirestore.getEventsGroup(idUserFollower: idUserNonNull));
    }
    else {
      for (String idGroup in idsGroupsInCommon) {
        eventsCreated.addAll(await IBFirestore.getEventsGroup(idGroup: idGroup, idUserCreator: idUserNonNull));
      }
      for (String idGroup in idsGroupsInCommon) {
        eventsFollowing.addAll(await IBFirestore.getEventsGroup(idGroup: idGroup, idUserFollower: idUserNonNull));
      }
    }

    eventsCreated.sort((event1, event2) => event2.countFollowers.compareTo(event1.countFollowers));
    eventsFollowing.sort((event1, event2) => event2.countFollowers.compareTo(event1.countFollowers));

    setState(() {
      this.eventsCreatedActive = eventsCreated.where((event) => event.isActive).toList();
      this.eventsCreatedInactive = eventsCreated.where((event) => !event.isActive).toList();
      this.eventsFollowingActive = eventsFollowing.where((event) => event.isActive).toList();
      this.eventsFollowingInactive = eventsFollowing.where((event) => !event.isActive).toList();
    });
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
          actions: [
            user != null ? PopupMenuButton<String>(
              child: Container(
                child: Icon(
                  user.id == IBUserApp.currentId ? Icons.more_vert : Icons.done,
                  color: isTappedAction ?
                  IBColors.actionTappedDown : user.id != IBUserApp.currentId ?
                  isAppUserFollowing ?
                  Colors.white : Colors.white70 : Colors.white,
                ),
                margin: EdgeInsets.only(
                    right: spacingHorizontal
                ),
              ),
              onSelected: (value) async {
                if (value == IBLocalString.userActionEdit) {
                  IBWidgetApp.pushWidget(IBWidgetUserCreate(), context);
                }
                else if (value == IBLocalString.userActionFollowing) {
                  if (IBUserApp.current != null) {
                    setState(() {
                      isAppUserFollowing = !isAppUserFollowing;
                    });
                    setState(() {
                      IBFirestore.followUser(user, follow: isAppUserFollowing);
                    });
                  }
                  else {
                    IBWidgetApp.pushWidget(IBWidgetUserCreate(onComplete: () async {
                      setState(() {
                        isAppUserFollowing = !isAppUserFollowing;
                      });
                      setState(() {
                        IBFirestore.followUser(user, follow: isAppUserFollowing);
                      });
                    }), context);
                  }
                }
                else if (value == IBLocalString.userActionLogout) {
                  IBUserApp.current = null;
                  IBDefaults.setIdUser(null);
                  Navigator.pop(context);
                }
              },
              itemBuilder: (BuildContext context) {
                var items = List<PopupMenuItem<String>>();
                if (isSelf) {
                  items.addAll([
                    // edit
                    PopupMenuItem<String>(
                      value: IBLocalString.userActionEdit,
                      child: Row(
                        children: <Widget>[
                          Text(
                              IBLocalString.userActionEdit
                          ),
                        ],
                      ),
                    ),
                    // logout
                    PopupMenuItem<String>(
                      value: IBLocalString.userActionLogout,
                      child: Row(
                        children: <Widget>[
                          Text(
                              IBLocalString.userActionLogout
                          ),
                        ],
                      ),
                    ),
                  ]);
                }
                else {
                  items.addAll([
                    PopupMenuItem<String>(
                      value: IBLocalString.userActionFollowing,
                      child: Row(
                        children: <Widget>[
                          Text(
                              IBLocalString.userActionFollowing
                          ),
                          Container(
                            child: Icon(
                              Icons.done,
                              color: isAppUserFollowing ? IBColors.logo : Colors.grey,
                            ),
                            margin: EdgeInsets.only(
                                left: spacingHorizontal/2
                            ),
                          )
                        ],
                      ),
                    ),
                  ]);
                }
                return items;
              },
            ) : Container(),
          ],
          centerTitle: false,
          elevation: 1.0,
          title: Text(
            user != null ? user.name : "",
            style: TextStyle(
                color: Colors.white
            ),
          ) ,
        ),
        body: user != null ? ListView(
          children: <Widget>[
            Center(
              child: Container(
                child: IBWidgetUserIcon(
                  user.id,
                ),
                height: sizeUserIcon,
                margin: EdgeInsets.only(
                    top: spacingVertical
                ),
                width: sizeUserIcon,
              ),
            ),
            Center(
              child: Container(
                child: Text(
                  user.description,
                  textAlign: TextAlign.center,
                ),
                margin: EdgeInsets.only(
                    top: spacingVertical,
                    right: spacingHorizontal,
                    left: spacingHorizontal
                ),
              ),
            ),
            Center(
              child: LayoutBuilder(builder: (context, constraints) {
                return Container(
                  color: IBColors.divider,
                  height: 0.5,
                  margin: EdgeInsets.only(
                      top: spacingVertical
                  ),
                  width: min(constraints.maxWidth - spacingHorizontal*2, user.description.length * 14.0/2.3),
                );
              }),
            ),
            usersPayloadsFollowersShown.isNotEmpty ? Center(
              child: Container(
                child: Wrap(
                  children: <Widget>[
                    Text(
                      IBLocalString.userFollowedBy,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.left,
                    )
                  ] + usersPayloadsFollowersShown.map((userPayload) => [
                    Container(
                      child: IBWidgetUserIcon(
                        user.id,
                      ),
                      height: 18.0,
                      margin: EdgeInsets.only(
                      ),
                      width: 18.0,
                    ),
                    IBWidgetTapText(
                      user.name,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                      onTap: () {
                        IBWidgetApp.pushWidget(IBWidgetUser(userPayload: userPayload), context);
                      },
                    )
                  ]).expand((list) => list).toList() + (user.idsFollowers.length > idsFollowersShown.length ? [
                    IBWidgetTapText(
                      IBLocalString.eventMoreFollowersCount(user.idsFollowers.length - idsFollowersShown.length),
                      onTap: () {
                        IBWidgetApp.pushWidget(IBWidgetUsersPayloads(true, user.idsFollowers, user.name), context);
                      },
                    )
                  ] : []),
                  runSpacing: spacingVertical/2,
                  spacing: spacingHorizontal/2,
                ),
                margin: EdgeInsets.only(
                    top: spacingVertical,
                    left: spacingHorizontal,
                    right: spacingHorizontal
                ),
              ),
            ) : Center(
              child: Container(
                child: IBWidgetTapText(
                  user.idsFollowers.isEmpty ? IBLocalString.userNoFollowers : IBLocalString.eventFollowersCount(user.idsFollowers.length),
                  style: TextStyle(
                      fontStyle: user.idsFollowers.isEmpty ? FontStyle.italic : FontStyle.normal
                  ),
                  onTap: () {
                    if (user.idsFollowers.isNotEmpty) {
                      IBWidgetApp.pushWidget(IBWidgetUsersPayloads(true, user.idsFollowers, user.name), context);
                    }
                  },
                  isEnabledOnTap: user.idsFollowers.isNotEmpty,
                ),
                margin: EdgeInsets.only(
                    top: spacingVertical,
                    left: spacingHorizontal,
                    right: spacingHorizontal
                ),
              ),
            ),
            usersPayloadsFollowingShown.isNotEmpty ? Center(
              child: Container(
                child: Wrap(
                  children: <Widget>[
                    Text(
                      IBLocalString.userFollowedBy,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.left,
                    )
                  ] + usersPayloadsFollowingShown.map((userPayload) => [
                    Container(
                      child: IBWidgetUserIcon(
                        user.id,
                      ),
                      height: 18.0,
                      margin: EdgeInsets.only(
                      ),
                      width: 18.0,
                    ),
                    IBWidgetTapText(
                      user.name,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                      onTap: () {
                        IBWidgetApp.pushWidget(IBWidgetUser(userPayload: userPayload), context);
                      },
                    )
                  ]).expand((list) => list).toList() + (user.idsFollowing.length > idsFollowingShown.length ? [
                    IBWidgetTapText(
                      IBLocalString.eventMoreFollowersCount(user.idsFollowing.length - idsFollowingShown.length),
                      onTap: () {
                        IBWidgetApp.pushWidget(IBWidgetUsersPayloads(false, user.idsFollowing, user.name), context);
                      },
                    )
                  ] : []),
                  runSpacing: spacingVertical/2,
                  spacing: spacingHorizontal/2,
                ),
                margin: EdgeInsets.only(
                    top: spacingVertical,
                    left: spacingHorizontal,
                    right: spacingHorizontal
                ),
              ),
            ) : Center(
              child: Container(
                child: IBWidgetTapText(
                  user.idsFollowing.isEmpty ? IBLocalString.userNoFollowing : IBLocalString.userFollowingCount(user.idsFollowing.length),
                  style: TextStyle(
                      fontStyle: user.idsFollowing.isEmpty ? FontStyle.italic : FontStyle.normal
                  ),
                  onTap: () {
                    if (user.idsFollowing.isNotEmpty) {
                      IBWidgetApp.pushWidget(IBWidgetUsersPayloads(false, user.idsFollowing, user.name), context);
                    }
                  },
                  isEnabledOnTap: user.idsFollowing.isNotEmpty,
                ),
                margin: EdgeInsets.only(
                    top: spacingVertical,
                    left: spacingHorizontal,
                    right: spacingHorizontal
                ),
              ),
            ),
            eventsCreatedActive != null && eventsCreatedActive.isNotEmpty ? Container(
              child: Column(
                  children: <Widget>[
                    Container(
                      color: IBColors.divider,
                      height: 0.5,
                      margin: EdgeInsets.only(
                      ),
                    ),
                    Container(
                      child: Text(
                        IBLocalString.userEventsCreatedActiveCount(eventsCreatedActive.length),
                        style: TextStyle(
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      margin: EdgeInsets.only(
                          top: spacingVertical/2,
                          bottom: spacingVertical/2
                      ),
                    ),
                    Container(
                      color: IBColors.divider,
                      height: 0.5,
                      margin: EdgeInsets.only(
                      ),
                    )
                  ] + eventsCreatedActive.map<Widget>((event) => IBWidgetEvent(event)).toList()
              ),
              margin: EdgeInsets.only(
                top: spacingVertical,
              ),
            ) : Container(),
            eventsCreatedInactive != null && eventsCreatedInactive.isNotEmpty ? Container(
              child: Column(
                  children: <Widget>[
                    Container(
                      color: IBColors.divider,
                      height: 0.5,
                      margin: EdgeInsets.only(
                      ),
                    ),
                    Container(
                      child: Text(
                        IBLocalString.userEventsCreatedInactiveCount(eventsCreatedInactive.length),
                        style: TextStyle(
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      margin: EdgeInsets.only(
                          top: spacingVertical/2,
                          bottom: spacingVertical/2
                      ),
                    ),
                    Container(
                      color: IBColors.divider,
                      height: 0.5,
                      margin: EdgeInsets.only(
                      ),
                    )
                  ] + eventsCreatedInactive.map<Widget>((event) => IBWidgetEvent(event)).toList()
              ),
              margin: EdgeInsets.only(
                top: spacingVertical,
              ),
            ) : Container(),
            eventsFollowingActive != null && eventsFollowingActive.isNotEmpty ? Container(
              child: Column(
                  children: <Widget>[
                    Container(
                      color: IBColors.divider,
                      height: 0.5,
                      margin: EdgeInsets.only(
                          top: spacingVertical,
                          left: spacingHorizontal,
                          right: spacingHorizontal
                      ),
                    ),
                    Container(
                      child: Text(
                        IBLocalString.userEventsFollowingActiveCount(eventsFollowingActive.length),
                        style: TextStyle(
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      margin: EdgeInsets.only(
                          top: spacingVertical/2,
                          bottom: spacingVertical/2
                      ),
                    ),
                    Container(
                      color: IBColors.divider,
                      height: 0.5,
                      margin: EdgeInsets.only(
                      ),
                    )
                  ] + eventsFollowingActive.map<Widget>((event) => IBWidgetEvent(event)).toList()
              ),
              margin: EdgeInsets.only(
                top: spacingVertical,
              ),
            ) : Container(),
            eventsFollowingInactive != null && eventsFollowingInactive.isNotEmpty ?
            Container(
              child: Column(
                  children: <Widget>[
                    Container(
                      color: IBColors.divider,
                      height: 0.5,
                      margin: EdgeInsets.only(
                      ),
                    ),
                    Container(
                      child: Container(
                        child: Text(
                          IBLocalString.userEventsFollowingInactiveCount(eventsFollowingInactive.length),
                          style: TextStyle(
                              fontWeight: FontWeight.w500
                          ),
                        ),
                        margin: EdgeInsets.only(
                            top: spacingVertical/2,
                            bottom: spacingVertical/2
                        ),
                      ),
                    ),
                    Container(
                      color: IBColors.divider,
                      height: 0.5,
                      margin: EdgeInsets.only(
                      ),
                    )
                  ] + eventsFollowingInactive.map<Widget>((event) => IBWidgetEvent(event)).toList()
              ),
              margin: EdgeInsets.only(
                top: spacingVertical,
              ),
            ) : Container(),
          ],
        ) : Container() // LOADING STATE
    );
  }
}






