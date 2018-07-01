

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ib/IBUserApp.dart';
import 'package:ib/IBColors.dart';
import 'package:ib/IBFirestore.dart';
import 'package:ib/IBFirestoreGroup.dart';
import 'package:ib/IBFirestoreUser.dart';
import 'package:ib/IBLocalString.dart';
import 'package:ib/IBLocation.dart';

import 'package:ib/IBWidgetApp.dart';
import 'package:ib/IBWidgetUserIcon.dart';
import 'package:ib/IBWidgetUserSearch.dart';


typedef void IBWidgetGroupCreateCompletion(IBFirestoreGroup group);


class IBWidgetGroupCreate extends StatefulWidget {

  // edit mode
  final IBFirestoreGroup group;

  final IBWidgetGroupCreateCompletion onComplete;

  IBWidgetGroupCreate({this.group, this.onComplete, Key key}) : super(key: key);

  @override
  IBStateWidgetGroupCreate createState() {
    return IBStateWidgetGroupCreate(group: group, onComplete: onComplete);
  }
}


class IBStateWidgetGroupCreate extends State<IBWidgetGroupCreate> {

  static int lengthMaxDescription = 150;
  static int lengthMaxName = 35;

  static int lengthMinDescription = 10;
  static int lengthMinName = 6;

  static int linesMaxDescription = 3;
  static int linesMaxName = 1;

  static double sizeIcon = 25.0;
  static double sizeWidthPayload = 65.0;

  static double spacingHorizontal = 8.0;
  static double spacingVertical = 6.0;
  static double spacingVerticalEdge = 8.0;

  IBFirestoreGroup group;
  IBWidgetGroupCreateCompletion onComplete;

  IBStateWidgetGroupCreate({this.group, this.onComplete});

  var focusNodeSearch = FocusNode();

  bool get isCreateEnabled {
    return textControllerName.text.trim().length >= lengthMinName && textControllerDescription.text.trim().length >= lengthMinDescription;
  }

  var isCreating = false;

  bool get isEditEnabled {
    return group.name != textControllerName.text.trim() || group.description != textControllerDescription.text.trim();
  }

  bool get isEditMode {
    return group != null;
  }

  var isTappedIcon = false;
  var isTappedSearch = false;

  var scrollController = ScrollController();

  var textControllerDescription = TextEditingController();
  var textControllerName = TextEditingController();
  var textControllerSearch = TextEditingController();

  var idsUsersSelected = List<IBFirestoreUser>();

  @override
  void initState() {

    super.initState();

    // IMPORTANT: determine locale
    IBLocalString.context = context;

    // only for testing
    IBLocation.getLocationInfo();

    if (group != null) {
      textControllerName.text = group.name;
      textControllerDescription.text = group.description;
    }

    setupAsync();
  }

  setupAsync() async {
//    await IBDefaults.getUpdatedUser();
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
            GestureDetector(
                child: Center(
                  child: Container(
                    child: Text(
                      isEditMode ? IBLocalString.groupCreateEdit : IBLocalString.groupCreate,
                      style: TextStyle(
                          color: isCreateEnabled && (!isEditMode || isEditEnabled) ? isTappedIcon ? IBColors.tappedDownLight : Colors.white : IBColors.actionDisable,
                          fontSize: Theme.of(context).textTheme.title.fontSize,
                          fontWeight: Theme.of(context).textTheme.title.fontWeight
                      ),
                    ),
                    margin: EdgeInsets.only(
                        right: spacingHorizontal
                    ),
                  ),
                ),
                onTapCancel: () {
                  setState(() {
                    isTappedIcon = false;
                  });
                },
                onTapDown: (_) {
                  setState(() {
                    isTappedIcon = true;
                  });
                },
                onTapUp: (_) async {
                  if (isCreateEnabled && (!isEditMode || isEditEnabled) && !isCreating) {
                    isCreating = true;
                    createGroup();
                  }
                }
            ),
          ],
          centerTitle: false,
          elevation: 1.0,
          title: GestureDetector(
              child: Text(
                group != null ? group.name : IBLocalString.groupCreateTitle,
                style: TextStyle(
                    color: Colors.white
                ),
              ),
              onTapDown: (_) {}
          ),
        ),
        body: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: ListView(
                children: <Widget>[
                  Container(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          child: TextField(
                            controller: textControllerName,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(
//                                top: spacingVertical,
                                ),
                                hintText: IBLocalString.groupCreateHintName
                            ),
                            keyboardType: TextInputType.multiline,
                            maxLines: linesMaxName,
                            maxLength: lengthMaxName,
                            onChanged: (_) {
                              setState(() {
                              });
                            },
                          ),
                          margin: EdgeInsets.only(
                            top: spacingVertical,
//                            left: spacingHorizontal
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            child: Icon(
                              Icons.done,
                              color: textControllerName.text.trim().length >= lengthMinName ? IBColors.logo : Colors.grey,
                              size: sizeIcon,
                            ),
                            margin: EdgeInsets.only(
                                top: spacingVertical/2
                            ),
                          ),
                        )
                      ],
                    ),
                    margin: EdgeInsets.only(
                      top: spacingVertical,
                      left: spacingHorizontal,
                      right: spacingHorizontal,
                    ),
                  ),
                  Container(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          child: TextField(
                            controller: textControllerDescription,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(
//                                top: spacingVertical,
                                ),
                                hintText: IBLocalString.groupCreateHintDescription
                            ),
                            keyboardType: TextInputType.multiline,
                            maxLength: lengthMaxDescription,
                            maxLines: linesMaxDescription,
                            onChanged: (_) {
                              setState(() {
                              });
                            },
                          ),
                          margin: EdgeInsets.only(
                            top: spacingVertical,
//                            left: spacingHorizontal
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            child: Icon(
                              Icons.done,
                              color: textControllerDescription.text.trim().length >= lengthMinDescription ? IBColors.logo : Colors.grey,
                              size: sizeIcon,
                            ),
                            margin: EdgeInsets.only(
                                top: spacingVertical/2
                            ),
                          ),
                        )
                      ],
                    ),
                    margin: EdgeInsets.only(
                      top: spacingVertical,
                      left: spacingHorizontal,
                      right: spacingHorizontal,
                    ),
                  ),
                  !isEditMode ? Container(
                      child: Text(
                        idsUsersSelected.isEmpty ? IBLocalString.groupCreateNoMembers : IBLocalString.groupCreateMembersCount(idsUsersSelected.length),
                        style: TextStyle(
                            fontSize: 16.0,
                            fontStyle: idsUsersSelected.isEmpty ? FontStyle.italic : FontStyle.normal
                        ),
                      ),
                      margin: EdgeInsets.only(
                        top: spacingVertical,
                        left: spacingHorizontal,
                      )
                  ) : Container(),
                  !isEditMode && idsUsersSelected.isNotEmpty ? Container(
                    child: ListView(
                      children: idsUsersSelected.map((payload) {
                        return Container(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: IBWidgetUserIcon(
                                    payload.id
                                ),
                                height: sizeWidthPayload,
                              ),
                              Container(
                                child: Text(
                                  payload.name,
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
                        );
                      }).toList(),
                      scrollDirection: Axis.horizontal,
                    ),
                    height: sizeWidthPayload + 16.0 + spacingVertical/2, // font size plus margin
                    margin: EdgeInsets.only(
                      top: spacingVertical,
                      left: spacingHorizontal/2,
                      right: spacingHorizontal/2,
                    ),
                    width: sizeWidthPayload,
                  ) : Container(),
                  !isEditMode ? Container(
                    child: GestureDetector(
                      child: Text(
                        IBLocalString.groupCreateSearchMembers,
                        style: TextStyle(
                            color: isTappedSearch ? IBColors.logo : Colors.black,
                            fontSize: 16.0
                        ),
                      ),
                      onTapCancel: () {
                        setState(() {
                          isTappedSearch = false;
                        });
                      },
                      onTapDown: (_) {
                        setState(() {
                          isTappedSearch = true;
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          isTappedSearch = false;
                        });
                        IBWidgetApp.pushWidget(IBWidgetUserSearch(idsSelected: idsUsersSelected.map((userPayload) => userPayload.id).toList(), onSelect: (payloads) {
                          setState(() {
                            this.idsUsersSelected.addAll(payloads);
                          });
                        }), context);
                      },
                    ),
                    margin: EdgeInsets.only(
                      top: spacingVertical,
                      left: spacingHorizontal,
                    ),
                  ) : Container(),
                ],
                controller: scrollController,
                shrinkWrap: true,
              ),
            ),
          ],
        )
    );
  }

  createGroup() async {
    if (isEditMode) {
      var groupNameBeforeUpdate = group.name;
      group.name = textControllerName.text.trim();
      group.description = textControllerDescription.text.trim();
      if (groupNameBeforeUpdate != group.name) {
        IBFirestore.addGroupPayload(group);
      }
    }
    else {
      idsUsersSelected.add(IBUserApp.current);
      group = IBFirestoreGroup(textControllerName.text.trim(), textControllerDescription.text.trim(), idsUsersSelected.map((userPayload) => userPayload.id).toList());
    }
    await IBFirestore.addGroup(group);
    Navigator.pop(context);
    if (onComplete != null) {
      onComplete(group);
    }
  }
}













