
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ib/IBColors.dart';
import 'package:ib/IBFirestore.dart';
import 'package:ib/IBFirestoreEvent.dart';
import 'package:ib/IBFirestoreGroup.dart';
import 'package:ib/IBFirestoreUser.dart';
import 'package:ib/IBLocalString.dart';
import 'package:ib/IBUserApp.dart';

import 'package:ib/IBWidgetApp.dart';
import 'package:ib/IBWidgetEvent.dart';
import 'package:ib/IBWidgetEventCreate.dart';
import 'package:ib/IBWidgetGroupCreate.dart';
import 'package:ib/IBWidgetUser.dart';
import 'package:ib/IBWidgetUserIcon.dart';
import 'package:ib/IBWidgetUserSelect.dart';


class IBWidgetGroup extends StatefulWidget {

  final IBFirestoreGroup groupPayload;

  IBWidgetGroup(this.groupPayload, {Key key}) : super(key: key);

  @override
  IBStateWidgetGroup createState() {
    return IBStateWidgetGroup(this.groupPayload);
  }
}


class IBStateWidgetGroup extends State<IBWidgetGroup> {

  static double sizeWidthPayload = 65.0;

  static double spacingHorizontal = 8.0;
  static double spacingVertical = 6.0;
  static double spacingVerticalEdge = 8.0;

  IBFirestoreGroup groupPayload;

  IBStateWidgetGroup(this.groupPayload);

  IBFirestoreGroup group;

  var eventsActive = List<IBFirestoreEvent>();
  var eventsInactive = List<IBFirestoreEvent>();

  bool isTappedAction = false;

  var usersPayloadsMembers = List<IBFirestoreUser>();

  @override
  void initState() {

    super.initState();

    IBLocalString.context = context;

    setupAsync();
  }


  setupAsync() async {

    var group = await IBFirestore.getGroup(groupPayload.id);
    var usersPayloadsMembers = group.idsMembers.map<IBFirestoreUser>((id) => IBFirestoreUser.firestore(id, IBFirestore.usersPayloads[id])).toList();

    setState(() {
      this.group = group;
      this.usersPayloadsMembers = usersPayloadsMembers;
    });

    loadEvents();
  }


  loadEvents() async {

    var events = await IBFirestore.getEventsGroup(idGroup: group.id);
    events.sort((event1, event2) => event2.countFollowers.compareTo(event1.countFollowers));

    setState(() {
      this.eventsActive = events.where((event) => event.isActive).toList();
      this.eventsInactive = events.where((event) => !event.isActive).toList();
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
          group != null ? PopupMenuButton<String>(
            child: Container(
              child: Icon(
                Icons.more_vert,
                color: isTappedAction ? IBColors.tappedDownLight : Colors.white,
              ),
              margin: EdgeInsets.only(
                  right: spacingHorizontal
              ),
            ),
            onSelected: (value) {
              if (value == IBLocalString.groupActionAddEvent) {
                IBWidgetApp.pushWidget(IBWidgetEventCreate(group: group), context);
              }
              else if (value == IBLocalString.groupActionEdit) {
                IBWidgetApp.pushWidget(IBWidgetGroupCreate(group: group), context);
              }
              else if (value == IBLocalString.groupActionAddMembers) {
                IBWidgetApp.pushWidget(IBWidgetUserSelect(idsExclude: group.idsMembers, onSelect: (usersPayloadsSelected) {
                  addIdsMembers(usersPayloadsSelected);
                }), context);
              }
              else if (value == IBLocalString.groupActionLeave) {
                IBFirestore.addGroupIdsMembers(group, [IBUserApp.current.id], add: false);
                Navigator.pop(context);
              }
            },
            itemBuilder: (BuildContext context) {

              var items = List<PopupMenuItem<String>>();

              items.addAll([
                // add event
                PopupMenuItem<String>(
                  value: IBLocalString.groupActionAddEvent,
                  child: Row(
                    children: <Widget>[
                      Text(
                          IBLocalString.groupActionAddEvent
                      ),
                    ],
                  ),
                ),
                // add members
                PopupMenuItem<String>(
                  value: IBLocalString.groupActionAddMembers,
                  child: Row(
                    children: <Widget>[
                      Text(
                          IBLocalString.groupActionAddMembers
                      ),
                    ],
                  ),
                ),
                // edit
                PopupMenuItem<String>(
                  value: IBLocalString.groupActionEdit,
                  child: Row(
                    children: <Widget>[
                      Text(
                          IBLocalString.groupActionEdit
                      ),
                    ],
                  ),
                ),
              ]);

//              if (group.idsMembers.length > 1) {
//                items.add(                // leave group
//                  PopupMenuItem<String>(
//                    value: IBLocalString.groupActionLeave,
//                    child: Row(
//                      children: <Widget>[
//                        Text(
//                            IBLocalString.groupActionLeave
//                        ),
//                      ],
//                    ),
//                  ),
//                );
//              }

              return items;
            },
          ) : Container()
        ],
        centerTitle: false,
        elevation: 1.0,
        title: GestureDetector(
            child: Text(
              groupPayload.name,
              style: TextStyle(
                  color: Colors.white
              ),
            ),
            onTapDown: (_) {}
        ),
      ),
      body: group != null ? ListView(
        children: <Widget>[
          Container(
              child: Text(
                group.description,
                textAlign: TextAlign.center,
              ),
              margin: EdgeInsets.only(
                  top: spacingVerticalEdge,
                  left: spacingHorizontal,
                  right: spacingHorizontal
              )
          ),
          Center(
            child: LayoutBuilder(builder: (context, constraints) {
              return Container(
                color: IBColors.divider,
                height: 0.5,
                margin: EdgeInsets.only(
                    top: spacingVertical
                ),
                width: min(constraints.maxWidth - spacingHorizontal*2, group.description.length * 14.0/2.3),
              );
            }),
          ),
          Container(
              child: Text(
                group.idsMembers.isEmpty ? IBLocalString.groupNoMembers : IBLocalString.groupMembersCount(group.idsMembers.length),
                style: TextStyle(
                    fontStyle: group.idsMembers.isEmpty ? FontStyle.italic : FontStyle.normal
                ),
              ),
              margin: EdgeInsets.only(
                top: spacingVertical,
                left: spacingHorizontal,
              )
          ),
          usersPayloadsMembers.isNotEmpty ? Container(
            child: ListView(
              children: usersPayloadsMembers.map((userPayload) {
                return GestureDetector(
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: IBWidgetUserIcon(
                              userPayload.id
                          ),
                          width: sizeWidthPayload,
                        ),
                        Container(
                          child: Text(
                            userPayload.name,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                          margin: EdgeInsets.only(
                              top: spacingVertical/2
                          ),
                          width: sizeWidthPayload,
                        )
                      ],
                    ),
                    margin: EdgeInsets.only(
                      left: spacingHorizontal/2,
                      right: spacingHorizontal/2,
                    ),
                  ),
                  onTapUp: (_) {
                    IBWidgetApp.pushWidget(IBWidgetUser(userPayload: userPayload), context);
                  },
                );
              }).toList(),
              padding: EdgeInsets.symmetric(
//                    horizontal: spacingHorizontal/2,
//                    vertical: spacingVertical
              ),
              scrollDirection: Axis.horizontal,
            ),
            height: sizeWidthPayload + 16.0 + spacingVertical/2, // font size plus margin
            margin: EdgeInsets.only(
              top: spacingVertical,
              left: spacingHorizontal/2,
              right: spacingHorizontal/2,
            ),
          ) : Container(),
          eventsActive != null && eventsActive.isNotEmpty ? Container(
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
                      IBLocalString.groupEventsActiveCount(eventsActive.length),
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
                ] + eventsActive.map<Widget>((event) => IBWidgetEvent(event)).toList()
            ),
            margin: EdgeInsets.only(
              top: spacingVertical,
            ),
          ) : Container(),
          eventsInactive != null && eventsInactive.isNotEmpty ? Container(
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
                      IBLocalString.userEventsCreatedActiveCount(eventsInactive.length),
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
                ] + eventsInactive.map<Widget>((event) => IBWidgetEvent(event)).toList()
            ),
            margin: EdgeInsets.only(
              top: spacingVertical,
            ),
          ) : Container(),
        ],
      ) : Container(),
    );
  }

  addIdsMembers(List<IBFirestoreUser> usersPayloads) {

    var idsMembers = usersPayloads.map((userPayload) => userPayload.id).toList();
    IBFirestore.addGroupIdsMembers(group, idsMembers);

    setState(() {
      group.idsMembers.addAll(idsMembers);
      usersPayloadsMembers = group.idsMembers.map<IBFirestoreUser>((id) => IBFirestoreUser.firestore(id, IBFirestore.usersPayloads[id])).toList();
    });
  }
}

